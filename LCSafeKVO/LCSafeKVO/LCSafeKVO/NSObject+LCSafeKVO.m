//
//  NSObject+LCSafeKVO.m
//  LCSafeKVO
//
//  Created by lc on 2018/4/17.
//  Copyright © 2018年 liuchang. All rights reserved.
//

#import "NSObject+LCSafeKVO.h"
#import <objc/runtime.h>

//推荐采用SEL作为key值
SEL selKeyPathWithObjcetAndKey(id object, NSString *key) {
    NSString *str = [NSString stringWithFormat:@"%@%p", key, object];
    return NSSelectorFromString(str);
}

NSString *stringKeyPathWithObjcetAndKey(id object, NSString *key) {
    return [NSString stringWithFormat:@"%@%p", key, object];
}

NSString *keyPathDeleteAddress(id object, NSString *key) {
    NSRange range = [key rangeOfString:[NSString stringWithFormat:@"%p", object]];
    if (range.location != NSNotFound) {
        NSMutableString *deletekey = [key mutableCopy];
        [deletekey deleteCharactersInRange:range];
        return deletekey;
    }
    return key;
}

@implementation NSObject (LCSafeKVO)

#pragma mark 🍀🍀 public methods

- (void)lc_addObserver:(NSObject *)observer
            forKeyPath:(NSString *)keyPath
               options:(NSKeyValueObservingOptions)options
               context:(void *)context
             withBlock:(LCSafeKVOBlock)block {
    
    objc_setAssociatedObject(observer, selKeyPathWithObjcetAndKey(self, keyPath), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addObserver:observer forKeyPath:keyPath options:options context:context];
}

#pragma mark 🍀🍀 kvo

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    
    LCSafeKVOBlock block = objc_getAssociatedObject(self, selKeyPathWithObjcetAndKey(object, keyPath));
    if (block) {
        block(change, context);
    }
}

#pragma mark 🍀🍀 swizzle method

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self exchangeMethodImplementations:@selector(addObserver:forKeyPath:options:context:)];
        [self exchangeMethodImplementations:@selector(removeObserver:forKeyPath:)];
        [self exchangeMethodImplementations:NSSelectorFromString(@"dealloc")];
    });
}

+ (void)exchangeMethodImplementations:(SEL)selector {
    Method oldMethod = class_getInstanceMethod(self, selector);
    NSString *newSelectorString = [NSString stringWithFormat:@"lc_%@", NSStringFromSelector(selector)];
    SEL newSelector = NSSelectorFromString(newSelectorString);
    Method newMethod = class_getInstanceMethod(self, NSSelectorFromString(newSelectorString));
    
    if (class_addMethod(self, selector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(self, newSelector, method_getImplementation(oldMethod), method_getTypeEncoding(oldMethod));
    } else {
        method_exchangeImplementations(oldMethod, newMethod);
    }
}

- (void)lc_addObserver:(NSObject *)observer
            forKeyPath:(NSString *)keyPath
               options:(NSKeyValueObservingOptions)options
               context:(void *)context {
    
    if (observer == nil || keyPath == nil || keyPath.length == 0) {
        return;
    }
    
    dispatch_semaphore_wait(self.lc_kvoSemaphore, DISPATCH_TIME_FOREVER);
    if (!observer.lc_kvoMapTable) {
        observer.lc_kvoMapTable = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:0];
    }
    
    NSString *keyPathWithAddress = stringKeyPathWithObjcetAndKey(self, keyPath);
    
    //添加监听时判断是否已经添加过监听
    if (![[observer.lc_kvoMapTable objectForKey:keyPathWithAddress] isEqual:self]) {
        [observer.lc_kvoMapTable setObject:self forKey:keyPathWithAddress];
        [self lc_addObserver:observer forKeyPath:keyPath options:options context:context];
    }
    dispatch_semaphore_signal(self.lc_kvoSemaphore);
}

- (void)lc_removeObserver:(NSObject *)observer
               forKeyPath:(NSString *)keyPath {
    
    if (observer == nil || keyPath == nil || keyPath.length == 0) {
        return;
    }
    
    objc_setAssociatedObject(observer, selKeyPathWithObjcetAndKey(self, keyPath), nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    NSString *keyPathWithAddress = stringKeyPathWithObjcetAndKey(self, keyPath);
    dispatch_semaphore_wait(self.lc_kvoSemaphore, DISPATCH_TIME_FOREVER);
    
    //移除监听时判断是否存在当前监听
    if ([[observer.lc_kvoMapTable objectForKey:keyPathWithAddress] isEqual:self]) {
        [observer.lc_kvoMapTable removeObjectForKey:keyPathWithAddress];
        [self lc_removeObserver:observer forKeyPath:keyPath];
    }
    dispatch_semaphore_signal(self.lc_kvoSemaphore);
}

- (void)lc_dealloc {
    
    if (self.lc_kvoMapTable != nil) {
        
        dispatch_semaphore_wait(self.lc_kvoSemaphore, DISPATCH_TIME_FOREVER);
        
        //在dealloc方法中移除仍然存在的监听
        NSEnumerator<NSString *> *enumerator = [self.lc_kvoMapTable keyEnumerator];
        NSString *key;
        while ((key = enumerator.nextObject)) {
            id object = [self.lc_kvoMapTable objectForKey:key];
            [object lc_removeObserver:self forKeyPath:keyPathDeleteAddress(object, key)];
        }
        [self.lc_kvoMapTable removeAllObjects];
        self.lc_kvoMapTable = nil;
    }
    dispatch_semaphore_signal(self.lc_kvoSemaphore);
    
    [self lc_dealloc];
}

#pragma mark 🍀🍀 add properties

- (void)setLc_kvoMapTable:(NSMapTable *)lc_kvoMapTable {
    objc_setAssociatedObject(self, @selector(setLc_kvoMapTable:), lc_kvoMapTable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMapTable *)lc_kvoMapTable {
    return objc_getAssociatedObject(self, @selector(setLc_kvoMapTable:));
}

- (dispatch_semaphore_t)lc_kvoSemaphore {
    dispatch_semaphore_t semaphore = objc_getAssociatedObject(self, @selector(lc_kvoSemaphore));
    if (semaphore == NULL) {
        semaphore = dispatch_semaphore_create(1);
        objc_setAssociatedObject(self, @selector(lc_kvoSemaphore), semaphore, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return semaphore;
}

@end

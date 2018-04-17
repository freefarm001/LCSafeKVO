//
//  NSObject+LCSafeKVO.h
//  LCSafeKVO
//
//  Created by lc on 2018/4/17.
//  Copyright © 2018年 liuchang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^LCSafeKVOBlock)(NSDictionary<NSKeyValueChangeKey,id> *change, void *context);

@interface NSObject (LCSafeKVO)

- (void)lc_addObserver:(NSObject *)observer
            forKeyPath:(NSString *)keyPath
               options:(NSKeyValueObservingOptions)options
               context:(void *)context
             withBlock:(LCSafeKVOBlock)block;

@end

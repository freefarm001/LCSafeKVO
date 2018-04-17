# LCSafeKVO

为了安全地使用KVO，这里新建了一个NSObject+LCSafeKVO的分类来实现。

引用这个分类后，我们可以允许下列操作而不引起崩溃：

- 重复添加、移除监听。
- 监听者dealloc时仍有未移除的监听。

当然上面的两种行为是不推荐的，这里只是防患于未然。

另外，这里还提供了KVO的block的使用，例如：
```
[model1 lc_addObserver:self
            forKeyPath:@"name"
               options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
               context:nil
             withBlock:^(NSDictionary<NSKeyValueChangeKey,id> *change, void *context) {
    NSLog(@"model1> old = %@, new = %@", change[NSKeyValueChangeOldKey], change[NSKeyValueChangeNewKey]);
}];
```

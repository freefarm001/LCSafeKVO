//
//  PushedViewController.m
//  LCSafeKVO
//
//  Created by lc on 2018/4/17.
//  Copyright © 2018年 liuchang. All rights reserved.
//

#import "PushedViewController.h"

@interface PushedViewController ()

@property (strong, nonatomic) Model *model1;
@property (strong, nonatomic) Model *model2;

@end

@implementation PushedViewController

- (instancetype)initWithModel:(id)model1 andModel2:(id)model2 {
    if (self = [super init]) {
        
        _model1 = model1;
        _model2 = model2;

        [model1 lc_addObserver:self
                    forKeyPath:@"name"
                       options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                       context:nil
                     withBlock:^(NSDictionary<NSKeyValueChangeKey,id> *change, void *context) {
                         
            NSLog(@"model1> old = %@, new = %@", change[NSKeyValueChangeOldKey], change[NSKeyValueChangeNewKey]);
        }];
        [model2 lc_addObserver:self
                    forKeyPath:@"name"
                       options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                       context:nil
                     withBlock:^(NSDictionary<NSKeyValueChangeKey,id> *change, void *context) {
                         
            NSLog(@"model2> old = %@, new = %@", change[NSKeyValueChangeOldKey], change[NSKeyValueChangeNewKey]);
        }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Pushed";
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _model1.name = [NSString stringWithFormat:@"aa%@", _model1.name];
    _model2.name = [NSString stringWithFormat:@"hh%@", _model2.name];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

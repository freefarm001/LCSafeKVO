//
//  ViewController.m
//  LCSafeKVO
//
//  Created by lc on 2018/4/17.
//  Copyright © 2018年 liuchang. All rights reserved.
//

#import "ViewController.h"
#import "PushedViewController.h"
#import "Model.h"

@interface ViewController ()

@property (strong, nonatomic) Model *model1;
@property (strong, nonatomic) Model *model2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _model1 = [Model new];
    _model1.name = @"aa";
    
    _model2 = [Model new];
    _model2.name = @"hh";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *(^buttonBlock)(CGRect, UIColor *, NSString *, SEL) = ^(CGRect frame, UIColor *backgroundColor, NSString *title, SEL touchedSelector) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn addTarget:self action:touchedSelector forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = backgroundColor;
        btn.frame = frame;
        [btn setTitle:title forState:UIControlStateNormal];
        [self.view addSubview:btn];
        return btn;
    };
    
    UIButton *button1 = buttonBlock(CGRectMake(100, 100, 100, 100), [UIColor redColor], @"Push", @selector(btn1Clicked));
    [self.view addSubview:button1];
    
    UIButton *button2 = buttonBlock(CGRectMake(100, 300, 100, 100), [UIColor blueColor], @"change value", @selector(btn2Clicked));
    button2.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:button2];
}

- (void)btn1Clicked {
    PushedViewController *vc = [[PushedViewController alloc] initWithModel:_model1 andModel2:_model2];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)btn2Clicked {
    _model1.name = [NSString stringWithFormat:@"aa%@", _model1.name];
    _model2.name = [NSString stringWithFormat:@"hh%@", _model2.name];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

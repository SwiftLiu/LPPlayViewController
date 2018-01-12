//
//  ViewController.m
//  LPPlayViewController
//
//  Created by iOSLiu on 2018/1/9.
//  Copyright © 2018年 iOS_刘平. All rights reserved.
//

#import "ViewController.h"
#import "LPPlayViewController.h"

@interface ViewController ()<LPPlayViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    LPPlayViewController *pvc = [LPPlayViewController playControllerWithStyle:(LPPlayStyleNormal)];
    [self addChildViewController:pvc];
    pvc.view.frame = CGRectMake(0, 20, self.view.bounds.size.width, 220);
    [self.view addSubview:pvc.view];
    
    pvc.autoFullScreen = NO;
    pvc.delegate = self;
}

#pragma mark - <LPPlayViewControllerDelegate>协议实现
- (NSArray<NSString *> *)claritiesInPlayController:(LPPlayViewController *)playController {
    return @[@"高清"];
}

- (NSString *)playController:(LPPlayViewController *)playController urlWitClarityIndex:(NSInteger)index setIndex:(NSInteger)set {
    return @"http://www.w3school.com.cn/example/html5/mov_bbb.mp4";
}

@end

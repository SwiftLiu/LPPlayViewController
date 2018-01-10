//
//  LPPlayViewController.m
//  LPPlayViewController
//
//  Created by iOSLiu on 2018/1/9.
//  Copyright © 2018年 iOS_刘平. All rights reserved.
//

#import "LPPlayViewController.h"
#import "LPPlayControl.h"


@interface LPPlayViewController ()<LPPlayControlDelegate>
@property (strong, nonatomic) LPPlayControl *control;
@end

@implementation LPPlayViewController

+ (instancetype)viewControllerWithStyle:(LPPlayStyle)style {
    LPPlayViewController *vc = [[LPPlayViewController alloc] init];
    vc.control = [LPPlayControl controlViewWithStyle:(style)];
    [vc.view addSubview:vc.control];
    vc.control.delegate = vc;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.control.frame = self.control.superview.bounds;
}





#pragma mark - <LPPlayControlDelegate>协议实现
- (void)control:(LPPlayControl *)control didClickedFullScreenButton:(BOOL)fullScreen {
    if (fullScreen) {//全屏
        //移动到App主window上
        [self.control removeFromSuperview];
        __weak UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [window addSubview:self.control];
        CGSize size = window.bounds.size;
        self.control.frame = CGRectMake(0, 0, size.height, size.width);
        self.control.center = CGPointMake(size.width/2.0f, size.height/2.0f);
        
        
        //动画
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            weakSelf.control.transform = CGAffineTransformMakeRotation(M_PI_2);
        } completion:^(BOOL finished) {
            _fullScreen = YES;
        }];
    }
    else {//竖屏
        //移动到根视图self.view上
        [self.control removeFromSuperview];
        [self.view addSubview:self.control];
        
        //动画
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            weakSelf.control.transform = CGAffineTransformMakeRotation(0);
        } completion:^(BOOL finished) {
            _fullScreen = NO;
        }];
        self.control.frame = self.view.bounds;
    }
}

@end

//
//  LPPlayViewController.m
//  LPPlayViewController
//
//  Created by iOSLiu on 2018/1/9.
//  Copyright © 2018年 iOS_刘平. All rights reserved.
//

#import "LPPlayViewController.h"
#import "LPPlayControl.h"
#import "UIViewController+LPPlayerRotation.h"

@interface LPPlayViewController ()<LPPlayControlDelegate>
@property (strong, nonatomic) LPPlayControl *control;
@property (strong, nonatomic) UIView *fullScreenBgView;//全屏时背景图层
@end

@interface LPPlayViewController ()
@property (assign, nonatomic, readonly) UIStatusBarStyle statusBarStyle;//状态栏初始风格
@property (assign, nonatomic, readonly) BOOL statusBarHidden;//状态栏初始状态
@property (assign, nonatomic, readonly) UIDeviceOrientation orientation;//屏幕方向
@end



@implementation LPPlayViewController

+ (instancetype)viewControllerWithStyle:(LPPlayStyle)style {
    LPPlayViewController *vc = [[LPPlayViewController alloc] init];
    vc.control = [LPPlayControl controlViewWithStyle:(style)];
    [vc.view addSubview:vc.control];
    vc.control.delegate = vc;
    vc.control.totalTime = 2000;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    //设备默认方向
    _orientation = UIDeviceOrientationPortrait;
    //状态栏初始风格
    _statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    _statusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    
    //开始监听转屏
    [self addNotifications];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.control.frame = self.control.superview.bounds;
}


- (void)dealloc {
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //停止监测设备方向
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    //销毁控制层
    [self.control removeFromSuperview];
    self.control = nil;
}


- (UIView *)fullScreenBgView {
    if (!_fullScreenBgView) {
        __weak UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        _fullScreenBgView = [[UIView alloc] initWithFrame:window.bounds];
        _fullScreenBgView.backgroundColor = [UIColor blackColor];
        [window addSubview:_fullScreenBgView];
    }
    return _fullScreenBgView;
}




#pragma mark - ------------------------ 转屏相关 --------------------------
//MARK: 开始监听设备方向旋转
- (void)addNotifications {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];//监测设备方向
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

//MARK: 设备方向改变时
- (void)onDeviceOrientationChange {
    UIDeviceOrientation deviceOri = [UIDevice currentDevice].orientation;//设备方向
    if (_orientation == deviceOri) { return; }
    if (UIDeviceOrientationIsLandscape(deviceOri)) {
        _orientation = deviceOri;
        [self beFullScreenToLeft:deviceOri==UIDeviceOrientationLandscapeLeft];//横屏
        self.control.fullScreen = YES;
    }
    else if (UIDeviceOrientationIsPortrait(deviceOri) && !UIDeviceOrientationIsPortrait(_orientation)) {
        _orientation = deviceOri;
        [self bePortraitScreen];//竖屏
        self.control.fullScreen = NO;
    }
}

//MARK: 全屏
- (void)beFullScreenToLeft:(BOOL)left {
    //状态栏
    UIApplication *application = [UIApplication sharedApplication];
    if (left) {
        [application setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
    }else {
        [application setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
    }
    [application setStatusBarStyle:(UIStatusBarStyleLightContent) animated:YES];
    [application setStatusBarHidden:self.control.barHidden animated:NO];
    
    //控制层和渲染层移动到App主window上
    UIView *bgView = self.control.superview;
    if (bgView != self.fullScreenBgView) {
        [self.control removeFromSuperview];
        [self.fullScreenBgView addSubview:self.control];
    }
    
    //动画
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        weakSelf.control.transform = CGAffineTransformMakeRotation(left?M_PI_2:-M_PI_2);
    } completion:^(BOOL finished) {
        if (finished) {
            _isFullScreen = YES;
        }
    }];
}

//MARK: 竖直屏幕
- (void)bePortraitScreen {
    //状态栏
    UIApplication *application = [UIApplication sharedApplication];
    [application setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    [application setStatusBarStyle:self.statusBarStyle animated:YES];
    [application setStatusBarHidden:self.statusBarHidden animated:YES];
    
    //控制层和渲染层移动到根视图self.view上
    UIView *bgView = self.control.superview;
    if (bgView == self.view) { return; }
    [self.control removeFromSuperview];
    [self.view addSubview:self.control];
    [bgView removeFromSuperview];
    self.fullScreenBgView = nil;
    
    //动画
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        weakSelf.control.transform = CGAffineTransformMakeRotation(0);
    } completion:^(BOOL finished) {
        if (finished) {
            _isFullScreen = NO;
        }
    }];
}




#pragma mark - <LPPlayControlDelegate>协议实现
- (void)control:(LPPlayControl *)control didClickedFullScreenButton:(BOOL)fullScreen {
    if (fullScreen) {//全屏
        [self beFullScreenToLeft:YES];
    } else {//竖屏
        [self bePortraitScreen];
    }
}

- (void)control:(LPPlayControl *)control barsWillBeHidden:(BOOL)hidden {
    if (self.isFullScreen && hidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:hidden animated:YES];
    }
}

- (void)control:(LPPlayControl *)control barsDidBeHidden:(BOOL)hidden {
    if (self.isFullScreen && !hidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:hidden animated:YES];
    }
}

@end

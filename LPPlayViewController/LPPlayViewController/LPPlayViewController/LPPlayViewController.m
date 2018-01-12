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
#import "PLPlayerKit.h"

@interface LPPlayViewController ()<LPPlayControlDelegate, PLPlayerDelegate>
@property (strong, nonatomic) PLPlayer *player;
@property (strong, nonatomic) LPPlayControl *control;
@property (strong, nonatomic) UIView *fullScreenBgView;//全屏时背景图层
@end

@interface LPPlayViewController ()
@property (assign, nonatomic, readonly) UIDeviceOrientation orientation;//屏幕方向

@property (assign, nonatomic, readonly) UIStatusBarStyle statusBarOriginStyle;//状态栏初始风格
@property (assign, nonatomic, readonly) BOOL statusBarOriginHidden;//状态栏初始状态
@property (assign, nonatomic, readonly) CGFloat screenOriginBrightness;//屏幕初始亮度
@end



@implementation LPPlayViewController

- (void)dealloc {
    //屏幕亮度恢复到初始亮度
    [UIScreen mainScreen].brightness = self.screenOriginBrightness;
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //停止监测设备方向
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    //销毁控制层
    [self.control removeFromSuperview];
    self.control = nil;
    //销毁播放器
    [self.player stop];
    [self.player.playerView removeFromSuperview];
    self.player = nil;
}

+ (instancetype)playControllerWithStyle:(LPPlayStyle)style {
    LPPlayViewController *vc = [[LPPlayViewController alloc] init];
    [vc setStyle:style];
    return vc;
}

- (void)setStyle:(LPPlayStyle)style {
    _style = style;
    
    //控制图层
    self.control = [LPPlayControl controlViewWithStyle:(style)];
    [self.view addSubview:self.control];
    self.control.delegate = self;
    self.control.totalTime = 2000;
    
    //播放器
    PLPlayerOption *option = [PLPlayerOption defaultOption];
    [option setOptionValue:@10 forKey:PLPlayerOptionKeyTimeoutIntervalForMediaPackets];
    if (style == LPPlayStyleLive) {//直播播放器
        self.player = [PLPlayer playerLiveWithURL:nil option:option];
    }else {//点播播放器
        self.player = [PLPlayer playerWithURL:nil option:option];
    }
    self.player.delegate = self;
    self.player.delegateQueue = dispatch_get_main_queue();
    self.player.backgroundPlayEnable = YES;
    if (self.player.status == PLPlayerStatusError) { return; }
    UIView *playerView = self.player.playerView;
    if (!playerView.superview) {
        playerView.contentMode = UIViewContentModeScaleAspectFit;
        playerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin
        | UIViewAutoresizingFlexibleTopMargin
        | UIViewAutoresizingFlexibleLeftMargin
        | UIViewAutoresizingFlexibleRightMargin
        | UIViewAutoresizingFlexibleWidth
        | UIViewAutoresizingFlexibleHeight;
        [self.control insertSubview:playerView atIndex:0];
    }
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    //设备默认方向
    _orientation = UIDeviceOrientationPortrait;
    //状态栏初始风格
    _statusBarOriginStyle = [UIApplication sharedApplication].statusBarStyle;
    _statusBarOriginHidden = [UIApplication sharedApplication].statusBarHidden;
    //屏幕初始亮度
    _screenOriginBrightness = [UIScreen mainScreen].brightness;
    
    //开始监听转屏
    [self addNotifications];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.control.frame = self.control.superview.bounds;
    self.player.playerView.frame = self.control.bounds;
}





#pragma mark - ------------------------ Setter & Getter --------------------------
//全屏背景图层
- (UIView *)fullScreenBgView {
    if (!_fullScreenBgView) {
        __weak UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        _fullScreenBgView = [[UIView alloc] initWithFrame:window.bounds];
        _fullScreenBgView.backgroundColor = [UIColor blackColor];
        [window addSubview:_fullScreenBgView];
    }
    return _fullScreenBgView;
}


#pragma mark - ------------------------ 外部方法 --------------------------
//MARK: 刷新播放器
- (void)reloadData {
    if (!self.delegate) { return; }
    //清晰度
    self.control.clarityNames = [self.delegate claritiesInPlayController:self];
    //播放地址
    NSString *url = [self.delegate playController:self urlOfClarityAtIndex:self.control.selectedClarityIndex];
    if ([_url isEqualToString:url]) { return; }
    _url = url;
    NSURL *URL = [NSURL URLWithString:url?:@""];
    [self.player playWithURL:URL sameSource:NO];
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
        [self becomeFullScreenToLeft:deviceOri==UIDeviceOrientationLandscapeLeft];//横屏
        self.control.fullScreen = YES;
    }
    else if (UIDeviceOrientationIsPortrait(deviceOri) && !UIDeviceOrientationIsPortrait(_orientation)) {
        _orientation = deviceOri;
        [self becomePortraitScreen];//竖屏
        self.control.fullScreen = NO;
    }
}

//MARK: 全屏
- (void)becomeFullScreenToLeft:(BOOL)left {
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
- (void)becomePortraitScreen {
    //状态栏
    UIApplication *application = [UIApplication sharedApplication];
    [application setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    [application setStatusBarStyle:self.statusBarOriginStyle animated:YES];
    [application setStatusBarHidden:self.statusBarOriginHidden animated:YES];
    
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






#pragma mark - <PLPlayerDelegate>协议实现






#pragma mark - <LPPlayControlDelegate>协议实现
- (void)control:(LPPlayControl *)control didClickedFullScreenButton:(BOOL)fullScreen {
    if (fullScreen) {//全屏
        [self becomeFullScreenToLeft:YES];
    } else {//竖屏
        [self becomePortraitScreen];
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

- (void)controlDidClickedBackButton:(LPPlayControl *)control {
    if (self.delegate && [self.delegate respondsToSelector:@selector(playControllerDidClickedBackButton:)]) {
        [self.delegate playControllerDidClickedBackButton:self];
    }
}

@end

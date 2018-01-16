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
@property (assign, nonatomic, readonly) BOOL isPlayingResignFocus;//失去焦点前播放暂停状态
@property (assign, nonatomic, readonly) BOOL isAutoFullScreenResignFocus;//失去焦点前是否自动全屏模式

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
    //默认设置
    [vc setStyle:style];
    //默认转屏模式
    vc.autoFullScreen = YES;
    //默认选中选集
    vc.selectedSetIndex = 0;
    return vc;
}

- (void)setStyle:(LPPlayStyle)style {
    _style = style;
    
    //控制图层
    self.control = [LPPlayControl controlViewWithStyle:(style)];
    [self.view addSubview:self.control];
    self.control.delegate = self;
    
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
    playerView.contentMode = UIViewContentModeScaleAspectFit;
    playerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleHeight;
    [self.control insertSubview:playerView atIndex:0];
    
    //防止打开静音按钮后播放无声音的BUG
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    //设备默认方向
    _orientation = [UIDevice currentDevice].orientation;;
    //状态栏初始风格
    _statusBarOriginStyle = [UIApplication sharedApplication].statusBarStyle;
    _statusBarOriginHidden = [UIApplication sharedApplication].statusBarHidden;
    //屏幕初始亮度
    _screenOriginBrightness = [UIScreen mainScreen].brightness;
    
    // app成为焦点
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeFocusController) name:UIApplicationDidBecomeActiveNotification object:nil];
    // app失去焦点
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignFocusController) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.control.frame = self.control.superview.bounds;
    self.player.playerView.frame = self.control.bounds;
}


#pragma mark - ------------------------ 焦点切换 --------------------------
//MARK: 本页面成为焦点
- (void)becomeFocusController {
    if (self.isPlayingResignFocus) {
        [self.player resume];
        self.control.playing = YES;
    }
    
    if (self.isPlayingResignFocus) {
        self.autoFullScreen = YES;
    }
}


//MARK: 本页面失去焦点
- (void)resignFocusController {
    _isPlayingResignFocus = self.player.isPlaying;
    [self.player pause];
    self.control.playing = NO;
    
    _isAutoFullScreenResignFocus = self.autoFullScreen;
    self.autoFullScreen = NO;
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

//MARK: 是否自动全屏
- (void)setAutoFullScreen:(BOOL)autoFullScreen {
    if (_autoFullScreen == autoFullScreen) { return; }
    _autoFullScreen = autoFullScreen;
    if (autoFullScreen) {
        //开始监测设备方向
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    }else {
        //停止监测设备方向
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    }
}

//MARK: 代理
- (void)setDelegate:(id<LPPlayViewControllerDelegate>)delegate {
    _delegate = delegate;
    self.selectedSetIndex = _selectedSetIndex;
}


//MARK: 播放选集
- (void)setSelectedSetIndex:(NSInteger)selectedSetIndex {
    //总集数
    NSInteger totalSets = [self.delegate numberOfSetsInPlayController:self];
    if (selectedSetIndex > MAX(totalSets-1, 0)) { return; }
    _selectedSetIndex = selectedSetIndex;
    if (!self.delegate) { return; }
    //清晰度名称
    self.control.clarityNames = [self.delegate claritiesInPlayController:self];
    //播放地址
    [self playUrlAtSet:_selectedSetIndex];
    //视频名称
    self.control.title = [self.delegate playController:self titleInSet:_selectedSetIndex];
    //即将播放的视频名称
    NSInteger willIndex = _selectedSetIndex + 1;
    if (willIndex < totalSets) {
        self.control.willPlayTitle = [self.delegate playController:self titleInSet:willIndex];
    }
}


//MARK: 设置http header referer 值
- (void)setReferer:(NSString *)referer {
    NSCharacterSet *charSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *value = [referer stringByAddingPercentEncodingWithAllowedCharacters:charSet];
    self.player.referer = value;
}






#pragma mark - ------------------------ 转屏相关 --------------------------
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






#pragma mark - ------------------------ 播放器 --------------------------
//MARK: 播放新视频
- (void)playUrlAtSet:(NSInteger)set {
    NSInteger index = self.control.selectedClarityIndex;
    index = MIN(index, self.control.clarityNames.count-1);
    index = MAX(index, 0);
    NSString *url = [self.delegate playController:self urlOfClarityAtIndex:index inSet:set];
    //encode解码
    url = [url stringByRemovingPercentEncoding];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    if ([_url isEqualToString:url]) { return; }
    _url = url;
    NSURL *URL = [NSURL URLWithString:url?:@""];
    //播放
    [self.player playWithURL:URL sameSource:NO];
}

//MARK: 开始监听播放时间
- (void)startObservingPlayedTime {
    if (self.style == LPPlayStyleLive) { return; }
    self.control.playingTime = CMTimeGetSeconds(self.player.currentTime);
    [self performSelector:@selector(startObservingPlayedTime) withObject:nil afterDelay:.5];
}

//MARK: 停止播放时间监听
- (void)stopObservingPlayedTime {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startObservingPlayedTime) object:nil];
}


//MARK: 开始监听下载速度
- (void)startObservingLoadSpeed {
    if (self.style == LPPlayStyleLive) { return; }
    [self.control.loader loadingWithSpeed:self.player.downSpeed];
    [self performSelector:@selector(startObservingLoadSpeed) withObject:nil afterDelay:.5];
}

//MARK: 停止下载速度监听
- (void)stopObservingLoadSpeed {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startObservingLoadSpeed) object:nil];
}




#pragma mark - <PLPlayerDelegate>协议实现
- (void)player:(PLPlayer *)player statusDidChange:(PLPlayerStatus)state {
    switch (state) {
        case PLPlayerStatusPreparing: {
            NSLog(@"状态：PLPlayerStatusPreparing");
            [self startObservingLoadSpeed];
        }
            break;
        case PLPlayerStatusReady: {
            NSLog(@"状态：PLPlayerStatusReady");
            CMTime time = self.player.totalDuration;
            self.control.totalTime = CMTimeGetSeconds(time);
            [self startObservingPlayedTime];
        }
            break;
        case PLPlayerStatusCaching: {
            NSLog(@"状态：PLPlayerStatusCaching");
            [self startObservingLoadSpeed];;
        }
            break;
        case PLPlayerStatusPlaying: {
            NSLog(@"状态：PLPlayerStatusPlaying");
            self.control.playing = YES;
            [self stopObservingLoadSpeed];
            [self.control.loader endLoading];
        }
            break;
        case PLPlayerStatusPaused: {
            NSLog(@"状态：PLPlayerStatusPaused");
            [self stopObservingPlayedTime];
        }
            break;
        case PLPlayerStatusError: {
            NSLog(@"状态：PLPlayerStatusError");
            self.control.playing = NO;
        }
            break;
        case PLPlayerStateAutoReconnecting: {
            NSLog(@"状态：PLPlayerStateAutoReconnecting");
        }
            break;
        case PLPlayerStatusStopped: {
            NSLog(@"状态：PLPlayerStatusStopped");
            [self stopObservingPlayedTime];
            [self.control reset];
            self.selectedSetIndex ++;
        }
            break;
        case PLPlayerStatusCompleted: {
            NSLog(@"状态：PLPlayerStatusCompleted");
            [self stopObservingPlayedTime];
            [self.control reset];
            self.selectedSetIndex ++;
        }
            break;
        default:{
            NSLog(@"状态：PLPlayerStatusUnknow");
        }
            break;
    }
}

- (void)player:(PLPlayer *)player stoppedWithError:(NSError *)error {
    NSString *meesage = [@"播放出错" stringByAppendingFormat:@" %ld", error.code];
    [self stopObservingLoadSpeed];
    [self.control.loader showError:meesage];
}






#pragma mark - <LPPlayControlDelegate>协议实现
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

- (void)control:(LPPlayControl *)control didClickedFullScreenButton:(BOOL)fullScreen {
    if (fullScreen) {//全屏
        BOOL left = [UIDevice currentDevice].orientation != UIDeviceOrientationLandscapeRight;
        [self becomeFullScreenToLeft:left];
    } else {//竖屏
        [self becomePortraitScreen];
    }
}

- (void)controlDidClickedBackButton:(LPPlayControl *)control {
    if (self.delegate && [self.delegate respondsToSelector:@selector(playControllerDidClickedBackButton:)]) {
        [self.delegate playControllerDidClickedBackButton:self];
    }
}

- (void)control:(LPPlayControl *)control didSelectedSourceAtIndex:(NSInteger)index {
    [self playUrlAtSet:self.selectedSetIndex];
}

- (void)control:(LPPlayControl *)control didClickedPlayButtonWillPlaying:(BOOL)playing {
    if (playing) {
        [self.player resume];
        [self startObservingPlayedTime];
    }else {
        [self.player pause];
        [self stopObservingPlayedTime];
    }
}

- (void)control:(LPPlayControl *)control beganSeekedFromTime:(NSTimeInterval)time {
    [self stopObservingPlayedTime];
}

- (void)control:(LPPlayControl *)control didSeekedToTime:(NSTimeInterval)time {
    [self.player seekTo:CMTimeMake(time+.9999, 1)];
    [self startObservingPlayedTime];
}

@end


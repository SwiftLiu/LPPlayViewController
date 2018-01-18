//
//  LPPlayControl.m
//  LPPlayControlView
//
//  Created by iOSLiu on 2018/1/5.
//  Copyright © 2018年 iOS_刘平. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "LPPlayControl.h"
#import "LPPlayGestureView.h"


@interface LPPlayControl ()<LPPlayProgressBarDelegate, LPPlayGestureViewDelegate>
//手势层
@property (weak, nonatomic) IBOutlet LPPlayGestureView *gestureView;
//返回按钮
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backButtonTopConstraint;
//即将播放的视频标题
@property (weak, nonatomic) IBOutlet UILabel *willPlayLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *willPlayLabelTopConstraint;

//右边控制栏
@property (weak, nonatomic) IBOutlet UIView *rightBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstRightButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondRightButtonHeightConstraint;

//顶部控制栏
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topBarTopMarginConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topBarTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *topBarBgImgView;
@property (weak, nonatomic) IBOutlet UIButton *topBackButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *firstTopButton;
@property (weak, nonatomic) IBOutlet UIButton *secondTopButton;

//底部控制栏
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBarBottomConstraint;
@property (weak, nonatomic) IBOutlet LPPlayProgressBar *progressBar;
@property (weak, nonatomic) IBOutlet UIImageView *bottomBgImgView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *clarityButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *clarityButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *episodeButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fullscreenButtonWidthConstraint;


@end


@interface LPPlayControl ()
//音量调节
@property (strong, nonatomic) UISlider *volumeSlider;
@end


@implementation LPPlayControl

+ (instancetype)controlViewWithStyle:(LPPlayStyle)style {
    NSArray *controls = [NSBundle.mainBundle loadNibNamed:@"LPPlayControls" owner:nil options:nil];
    switch (style) {
        case LPPlayStyleNormal: {
            LPPlayControl *ctrl = [controls objectAtIndex:0];
            return ctrl;
        }
        case LPPlayStyleLive: {
            LPPlayControl *ctrl = [controls objectAtIndex:2];
            return ctrl;
        }
        default: {
            LPPlayControl *ctrl = [controls objectAtIndex:1];
            return ctrl;
        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.userInteractionEnabled = YES;
    self.clipsToBounds = YES;
    
    //手势层代理
    self.gestureView.delegate = self;
    
    //进度条
    self.progressBar.delegate = self;
    self.progressBar.hoursHidden = YES;
    self.progressBar.thumbImage = [UIImage imageNamed:@"LPPlayer_slider"];
    
    //暂停状态
    self.playing = NO;
    
    //竖屏模式
    [self becomeFullScreen:NO];
    
    //顶部空白预留
    self.statusBarMargin = NO;
    
    //控制栏默认显示状态
    _barHidden = NO;
}


#pragma mark - ------------------------ Setter & Getter --------------------------
//播放状态
- (void)setPlaying:(BOOL)playing {
    _playing = playing;
    self.playButton.selected = playing;
}

//全屏或竖屏模式
- (void)setFullScreen:(BOOL)fullScreen {
    if (_fullScreen == fullScreen) { return; }
    [self autoHideBarIfNeed];
    _fullScreen = fullScreen;
    [self becomeFullScreen:fullScreen];
}

//竖屏时是否需要控制栏顶部预留20pt高度
- (void)setStatusBarMargin:(BOOL)statusBarMargin {
    _statusBarMargin = statusBarMargin;
    self.backButtonTopConstraint.constant = statusBarMargin?20:0;
    self.topBarTopMarginConstraint.constant = statusBarMargin?20:0;
}

//视频名称
- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

//即将播放的视频名称
- (void)setWillPlayTitle:(NSString *)willPlayTitle {
    if (_willPlayTitle==nil && willPlayTitle==nil) { return; }
    _willPlayTitle = willPlayTitle;
    self.willPlayLabel.text = [NSString stringWithFormat:@"即将播放：%@", willPlayTitle?:@""];
    //提示即将播放
    if (_willPlayTitle && _willPlayTitle.length) {
        if (self.fullScreen) {
            [self hideBarsAnimation];//全屏模式下隐藏控制栏
        }
        //动画
        self.willPlayLabelTopConstraint.constant = (self.statusBarMargin || self.fullScreen) ? 20 : 0;
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            [self layoutIfNeeded];
        }];
    }
    //隐藏即将播放
    else {
        self.willPlayLabelTopConstraint.constant = -self.willPlayLabel.bounds.size.height;
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            [self layoutIfNeeded];
        }];
    }
}

//清晰度名称
- (void)setClarityNames:(NSArray<NSString *> *)clarityNames {
    _clarityNames = clarityNames;
    self.selectedClarityIndex = _selectedClarityIndex;
    if (self.isFullScreen) {
        self.clarityButtonWidthConstraint.constant = clarityNames.count?LPPLAYER_WIDTH:0;
    }
}

//选中的清晰度
- (void)setSelectedClarityIndex:(NSInteger)selectedClarityIndex {
    _selectedClarityIndex = selectedClarityIndex;
    if (!self.clarityNames.count) { return; }
    NSString *title = [self.clarityNames objectAtIndex:selectedClarityIndex];
    [self.clarityButton setTitle:title forState:(UIControlStateNormal)];
}



//正在播放时间（单位：秒）
- (void)setPlayingTime:(NSTimeInterval)playingTime {
    if (self.gestureView.isSlidingProgress) { return; }
    //进度条播放时间
    self.progressBar.playingTime = playingTime;
}
- (NSTimeInterval)playingTime {
    return self.progressBar.playingTime;
}

//缓存的时间（单位：秒）
- (void)setLoadingTime:(NSTimeInterval)loadingTime {
    self.progressBar.loadingTime = loadingTime;
}
- (NSTimeInterval)loadingTime {
    return self.progressBar.loadingTime;
}

//总时间（单位：秒）
- (void)setTotalTime:(NSTimeInterval)totalTime {
    self.progressBar.totalTime = totalTime;
}
- (NSTimeInterval)totalTime {
    return self.progressBar.totalTime;
}


//音量调节滑块Getter
- (UISlider *)volumeSlider {
    if (!_volumeSlider) {
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        for (UIView *view in [volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                _volumeSlider = (UISlider *)view;
                break;
            }
        }
    }
    return _volumeSlider;
}

//指示器
- (LPPlayLoader *)loader {
    if (!_loader) {
        LPPlayLoader *loader = [LPPlayLoader loader];
        loader.frame = self.bounds;
        [self insertSubview:loader atIndex:1];
        _loader = loader;
    }
    return _loader;
}





#pragma mark - ------------------------ 界面布局 --------------------------
//MARK: 重置
- (void)reset {
    self.willPlayTitle = nil;
    self.willPlayLabel.alpha = 0;
    self.playing = NO;
    self.playingTime = 0;
    self.loadingTime = 0;
}

//MARK: 全屏或竖屏模式
- (void)becomeFullScreen:(BOOL)fullScreen {
    if (fullScreen) {
        //全屏布局
        self.backButton.hidden = YES;
        self.rightBar.hidden = NO;
        self.topBackButton.hidden = NO;
        self.titleLabel.hidden = NO;
        self.secondTopButton.hidden = NO;
        self.topBarTopMarginConstraint.constant = 20;
        self.clarityButtonWidthConstraint.constant = self.clarityNames.count?LPPLAYER_WIDTH:0;
        self.episodeButtonWidthConstraint.constant = LPPLAYER_WIDTH;
        self.fullscreenButtonWidthConstraint.constant = 0;
    }
    else {
        //竖屏布局
        self.backButton.hidden = NO;
        self.rightBar.hidden = YES;
        self.topBackButton.hidden = YES;
        self.titleLabel.hidden = YES;
        self.secondTopButton.hidden = YES;
        self.topBarTopMarginConstraint.constant = self.statusBarMargin?20:0;
        self.clarityButtonWidthConstraint.constant = 0;
        self.episodeButtonWidthConstraint.constant = 0;
        self.fullscreenButtonWidthConstraint.constant = LPPLAYER_WIDTH;
    }
}


//MARK: 弹出制栏动画
- (void)showBarsAnimation {
    //移除动画
    [self cancelAutoHideBar];
    [self.rightBar.layer  removeAllAnimations];
    [self.topBar.layer    removeAllAnimations];
    [self.bottomBar.layer removeAllAnimations];
    
    //动画结束执行
    __weak typeof(self) weakSelf = self;
    typedef void(^AnimationCompleted)(BOOL);
    AnimationCompleted handler = ^(BOOL finished) {
        if (finished) {
            _barHidden = NO;
            //延时隐藏控制栏
            [weakSelf autoHideBarIfNeed];
            //代理回调
            if (self.delegate && [self.delegate respondsToSelector:@selector(control:barsDidBeHidden:)]) {
                [self.delegate control:self barsDidBeHidden:NO];
            }
        }
    };
    
    //动画
    if (_fullScreen) {//①全屏模式（弹出动画）
        self.topBar.alpha    = 1;
        self.bottomBar.alpha = 1;
        self.topBarTopConstraint.constant = 0;
        self.bottomBarBottomConstraint.constant = 0;
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            [weakSelf layoutIfNeeded];
            weakSelf.rightBar.alpha = 1;
        } completion:handler];
    }
    else {//②竖屏模式（渐显动画）
        self.topBarTopConstraint.constant = 0;
        self.bottomBarBottomConstraint.constant = 0;
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            weakSelf.rightBar.alpha  = 1;
            weakSelf.topBar.alpha    = 1;
            weakSelf.bottomBar.alpha = 1;
        } completion:handler];
    }
    
    //代理回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(control:barsWillBeHidden:)]) {
        [self.delegate control:self barsWillBeHidden:YES];
    }
}

//MARK: 隐藏控制栏动画
- (void)hideBarsAnimation {
    //移除动画
    [self cancelAutoHideBar];
    [self.rightBar.layer  removeAllAnimations];
    [self.topBar.layer    removeAllAnimations];
    [self.bottomBar.layer removeAllAnimations];
    
    //动画结束执行
    __weak typeof(self) weakSelf = self;
    typedef void(^AnimationCompleted)(BOOL);
    AnimationCompleted handler = ^(BOOL finished) {
        if (finished) {
            _barHidden = YES;
            //延时隐藏控制栏
            [weakSelf autoHideBarIfNeed];
            //代理回调
            if (self.delegate && [self.delegate respondsToSelector:@selector(control:barsDidBeHidden:)]) {
                [self.delegate control:self barsDidBeHidden:YES];
            }
        }
    };
    
    //动画
    if (_fullScreen) {//①全屏模式（弹出动画）
        self.topBar.alpha    = 1;
        self.bottomBar.alpha = 1;
        self.topBarTopConstraint.constant = -self.topBar.bounds.size.height;
        self.bottomBarBottomConstraint.constant = self.bottomBar.bounds.size.height;
        [UIView animateWithDuration:ANIMATION_DURATION+.2f animations:^{
            [weakSelf layoutIfNeeded];
            weakSelf.rightBar.alpha = 0;
        } completion:handler];
    }
    else {//②竖屏模式（渐隐动画）
        self.topBarTopConstraint.constant = 0;
        self.bottomBarBottomConstraint.constant = 0;
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            weakSelf.rightBar.alpha  = 0;
            weakSelf.topBar.alpha    = 0;
            weakSelf.bottomBar.alpha = 0;
        } completion:handler];
    }
    
    //代理回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(control:barsWillBeHidden:)]) {
        [self.delegate control:self barsWillBeHidden:YES];
    }
}

//延时隐藏控制栏
- (void)autoHideBarIfNeed {
    if (!_barHidden) {
        [self cancelAutoHideBar];
        [self performSelector:@selector(hideBarsAnimation) withObject:nil afterDelay:5];
    }
}

//取消延时隐藏控制栏
- (void)cancelAutoHideBar {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideBarsAnimation) object:nil];
}





#pragma mark - ------------------------ 用户交互 --------------------------
//MARK: 点击播放暂停按钮
- (IBAction)playButtonPressed:(UIButton *)sender {
    //延时隐藏控制栏
    [self autoHideBarIfNeed];
    //播放状态
    self.playing = !sender.selected;
    //代理
    if (self.delegate && [self.delegate respondsToSelector:@selector(control:didClickedPlayButtonWillPlaying:)]) {
        [self.delegate control:self didClickedPlayButtonWillPlaying:self.isPlaying];
    }
}

//MARK: 点击全屏按钮
- (IBAction)fullScreenButtonPressed:(UIButton *)sender {
    //延时隐藏控制栏
    [self autoHideBarIfNeed];
    //全屏
    self.fullScreen = YES;
    //代理
    if (self.delegate && [self.delegate respondsToSelector:@selector(control:didClickedFullScreenButton:)]) {
        [self.delegate control:self didClickedFullScreenButton:YES];
    }
}

//MARK: 点击选集按钮
- (IBAction)episodeButtonPressed:(UIButton *)sender {
    //隐藏控制栏
    [self hideBarsAnimation];
    //弹出选集框
    //MARK: NeedDo <<<<<<<<<<<<<<<<<<<<<<<<< 1 >>>>>>>>>>>>>>>>>>>>>>>>>
}

//MARK: 点击清晰度按钮
- (IBAction)clarityButtonPressed:(UIButton *)sender {
    //隐藏控制栏
    [self hideBarsAnimation];
    //弹出清晰度选择框
    //MARK: NeedDo <<<<<<<<<<<<<<<<<<<<<<<<< 2 >>>>>>>>>>>>>>>>>>>>>>>>>
}

//MARK: 全屏时点击返回按钮
- (IBAction)portraitScreenButtonPressed:(UIButton *)sender {
    //延时隐藏控制栏
    [self autoHideBarIfNeed];
    //全屏时变为竖屏
    self.fullScreen = NO;
    //代理
    if (self.delegate && [self.delegate respondsToSelector:@selector(control:didClickedFullScreenButton:)]) {
        [self.delegate control:self didClickedFullScreenButton:NO];
    }
}

//MARK: 点击返回按钮
- (IBAction)backButtonPressed:(UIButton *)sender {
    //取消延时隐藏控制栏
    [self cancelAutoHideBar];
    //代理
    if (self.delegate && [self.delegate respondsToSelector:@selector(controlDidClickedBackButton:)]) {
        [self.delegate controlDidClickedBackButton:self];
    }
}

//MARK: 点击顶部右边第一个按钮
- (IBAction)firstTopButtonPressed:(UIButton *)sender {
    //延时隐藏控制栏
    [self autoHideBarIfNeed];
    //弹出菜单框
    //MARK: NeedDo <<<<<<<<<<<<<<<<<<<<<<<<< 3 >>>>>>>>>>>>>>>>>>>>>>>>>
}

//MARK: 点击顶部右边第二个按钮
- (IBAction)secondTopButtonPressed:(UIButton *)sender {
    //延时隐藏控制栏
    [self autoHideBarIfNeed];
    //弹出分享框
    //MARK: NeedDo <<<<<<<<<<<<<<<<<<<<<<<<< 4 >>>>>>>>>>>>>>>>>>>>>>>>>
}





#pragma mark - <LPPlayProgressBarDelegate>协议实现
- (void)progressBar:(LPPlayProgressBar *)bar slidingBeganAtTime:(NSTimeInterval)time {
    //取消延时隐藏控制栏
    [self cancelAutoHideBar];
    //代理回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(control:beganSeekedFromTime:)]) {
        [self.delegate control:self beganSeekedFromTime:time];
    }
}

- (void)progressBar:(LPPlayProgressBar *)bar slidingMovedAtTime:(NSTimeInterval)time {
    //显示快进后退时间
    //MARK: NeedDo <<<<<<<<<<<<<<<<<<<<<<<<< 5 >>>>>>>>>>>>>>>>>>>>>>>>>
}

- (void)progressBar:(LPPlayProgressBar *)bar slidingEndedAtTime:(NSTimeInterval)time {
    //延时隐藏控制栏
    [self autoHideBarIfNeed];
    //代理回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(control:didSeekedToTime:)]) {
        [self.delegate control:self didSeekedToTime:time];
    }
}


#pragma mark - <LPPlayGestureViewDelegate>协议实现
- (void)gestureViewDidSigleTap:(LPPlayGestureView *)view {
    if (_barHidden) {
        [self showBarsAnimation];
    }else {
        [self hideBarsAnimation];
    }
}

- (void)gestureViewDidDoubleTap:(LPPlayGestureView *)view {
    //等同于点击播放按钮
    [self playButtonPressed:self.playButton];
}

- (void)gestureViewPanBegan:(LPPlayGestureView *)view {
    //取消延时隐藏控制栏
    [self cancelAutoHideBar];
}

- (void)gestureViewPanEnded:(LPPlayGestureView *)view {
    //延时隐藏控制栏
    [self autoHideBarIfNeed];
}

- (void)gestureView:(LPPlayGestureView *)view addY:(CGFloat)y left:(BOOL)left {
    CGFloat addedScale = y / (self.bounds.size.height*.62);
    if (left) {//亮度调节
        [UIScreen mainScreen].brightness += addedScale;
        //MARK: NeedDo <<<<<<<<<<<<<<<<<<<<<<<<< 7 >>>>>>>>>>>>>>>>>>>>>>>>>
    }
    else {//音量调节
        self.volumeSlider.value += addedScale;
    }
}

- (void)gestureView:(LPPlayGestureView *)view beganPanWithAddedX:(CGFloat)x {
    if (self.delegate && [self.delegate respondsToSelector:@selector(control:beganSeekedFromTime:)]) {
        [self.delegate control:self beganSeekedFromTime:self.playingTime];
    }
}

- (void)gestureView:(LPPlayGestureView *)view movedPanWithAddedX:(CGFloat)x {
    //进度条调节
    self.progressBar.playingTime += x/5.f;
    NSLog(@"左右调节：%.0lf----  %.0lf", x, self.progressBar.playingTime);
    //播放时间弹出层
    //MARK: NeedDo <<<<<<<<<<<<<<<<<<<<<<<<< 6 >>>>>>>>>>>>>>>>>>>>>>>>>
}

- (void)gestureView:(LPPlayGestureView *)view endedPanWithAddedX:(CGFloat)x {
    if (self.delegate && [self.delegate respondsToSelector:@selector(control:didSeekedToTime:)]) {
        [self.delegate control:self didSeekedToTime:self.playingTime];
    }
}
@end

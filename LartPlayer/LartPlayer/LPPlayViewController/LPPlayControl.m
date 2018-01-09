//
//  LPPlayControl.m
//  LPPlayControlView
//
//  Created by iOSLiu on 2018/1/5.
//  Copyright © 2018年 iOS_刘平. All rights reserved.
//

#import "LPPlayControl.h"
#import "LPProgressBar.h"
#import "LPGestureView.h"

#define LPPLAYER_WIDTH 45
#define ANIMATION_DURATION .3f

@interface LPPlayControl ()<LPProgressBarDelegate, LPGestureViewDelegate>
//手势层
@property (weak, nonatomic) IBOutlet LPGestureView *gestureView;

//右边控制栏
@property (weak, nonatomic) IBOutlet UIView *rightBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstRightButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondRightButtonHeightConstraint;


//顶部控制栏
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topBarTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *topBarBgImgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *firstTopButton;
@property (weak, nonatomic) IBOutlet UIButton *secondTopButton;

//底部控制栏
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBarBottomConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *bottomBgImgView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *clarityButton;
@property (weak, nonatomic) IBOutlet LPProgressBar *progressBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *clarityButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *episodeButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fullscreenButtonWidthConstraint;
@end


@interface LPPlayControl ()
{
    BOOL _barShow;//控制栏是否显示
}
@end


@implementation LPPlayControl

+ (instancetype)controlViewWithStyle:(LPPlayControlStyle)style {
    NSArray *controls = [NSBundle.mainBundle loadNibNamed:@"LPPlayControls" owner:nil options:nil];
    switch (style) {
        case LPPlayControlStyleNormal: {
            LPPlayControl *ctrl = [controls objectAtIndex:0];
            return ctrl;
        }
        case LPPlayControlStyleLive: {
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
    
    //手势代理
    self.gestureView.delegate = self;
    
    //进度条
    if (self.progressBar) {
        self.progressBar.delegate = self;
        self.progressBar.hoursHidden = YES;
        self.progressBar.thumbImage = [UIImage imageNamed:@"LPPlayer_slider"];
    }
    
    //默认竖屏模式
    self.fullScreen = NO;
    
    //控制栏默认显示状态
    _barShow = YES;
}

- (void)setFullScreen:(BOOL)fullScreen {
    _fullScreen = fullScreen;
    if (fullScreen) {
        //全屏布局
        self.rightBar.hidden = NO;
        self.topBarBgImgView.hidden = NO;
        self.bottomBgImgView.hidden = NO;
        self.titleLabel.hidden = NO;
        self.secondTopButton.hidden = NO;
        self.clarityButtonWidthConstraint.constant = LPPLAYER_WIDTH;
        self.episodeButtonWidthConstraint.constant = LPPLAYER_WIDTH;
        self.fullscreenButtonWidthConstraint.constant = 0;
    }
    else {
        //竖屏布局
        self.rightBar.hidden = YES;
        self.topBarBgImgView.hidden = YES;
        self.bottomBgImgView.hidden = YES;
        self.titleLabel.hidden = YES;
        self.secondTopButton.hidden = YES;
        self.clarityButtonWidthConstraint.constant = 0;
        self.episodeButtonWidthConstraint.constant = 0;
        self.fullscreenButtonWidthConstraint.constant = LPPLAYER_WIDTH;
    }
}




#pragma mark - ------------------------ 界面布局 --------------------------
//MARK: 弹出制栏动画
- (void)showBarsAnimation {
    //取消自动隐藏
    [self cancelAutoHideBar];
    //移除动画
    [self.rightBar.layer  removeAllAnimations];
    [self.topBar.layer    removeAllAnimations];
    [self.bottomBar.layer removeAllAnimations];
    
    //动画
    __weak typeof(self) weakSelf = self;
    if (_fullScreen) {//①全屏模式（弹出动画）
        self.topBar.alpha    = 1;
        self.bottomBar.alpha = 1;
        self.topBarTopConstraint.constant = 0;
        self.bottomBarBottomConstraint.constant = 0;
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            [weakSelf layoutIfNeeded];
            weakSelf.rightBar.alpha = 1;
        } completion:^(BOOL finished) {
            if (finished) {
                _barShow = YES;
                [weakSelf autoHideBar];//自动隐藏
            }
        }];
    }
    else {//②竖屏模式（渐显动画）
        self.topBarTopConstraint.constant = 0;
        self.bottomBarBottomConstraint.constant = 0;
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            weakSelf.rightBar.alpha  = 1;
            weakSelf.topBar.alpha    = 1;
            weakSelf.bottomBar.alpha = 1;
        } completion:^(BOOL finished) {
            if (finished) {
                _barShow = YES;
                [weakSelf autoHideBar];//自动隐藏
            }
        }];
    }
    
    //代理回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(control:barsDidHided:)]) {
        [self.delegate control:self barsDidHided:NO];
    }
}

//MARK: 隐藏控制栏动画
- (void)hideBarsAnimation {
    //取消自动隐藏
    [self cancelAutoHideBar];
    //移除动画
    [self.rightBar.layer  removeAllAnimations];
    [self.topBar.layer    removeAllAnimations];
    [self.bottomBar.layer removeAllAnimations];
    
    //动画
    __weak typeof(self) weakSelf = self;
    if (_fullScreen) {//①全屏模式（弹出动画）
        self.topBar.alpha    = 1;
        self.bottomBar.alpha = 1;
        self.topBarTopConstraint.constant = -self.topBar.bounds.size.height;
        self.bottomBarBottomConstraint.constant = self.bottomBar.bounds.size.height;
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            [weakSelf layoutIfNeeded];
            weakSelf.rightBar.alpha = 0;
        } completion:^(BOOL finished) {
            if (finished) {
                _barShow = NO;
            }
        }];
    }
    else {//②竖屏模式（渐隐动画）
        self.topBarTopConstraint.constant = 0;
        self.bottomBarBottomConstraint.constant = 0;
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            weakSelf.rightBar.alpha  = 0;
            weakSelf.topBar.alpha    = 0;
            weakSelf.bottomBar.alpha = 0;
        } completion:^(BOOL finished) {
            if (finished) {
                _barShow = NO;
            }
        }];
    }
    
    //代理回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(control:barsDidHided:)]) {
        [self.delegate control:self barsDidHided:YES];
    }
}

//自动隐藏
- (void)autoHideBar {
    [self performSelector:@selector(hideBarsAnimation) withObject:nil afterDelay:5];
}

//取消自动隐藏
- (void)cancelAutoHideBar {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideBarsAnimation) object:nil];
}






#pragma mark - ------------------------ 用户交互 --------------------------
//MARK: 点击播放暂停按钮
- (IBAction)playButtonPressed:(UIButton *)sender {
    
}

//MARK: 点击全屏按钮
- (IBAction)fullScreenButtonPressed:(UIButton *)sender {
    self.fullScreen = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(control:didClickedFullScreenButton:)]) {
        [self.delegate control:self didClickedFullScreenButton:YES];
    }
}

//MARK: 点击选集按钮
- (IBAction)episodeButtonPressed:(UIButton *)sender {
    
}

//MARK: 点击清晰度按钮
- (IBAction)clarityButtonPressed:(UIButton *)sender {
    
}

//MARK: 点击返回按钮
- (IBAction)portraitScreenButtonPressed:(UIButton *)sender {
    if (self.fullScreen) {
        //全屏时变为竖屏
        self.fullScreen = NO;
        if (self.delegate && [self.delegate respondsToSelector:@selector(control:didClickedFullScreenButton:)]) {
            [self.delegate control:self didClickedFullScreenButton:NO];
        }
    }
    else {
        //竖屏时返回
        if (self.delegate && [self.delegate respondsToSelector:@selector(controlDidClickedBackButton:)]) {
            [self.delegate controlDidClickedBackButton:self];
        }
    }
}

//MARK: 点击顶部右边第一个按钮
- (IBAction)firstTopButtonPressed:(UIButton *)sender {
}

//MARK: 点击顶部右边第二个按钮
- (IBAction)secondTopButtonPressed:(UIButton *)sender {
}





#pragma mark - <LPProgressBarDelegate>协议实现
- (void)progressBar:(LPProgressBar *)bar userDidSlidindAtTime:(NSTimeInterval)time {
    //显示快进后退时间
    
}

- (void)progressBar:(LPProgressBar *)bar userSlidedDidEndedAtTime:(NSTimeInterval)time {
    //快进、后退
    if (self.delegate && [self.delegate respondsToSelector:@selector(control:didSeekedToTime:)]) {
        [self.delegate control:self didSeekedToTime:time];
    }
}


#pragma mark - <LPGestureViewDelegate>协议实现
- (void)gestureViewDidSigleTap:(LPGestureView *)view {
    if (_barShow) {
        [self hideBarsAnimation];
    }else {
        [self showBarsAnimation];
    }
}

- (void)gestureViewDidDoubleTap:(LPGestureView *)view {
    
}

- (void)gestureView:(LPGestureView *)view panX:(CGFloat)x {
    NSLog(@"左右调节：%.0lf", x);
}

- (void)gestureView:(LPGestureView *)view panY:(CGFloat)y left:(BOOL)left {
    NSLog(@"上下调节-%@：%.0lf", left?@"左":@"右", y);
}

@end

//
//  LPProgressBar.m
//  LPProgressBar
//
//  Created by iOSLiu on 2018/1/3.
//  Copyright © 2018年 iOS_刘平. All rights reserved.
//

#import "LPProgressBar.h"

@interface LPProgressBar ()

@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewRightConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *thumbImgView;
@property (weak, nonatomic) IBOutlet UIImageView *playingImgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playingImgViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *loadingImgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loadingImgViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *totalImgView;

@property (weak, nonatomic) IBOutlet UILabel *playingLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;

@end



@implementation LPProgressBar
#pragma mark - ------------------------ 重写 --------------------------
- (void)awakeFromNib {
    [super awakeFromNib];
    UIView *view = [NSBundle.mainBundle loadNibNamed:@"LPProgressBar" owner:self options:nil].firstObject;
    view.frame = self.bounds;
    [self addSubview:view];
    
    //单击手势
    UITapGestureRecognizer *sigleTap = [[UITapGestureRecognizer alloc] init];
    sigleTap.numberOfTapsRequired = 1;
    [sigleTap addTarget:self action:@selector(sigleClicked:)];
    [self addGestureRecognizer:sigleTap];
    
    //滑动、拖拽
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] init];
    [pan addTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    
    self.totalTime = 0;
    self.fontSize = 9;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.frame.size.width - 2*self.progressViewLeftConstraint.constant;
    self.playingImgViewWidthConstraint.constant = w * _playingTime/_totalTime;
    self.loadingImgViewWidthConstraint.constant = w * _loadingTime/_totalTime;
}


#pragma mark - ------------------------ 配置 --------------------------
- (void)setHoursHidden:(BOOL)hoursHidden {
    _hoursHidden = hoursHidden;
    [self layoutProgressView];
    [self updateTimeLabel];
}

- (void)setRemainedTime:(BOOL)remainedTime {
    _remainedTime = remainedTime;
    [self updateTimeLabel];
}


- (void)setFontColor:(UIColor *)fontColor {
    self.playingLabel.textColor = fontColor?:[UIColor whiteColor];
    self.totalLabel.textColor = fontColor?:[UIColor whiteColor];
}

- (void)setFontSize:(CGFloat)fontSize {
    _fontSize = MAX(fontSize, 9);
    self.playingLabel.font = [UIFont systemFontOfSize:_fontSize];
    self.totalLabel.font = [UIFont systemFontOfSize:_fontSize];
    [self layoutProgressView];
}

- (void)setThumbImage:(UIImage *)thumbImage {
    self.thumbImgView.image = thumbImage;
}

- (void)setPlayingTint:(UIColor *)playingTint {
    self.playingImgView.backgroundColor = playingTint;
}

- (void)setPlayingImage:(UIImage *)playingImage {
    self.playingImgView.image = playingImage;
}

- (void)setLoadingTint:(UIColor *)loadingTint {
    self.loadingImgView.backgroundColor = loadingTint;
}

- (void)setLoadingImage:(UIImage *)loadingImage {
    self.loadingImgView.image = loadingImage;
}

- (void)setTotalTint:(UIColor *)totalTint {
    self.totalImgView.backgroundColor = totalTint;
}

- (void)setTotalImage:(UIImage *)totalImage {
    self.totalImgView.image = totalImage;
}

- (void)layoutProgressView {
    CGFloat constant = (_hoursHidden?3:4) * _fontSize + 15;
    self.progressViewLeftConstraint.constant = constant;
    self.progressViewRightConstraint.constant = constant;
}


#pragma mark - ------------------------ 时间控制 --------------------------
//MARK: 正在播放时间
- (void)setPlayingTime:(NSTimeInterval)playingTime {
    if (_isSliding) { return; }
    playingTime = MAX(playingTime, 0);
    _playingTime = MIN(playingTime, _totalTime);
    self.playingImgViewWidthConstraint.constant = self.totalImgView.bounds.size.width * _playingTime/_totalTime;
    [self updateTimeLabel];
}

//MARK: 已加载的时间
- (void)setLoadingTime:(NSTimeInterval)loadingTime {
    loadingTime = MAX(loadingTime, 0);
    _loadingTime = MIN(loadingTime, _totalTime);
    self.loadingImgViewWidthConstraint.constant = self.totalImgView.bounds.size.width * _loadingTime/_totalTime;
}

//MARK: 总时间
- (void)setTotalTime:(NSTimeInterval)totalTime {
    if (_isSliding) { return; }
    _totalTime = MAX(totalTime, 0.000001);
    _playingTime = MIN(_playingTime, _totalTime);
    _loadingTime = MIN(_loadingTime, _totalTime);
    self.playingImgViewWidthConstraint.constant = self.totalImgView.bounds.size.width * _playingTime/_totalTime;
    self.loadingImgViewWidthConstraint.constant = self.totalImgView.bounds.size.width * _loadingTime/_totalTime;
    [self updateTimeLabel];
}

//MARK: 时间显示
- (void)updateTimeLabel {
    NSInteger s = (NSInteger)_playingTime;
    NSInteger sec = _remainedTime ? (NSInteger)(_totalTime-_playingTime) : (NSInteger)_totalTime;
    NSString *playingText, *totalText;
    if (_hoursHidden) {
        NSString *pFormat = s/60<10 ? @"%02ld:%02ld" : @"%ld:%02ld";
        playingText = [NSString stringWithFormat:pFormat, s/60, s%60];
        NSString *tFormat = sec/60<10 ? @"%02ld:%02ld" : @"%ld:%02ld";
        totalText = [NSString stringWithFormat:tFormat, sec/60, sec%60];
    }else {
        playingText = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", s/3600, (s%3600)/60, s%60];
        totalText = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", sec/3600, (sec%3600)/60, sec%60];
    }
    self.playingLabel.text = playingText;
    self.totalLabel.text = _remainedTime?[@"-" stringByAppendingString:totalText]:totalText;
}

//滚动到指定位置
- (BOOL)shouldSlidingToX:(CGFloat)x {
    CGFloat width = self.progressView.bounds.size.width;
    if (x < -15) {
        return NO;
    }
    else if (x < 0) {
        self.playingImgViewWidthConstraint.constant = 0;
        _playingTime = 0;
    }else if (x < width) {
        self.playingImgViewWidthConstraint.constant = x;
        _playingTime = _totalTime * x / width;
    }else if (x < width+15) {
        self.playingImgViewWidthConstraint.constant = width;
        _playingTime = _totalTime;
    }else {
        return NO;
    }
    [self updateTimeLabel];
    return YES;
}




#pragma mark - ------------------------ 用户交互 --------------------------
//MARK: 单击
- (void)sigleClicked:(UITapGestureRecognizer *)gesture {
    CGFloat x = [gesture locationInView:self.progressView].x;
    if ([self shouldSlidingToX:x]) {
        //代理回调
        if (self.delegate && [self.delegate respondsToSelector:@selector(progressBar:slidingEndedAtTime:)]) {
            [self.delegate progressBar:self slidingEndedAtTime:_playingTime];
        }
    }
}

//MARK: 滑动、拖拽
- (void)pan:(UIPanGestureRecognizer *)gesture {
    //滑动中
    CGFloat x = [gesture locationInView:self.progressView].x;
    if ([self shouldSlidingToX:x]) {
        //代理回调
        if (self.delegate && [self.delegate respondsToSelector:@selector(progressBar:slidingMovedAtTime:)]) {
            [self.delegate progressBar:self slidingMovedAtTime:_playingTime];
        }
    }
    
    //滑动开始
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _isSliding = YES;
        //代理回调
        if (self.delegate && [self.delegate respondsToSelector:@selector(progressBar:slidingBeganAtTime:)]) {
            [self.delegate progressBar:self slidingBeganAtTime:_playingTime];
        }
    }
    //滑动结束
    else if (gesture.state == UIGestureRecognizerStateEnded) {
        _isSliding = NO;
        //代理回调
        if (self.delegate && [self.delegate respondsToSelector:@selector(progressBar:slidingEndedAtTime:)]) {
            [self.delegate progressBar:self slidingEndedAtTime:_playingTime];
        }
    }
}

@end

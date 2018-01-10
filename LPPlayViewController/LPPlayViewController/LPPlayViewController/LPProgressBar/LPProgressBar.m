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
    
    self.totalTime = 0;
    self.playingTime = 0;
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
    _playingTime = playingTime;
    self.playingImgViewWidthConstraint.constant = self.totalImgView.bounds.size.width * playingTime/_totalTime;
    [self updateTimeLabel];
}

//MARK: 已加载的时间
- (void)setLoadingTime:(NSTimeInterval)loadingTime {
    _loadingTime = loadingTime;
    self.loadingImgViewWidthConstraint.constant = self.totalImgView.bounds.size.width * loadingTime/_totalTime;
}

- (void)setTotalTime:(NSTimeInterval)totalTime {
    if (_isSliding) { return; }
    _totalTime = MAX(totalTime, 0.000001);
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



#pragma mark - ------------------------ 用户交互 --------------------------
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGFloat x = [touches.anyObject locationInView:self].x;
    CGRect rect = self.progressView.frame;
    if (x>CGRectGetMinX(rect)-15 && x<CGRectGetMaxX(rect)+15) {
        _isSliding = YES;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_isSliding) {
        CGFloat x = [touches.anyObject locationInView:self.progressView].x;
        CGFloat width = self.progressView.bounds.size.width;
        x = MIN(x, width);
        x = MAX(x, 0);
        self.playingImgViewWidthConstraint.constant = x;
        _playingTime = _totalTime * x / width;
        [self updateTimeLabel];
        
        //代理回调
        if (self.delegate && [self.delegate respondsToSelector:@selector(progressBar:userDidSlidindAtTime:)]) {
            [self.delegate progressBar:self userDidSlidindAtTime:_playingTime];
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_isSliding) {
        [self touchesMoved:touches withEvent:event];
        _isSliding = NO;
        //代理回调
        if (self.delegate && [self.delegate respondsToSelector:@selector(progressBar:userSlidedDidEndedAtTime:)]) {
            [self.delegate progressBar:self userSlidedDidEndedAtTime:_playingTime];
        }
    }
}
@end

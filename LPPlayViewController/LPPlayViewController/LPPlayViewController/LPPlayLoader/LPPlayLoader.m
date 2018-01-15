//
//  LPPlayLoader.m
//  LPPlayViewController
//
//  Created by iOSLiu on 2018/1/15.
//  Copyright © 2018年 iOS_刘平. All rights reserved.
//

#import "LPPlayLoader.h"

@interface LPPlayLoader ()
@property (weak, nonatomic) IBOutlet UIImageView *animationImgView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@end



@implementation LPPlayLoader

+ (instancetype)loader {
    LPPlayLoader *loader = [NSBundle.mainBundle loadNibNamed:@"LPPlayLoader" owner:nil options:nil].firstObject;
    //动画帧
    NSMutableArray *animationImgs = [NSMutableArray array];
    for (int i=0; i<8; i++) {
        NSString *imgName = [@"LPPlayer_loader" stringByAppendingFormat:@"%d", i];
        UIImage *img = [UIImage imageNamed:imgName];
        if (!img) { continue; }
        [animationImgs addObject:img];
    }
    loader.animationImgView.animationImages = animationImgs;
    loader.animationImgView.animationDuration = 1;
    loader.animationImgView.animationRepeatCount = 0;
    return loader;
}

- (void)loadingWithSpeed:(NSInteger)speed {
    if (self.animationImgView.isAnimating) {
        [self.animationImgView stopAnimating];
    }
    self.animationImgView.highlighted = NO;
    self.messageLabel.text = SpeedString(speed);
}

- (void)reloadingWithSpeed:(NSInteger)speed {
    if (!self.animationImgView.isAnimating) {
        [self.animationImgView startAnimating];
    }
    self.messageLabel.text = SpeedString(speed);
}


- (void)endLoading {
    [self.animationImgView stopAnimating];
    [self removeFromSuperview];
}

- (void)showError:(NSString *)description {
    [self.animationImgView stopAnimating];
    self.animationImgView.highlighted = YES;
    self.messageLabel.text = description;
}



//网速
NSString *SpeedString(NSInteger speed) {
    CGFloat v = speed/1024.f;
    if (v >= 1024) {
        return [NSString stringWithFormat:@"%.1lfMB/s",v/1024.f];
    }else if (v >= 1) {
        return [NSString stringWithFormat:@"%.1lfKB/s",v];
    }else if (v >= 0) {
        return [NSString stringWithFormat:@"%ldB/s",speed];
    }else {
        return @"0B/s";
    }
}
@end

//
//  LPProgressBar.h
//  LPProgressBar
//
//  Created by iOSLiu on 2018/1/3.
//  Copyright © 2018年 iOS_刘平. All rights reserved.
//

#import <UIKit/UIKit.h>


/** 协议 */
@class LPProgressBar;
@protocol LPProgressBarDelegate <NSObject>
@optional
/** 用户开始手动滑动进度条时 */
- (void)progressBar:(LPProgressBar *)bar slidingBeganAtTime:(NSTimeInterval)time;
/** 用户手动滑动进度条时 */
- (void)progressBar:(LPProgressBar *)bar slidingMovedAtTime:(NSTimeInterval)time;
/** 用户手动滑动进度条结束 */
- (void)progressBar:(LPProgressBar *)bar slidingEndedAtTime:(NSTimeInterval)time;
@end



/*************** 视频播放进度条 ***************/
@interface LPProgressBar : UIView
///是否隐藏小时数（默认NO）
@property (assign, nonatomic) BOOL hoursHidden;
///是否显示剩余时间（默认NO）
@property (assign, nonatomic) BOOL remainedTime;

///字体颜色（默认FFFFFF）
@property (copy, nonatomic) UIColor *fontColor;
///字体大小（默认9，最小为9）
@property (assign, nonatomic) CGFloat fontSize;
///指示器图
@property (copy, nonatomic) UIImage *thumbImage;
///已播放条背景色（默认000000）
@property (copy, nonatomic) UIColor *playingTint;
///已播放条图
@property (copy, nonatomic) UIImage *playingImage;
///已缓存条背景色（默认B4B4B4）
@property (copy, nonatomic) UIColor *loadingTint;
///已缓存条图
@property (copy, nonatomic) UIImage *loadingImage;
///进度条背景色（默认FFFFFF）
@property (copy, nonatomic) UIColor *totalTint;
///进度条图
@property (copy, nonatomic) UIImage *totalImage;

///代理
@property (weak, nonatomic) id <LPProgressBarDelegate> delegate;

///正在播放时间（单位：秒）
@property (assign, nonatomic) NSTimeInterval playingTime;
///缓存的时间（单位：秒）
@property (assign, nonatomic) NSTimeInterval loadingTime;
///总时间（单位：秒）
@property (assign, nonatomic) NSTimeInterval totalTime;


///用户是否正在手动调整进度条
@property (assign, nonatomic, readonly) BOOL isSliding;
@end



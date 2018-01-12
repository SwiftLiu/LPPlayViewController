//
//  LPPlayControl.h
//  LPPlayControlView
//
//  Created by iOSLiu on 2018/1/5.
//  Copyright © 2018年 iOS_刘平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPPlayControlDelegate.h"
#import "LPPlayHeader.h"
#import "LPProgressBar.h"

/*************** 播放器控制层 ***************/
@interface LPPlayControl : UIView

///代理
@property (weak, nonatomic) id <LPPlayControlDelegate> delegate;
///全屏（默认为NO）
@property (assign, nonatomic, getter=isFullScreen) BOOL fullScreen;
///播放状态（默认为NO）
@property (assign, nonatomic, getter=isPlaying) BOOL playing;

///正在播放时间（单位：秒）
@property (assign, nonatomic) NSTimeInterval playingTime;
///缓存的时间（单位：秒）
@property (assign, nonatomic) NSTimeInterval loadingTime;
///总时间（单位：秒）
@property (assign, nonatomic) NSTimeInterval totalTime;

///控制栏是否隐藏（默认为NO）
@property (assign, nonatomic, readonly) BOOL barHidden;

/** 初始化 */
+ (instancetype)controlViewWithStyle:(LPPlayStyle)style;
@end

//
//  LPPlayControl.h
//  LPPlayControlView
//
//  Created by iOSLiu on 2018/1/5.
//  Copyright © 2018年 iOS_刘平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPPlayControlDelegate.h"

/*************** 控制层风格  ***************/
typedef NS_ENUM(NSInteger, LPPlayControlStyle) {
    ///正常风格
    LPPlayControlStyleNormal = 0,
    ///极简风格
    LPPlayControlStyleEsay   = 1,
    ///直播风格
    LPPlayControlStyleLive   = 2,
};



/*************** 播放器控制层 ***************/
@interface LPPlayControl : UIView
///代理
@property (weak, nonatomic) id <LPPlayControlDelegate> delegate;
///全屏
@property (assign, nonatomic) BOOL fullScreen;

/** 初始化 */
+ (instancetype)controlViewWithStyle:(LPPlayControlStyle)style;
@end

//
//  LPPlayControlDelegate.h
//  LPPlayer
//
//  Created by iOSLiu on 2017/8/8.
//  Copyright © 2017年 iOS_刘平. All rights reserved.
//

#ifndef LPPlayControlDelegate_h
#define LPPlayControlDelegate_h

/** 控制代理 */
@class LPPlayControl;
@protocol LPPlayControlDelegate <NSObject>

@optional
/** 点击返回按钮 */
- (void)controlDidClickedBackButton:(LPPlayControl *)control;
/** 点击播放按钮 */
- (void)control:(LPPlayControl *)control didClickedPlayButtonWillPlaying:(BOOL)playing;
/** 点击全屏按钮时 */
- (void)control:(LPPlayControl *)control didClickedFullScreenButton:(BOOL)fullScreen;
/** 点击提示时的按钮 */
- (void)controlDidClickedAlertButton:(LPPlayControl *)control;
/** 快进到指定播放时间 */
- (void)control:(LPPlayControl *)control didSeekedToTime:(NSTimeInterval)time;
/** 调节音量时 */
- (void)control:(LPPlayControl *)control volumeDidChangedToValue:(CGFloat)value;
/** 调节亮度时 */
- (void)control:(LPPlayControl *)control brightnessDidChangedToValue:(CGFloat)value;
/** 点击锁屏按钮时 */
- (void)control:(LPPlayControl *)control didClickedLockButton:(BOOL)locked;
/** 选中清晰度播放源时 */
- (void)control:(LPPlayControl *)control didSelectedSourceAtIndex:(NSInteger)index;
/** 选中某一集时 */
- (void)control:(LPPlayControl *)control didSelectedSetAtIndex:(NSInteger)index;
/** 控制栏即将显示和隐藏 */
- (void)control:(LPPlayControl *)control barsWillBeHidden:(BOOL)hidden;
/** 控制栏完成显示和隐藏 */
- (void)control:(LPPlayControl *)control barsDidBeHidden:(BOOL)hidden;
@end


#endif /* LPPlayControlDelegate_h */

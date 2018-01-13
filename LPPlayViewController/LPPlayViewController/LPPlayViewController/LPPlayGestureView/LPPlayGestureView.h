//
//  LPPlayGestureView.h
//  LPPlayControl
//
//  Created by iOSLiu on 2018/1/8.
//  Copyright © 2018年 iOS_刘平. All rights reserved.
//

#import <UIKit/UIKit.h>

/*************** 拖拽或滑动方向 ***************/
typedef NS_ENUM(NSInteger, LPPanDirection) {
    ///上
    LPPanDirectionUp,
    ///下
    LPPanDirectionDown,
    ///左
    LPPanDirectionLeft,
    ///右
    LPPanDirectionRight
};


/** 代理 */
@class LPPlayGestureView;
@protocol LPPlayGestureViewDelegate <NSObject>
@optional
/** 单击 */
- (void)gestureViewDidSigleTap:(LPPlayGestureView *)view;
/** 双击 */
- (void)gestureViewDidDoubleTap:(LPPlayGestureView *)view;

/** 滑动开始 */
- (void)gestureViewPanBegan:(LPPlayGestureView *)view;
/** 滑动结束 */
- (void)gestureViewPanEnded:(LPPlayGestureView *)view;
/** 上下滑动 */
- (void)gestureView:(LPPlayGestureView *)view addY:(CGFloat)y left:(BOOL)left;
/** 开始左右滑动 */
- (void)gestureView:(LPPlayGestureView *)view beganPanWithAddedX:(CGFloat)x;
/** 左右滑动中 */
- (void)gestureView:(LPPlayGestureView *)view movedPanWithAddedX:(CGFloat)x;
/** 结束左右滑动 */
- (void)gestureView:(LPPlayGestureView *)view endedPanWithAddedX:(CGFloat)x;
@end

/*************** 手势层 ***************/
@interface LPPlayGestureView : UIView
///代理
@property (weak, nonatomic) id <LPPlayGestureViewDelegate> delegate;
///用户是否正在手动调整进度条
@property (assign, nonatomic, readonly) BOOL isSlidingProgress;
@end

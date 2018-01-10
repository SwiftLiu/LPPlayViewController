//
//  LPGestureView.h
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
@class LPGestureView;
@protocol LPGestureViewDelegate <NSObject>
@optional
/** 单击 */
- (void)gestureViewDidSigleTap:(LPGestureView *)view;
/** 双击 */
- (void)gestureViewDidDoubleTap:(LPGestureView *)view;
/** 左右滑动 */
- (void)gestureView:(LPGestureView *)view addX:(CGFloat)x;
/** 上下滑动 */
- (void)gestureView:(LPGestureView *)view addY:(CGFloat)y left:(BOOL)left;
@end

/*************** 手势层 ***************/
@interface LPGestureView : UIView
///代理
@property (weak, nonatomic) id <LPGestureViewDelegate> delegate;
@end

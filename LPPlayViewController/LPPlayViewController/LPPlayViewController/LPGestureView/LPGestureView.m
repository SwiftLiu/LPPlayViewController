//
//  LPGestureView.m
//  LPPlayControl
//
//  Created by iOSLiu on 2018/1/8.
//  Copyright © 2018年 iOS_刘平. All rights reserved.
//

#import "LPGestureView.h"

@interface LPGestureView ()
{
    CGPoint currentGesturePoint;//当前手势相对手势开始点的位置
    BOOL isLeft;//手势开始位置是否在屏幕左半部分
    BOOL isBeganDirecation;//是否开始判断滑动方向
    BOOL isHorizontal;//是否为横向滑动
}
@end

@implementation LPGestureView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addGestures];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self addGestures];
}

//MARK: 添加手势
- (void)addGestures {
    //单击
    UITapGestureRecognizer *sigleTap = [[UITapGestureRecognizer alloc] init];
    sigleTap.numberOfTapsRequired = 1;
    [sigleTap addTarget:self action:@selector(sigleClicked:)];
    [self addGestureRecognizer:sigleTap];
    
    //双击
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] init];
    doubleTap.numberOfTapsRequired = 2;
    [doubleTap addTarget:self action:@selector(doubleClicked:)];
    [self addGestureRecognizer:doubleTap];
    
    //优先双击手势
    [sigleTap requireGestureRecognizerToFail:doubleTap];
    
    //滑动、拖拽
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] init];
    [pan addTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
}


//MARK: 单击
- (void)sigleClicked:(UITapGestureRecognizer *)gesture {
    if (self.delegate && [self.delegate respondsToSelector:@selector(gestureViewDidSigleTap:)]) {
        [self.delegate gestureViewDidSigleTap:self];
    }
}

//MARK: 双击
- (void)doubleClicked:(UITapGestureRecognizer *)gesture {
    if (self.delegate && [self.delegate respondsToSelector:@selector(gestureViewDidDoubleTap:)]) {
        [self.delegate gestureViewDidDoubleTap:self];
    }
}

//MARK: 滑动、拖拽
- (void)pan:(UIPanGestureRecognizer *)gesture {
    if (!self.delegate) { return; }
    
    //①滑动开始代理
    if (gesture.state == UIGestureRecognizerStateBegan) {
        //重置初始位置
        currentGesturePoint = CGPointZero;
        //设置为开始判断方向
        isBeganDirecation = YES;
        //判断手势开始位置在屏幕左边或右边
        isLeft = [gesture locationInView:self].x < self.bounds.size.width*.5;
        //代理回调
        if ([self.delegate respondsToSelector:@selector(gestureViewPanBegan:)]) {
            [self.delegate gestureViewPanBegan:self];
        }
    }
    
    //②滑动方向判断（根据第一个滑动了2pt距离的点判断）
    CGPoint p = [gesture translationInView:self];
    if (isBeganDirecation && (pow(p.x, 2)+pow(p.y, 2)>=4)) {
        isHorizontal = (pow(p.x, 2) > pow(p.y, 2));//判断是否为横向滑动
        _isSlidingProgress = isHorizontal;//开始进度调节
        isBeganDirecation = NO;//结束判断
    }
    
    //③根据滑动方向回调对应代理协议
    if (isHorizontal) {
        if ([self.delegate respondsToSelector:@selector(gestureView:addX:isEnd:)]) {
            [self.delegate gestureView:self addX:p.x-currentGesturePoint.x isEnd:gesture.state == UIGestureRecognizerStateEnded];
        }
    }else {
        if ([self.delegate respondsToSelector:@selector(gestureView:addY:left:)]) {
            [self.delegate gestureView:self addY:currentGesturePoint.y-p.y left:isLeft];
        }
    }
    
    //滑动结束代理
    if (gesture.state == UIGestureRecognizerStateEnded) {
        //结束进度调节
        _isSlidingProgress = NO;
        //代理回调
        if ([self.delegate respondsToSelector:@selector(gestureViewPanEnded:)]) {
            [self.delegate gestureViewPanEnded:self];
        }
    }
    
    currentGesturePoint = p;
}
@end

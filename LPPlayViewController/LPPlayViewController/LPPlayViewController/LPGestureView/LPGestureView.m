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
    CGPoint _currentGesturePoint;//当前手势相对手势开始点的位置
    BOOL _gestureBeganLeft;//手势开始位置是否在屏幕左半部分
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
    CGPoint p = [gesture translationInView:self];
    if (pow(p.x, 2) > pow(p.y, 2)) {//左右
        if (self.delegate && [self.delegate respondsToSelector:@selector(gestureView:addX:)]) {
            [self.delegate gestureView:self addX:p.x-_currentGesturePoint.x];
        }
    }
    else {//上下
        //判断手势开始位置在屏幕左边或右边
        if (gesture.state == UIGestureRecognizerStateBegan) {
            _gestureBeganLeft = [gesture locationInView:self].x < self.bounds.size.width*.5;
        }
        //回调
        if (self.delegate && [self.delegate respondsToSelector:@selector(gestureView:addY:left:)]) {
            [self.delegate gestureView:self addY:_currentGesturePoint.y-p.y left:_gestureBeganLeft];
        }
    }
    
    _currentGesturePoint = p;
}
@end

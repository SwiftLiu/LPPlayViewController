//
//  LPPlayLoader.h
//  LPPlayViewController
//
//  Created by iOSLiu on 2018/1/15.
//  Copyright © 2018年 iOS_刘平. All rights reserved.
//

#import <UIKit/UIKit.h>

/*************** 加载指示器 ***************/
@interface LPPlayLoader : UIView
/** 便利初始化 */
+ (instancetype)loader;

/** 开始加载，显示默认图（网速单位：B/s） */
- (void)loadingWithSpeed:(NSInteger)speed;
/** 重加载，显示动画（网速单位：B/s） */
- (void)reloadingWithSpeed:(NSInteger)speed;
/** 结束加载，从父视图上移除 */
- (void)endLoading;
/** 结束加载并显示错误提示 */
- (void)showError:(NSString *)description;
@end

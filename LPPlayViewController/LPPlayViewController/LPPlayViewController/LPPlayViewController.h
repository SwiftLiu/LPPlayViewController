//
//  LPPlayViewController.h
//  LPPlayViewController
//
//  Created by iOSLiu on 2018/1/9.
//  Copyright © 2018年 iOS_刘平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPPlayHeader.h"


/** 代理 */
@class LPPlayViewController;
@protocol LPPlayViewControllerDelegate <NSObject>
@optional
/** 清晰度名称 */
- (NSArray<NSString*> *)claritiesInViewController:(LPPlayViewController *)viewController;
/** 各清晰度资源地址 */
- (NSString *)viewController:(LPPlayViewController *)viewController urlOfClarityAtIndex:(NSInteger)index;
/** 选集数 */
- (NSInteger)numberOfSetsInViewController:(LPPlayViewController *)viewController;
/** 选集item */
//- (uicollection)numberOfSetsInViewController:(LPPlayViewController *)viewController;
@end



/*************** 视频播放控制器 **************
 * 注意：info.plist必须添加View controller-based status bar appearance设为NO
 */
@interface LPPlayViewController : UIViewController

///代理
@property (weak, nonatomic) id <LPPlayViewControllerDelegate> delegate;
///设备旋转时是否允许自动全屏（默认为YES）
@property (assign, nonatomic) BOOL autoFullScreen;

///当前是否为全屏模式（默认为NO）
@property (assign, nonatomic, readonly) BOOL fullScreen;

/** 便利初始化 */
+ (instancetype)viewControllerWithStyle:(LPPlayStyle)style;
@end

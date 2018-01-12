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
/** 点击返回按钮时 */
- (void)playControllerDidClickedBackButton:(LPPlayViewController *)playController;

@required
/** 清晰度名称 */
- (NSArray<NSString*> *)claritiesInPlayController:(LPPlayViewController *)playController;
/** 各清晰度资源地址 */
- (NSString *)playController:(LPPlayViewController *)playController urlOfClarityAtIndex:(NSInteger)index;
/** 选集数 */
- (NSInteger)numberOfSetsInPlayController:(LPPlayViewController *)playController;
/** 选集item */
- (UICollectionViewCell *)playController:(LPPlayViewController *)playController cellForItemAtIndex:(NSInteger)index;
@end



/*************** 视频播放控制器 **************
 * 注意：info.plist必须添加View controller-based status bar appearance设为NO
 */
@interface LPPlayViewController : UIViewController

///代理
@property (weak, nonatomic) id <LPPlayViewControllerDelegate> delegate;
///设备旋转时是否允许自动全屏（默认为YES）
@property (assign, nonatomic) BOOL autoFullScreen;


///当前播放的网络视频地址
@property (copy, nonatomic, readonly) NSString *url;
///播放器风格（默认为LPPlayStyleNormal）
@property (assign, nonatomic, readonly) LPPlayStyle style;
///当前是否为全屏模式（默认为NO）
@property (assign, nonatomic, readonly) BOOL isFullScreen;

/** 初始化 */
+ (instancetype)playControllerWithStyle:(LPPlayStyle)style;
/** 刷新播放器 */
- (void)reloadData;
@end

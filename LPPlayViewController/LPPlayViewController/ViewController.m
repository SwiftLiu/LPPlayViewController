//
//  ViewController.m
//  LPPlayViewController
//
//  Created by iOSLiu on 2018/1/9.
//  Copyright © 2018年 iOS_刘平. All rights reserved.
//

#import "ViewController.h"
#import "LPPlayViewController.h"
#import "BasicNetwork.h"

@interface ViewController ()<LPPlayViewControllerDelegate>
@property (strong, nonatomic) NSMutableArray *urls;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.urls = [NSMutableArray array];
    [self.urls addObject:@"https://video1.lart.org/Fabien_Danesi-E.A.A.C.A-preview-720.mp4"];
    [self.urls addObject:@"https://video1.lart.org/Federico_Muelas-I.A.I.D.A-preview-720.mp4"];
    [self.urls addObject:@"https://video1.lart.org/Jonathan_Miles-T.F.O.M-preview-720.mp4"];
    [self.urls addObject:@"https://video1.lart.org/Svetlana_Kuleshova-I.T.S-preview-720.mp4"];
    [self initPlayer];
}

- (void)initPlayer {
    LPPlayViewController *pvc = [LPPlayViewController playControllerWithStyle:(LPPlayStyleNormal)];
    [self addChildViewController:pvc];
    pvc.view.frame = CGRectMake(0, 20, self.view.bounds.size.width, 210);
    [self.view addSubview:pvc.view];
    pvc.selectedSetIndex = 1;
    pvc.referer = @"https://www.lart.org";
    pvc.delegate = self;
}






#pragma mark - <LPPlayViewControllerDelegate>协议实现
- (NSArray<NSString *> *)claritiesInPlayController:(LPPlayViewController *)playController {
    return @[@"超清", @"高清", @"标清"];
}

- (NSString *)playController:(LPPlayViewController *)playController urlOfClarityAtIndex:(NSInteger)index inSet:(NSInteger)set {
    return [self.urls objectAtIndex:set];
}

- (NSInteger)numberOfSetsInPlayController:(LPPlayViewController *)playController {
    return self.urls.count;
}

- (NSString *)playController:(LPPlayViewController *)playController titleInSet:(NSInteger)set {
    return [NSString stringWithFormat:@"第%02ld集", set+1];
}

//- (UICollectionViewCell *)playController:(LPPlayViewController *)playController cellForItemAtIndex:(NSInteger)index {
//
//}

@end

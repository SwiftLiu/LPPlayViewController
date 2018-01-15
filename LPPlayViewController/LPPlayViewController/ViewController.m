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
@property (copy, nonatomic) NSString *url;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    NSString *url = @"https://api.lart.org/course/detail";
    NSDictionary *param = @{@"customerId":@"", @"courseId":@"14933647653134"};
    [BasicNetwork getDataFromURL:url token:nil userId:nil param:param succeedBlock:^(NSDictionary *result, NSString *token) {
        weakSelf.url = [result objectForKey:@"previewVideo"];
        [weakSelf initPlayer];
    } failedBlock:nil];
}

- (void)initPlayer {
    LPPlayViewController *pvc = [LPPlayViewController playControllerWithStyle:(LPPlayStyleNormal)];
    [self addChildViewController:pvc];
    pvc.view.frame = CGRectMake(0, 20, self.view.bounds.size.width, 220);
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
    if (set == 0) {
        return @"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4";
    }else if (set == 1) {
        return @"https://www.w3schools.com/html/movie.mp4";
    }else if (set == 2) {
        return @"http://www.w3school.com.cn/example/html5/mov_bbb.mp4";
    }else if (set == 3) {
        return @"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4";
    }else {
        return self.url;
    }
}

- (NSInteger)numberOfSetsInPlayController:(LPPlayViewController *)playController {
    return 5;
}

- (NSString *)playController:(LPPlayViewController *)playController titleInSet:(NSInteger)set {
    return [NSString stringWithFormat:@"第%02ld集", set+1];
}

//- (UICollectionViewCell *)playController:(LPPlayViewController *)playController cellForItemAtIndex:(NSInteger)index {
//
//}

@end

//
//  BasicNetwork.h
//  Desire
//
//  Created by liuping on 16/8/15.
//  Copyright © 2016年 刘平. All rights reserved.
//

#import <Foundation/Foundation.h>

/********** 自定义错误类 *********
@interface KWError : NSObject
///错误编码
@property (assign, nonatomic) NSInteger code;
///错误描述
@property (copy, nonatomic) NSString *description;
///错误描述（调试）
@property (copy, nonatomic) NSString *debugDescription;
@end
*/

#pragma mark - 页码信息结构体
struct NetworkPage {
    ///总页数
    NSInteger pageCount;
    ///当前页码
    NSInteger pageNum;
    ///所有页码数据总条数
    NSInteger dataTotal;
} ;
typedef struct NetworkPage NetworkPage;

NetworkPage NetworkPageMake(NSDictionary *modelDic);
NetworkPage NetworkPageMaked(NSInteger pageCount, NSInteger pageNum, NSInteger dataTotal);
#define NetworkPageZero (NetworkPage){.pageCount=0,.pageNum=0,.dataTotal=0};


#pragma mark - 网络请求封装
///网络请求成功后服务器返回的结果回调
typedef void (^RequestSucceed)(id result, NSString *token);
///网络请求失败回调
typedef void (^RequestFailed)(NSInteger code, NSString *description);


/********** 参数key **********/
#define kNetworkCode @"code"
#define kNetworkData @"data"
#define kNetworkMsg @"msg"
#define kNetworkToken @"token"

#define kContentType @"Content-Type"
#define kAuthorization @"authorization"
#define kCustomerId @"customerId"
#define kNetworkList @"list"
#define kNetworkPages @"pages"
#define kNetworkPageCount @"countPage"
#define kNetworkPageNum @"nowPage"
#define kNetworkDataTotal @"total"

/********** 网络请求封装 **********
 * Post异步
 * Get异步
********** 网络请求封装 **********/
@interface BasicNetwork : NSObject

/**
 *  Post异步请求(自动添加用户Token到header)
 *
 *  @param url            接口地址
 *  @param token          用户登录token
 *  @param userId         用户Id
 *  @param params         参数
 *  @param succeedBlock   请求成功
 *  @param failedBlock    请求失败
 */
+ (void)postDataToURL:(NSString *)url
                token:(NSString *)token
               userId:(NSString *)userId
                param:(NSDictionary *)params
         succeedBlock:(RequestSucceed)succeedBlock
          failedBlock:(RequestFailed)failedBlock;



/**
 *  Get异步请求
 *
 *  @param url              接口地址
 *  @param token            用户登录token
 *  @param userId           用户Id
 *  @param params           参数
 *  @param succeedBlock     请求成功
 *  @param failedBlock      请求失败
 */
+ (void)getDataFromURL:(NSString *)url
                 token:(NSString *)token
                userId:(NSString *)userId
                 param:(NSDictionary *)params
          succeedBlock:(RequestSucceed)succeedBlock
           failedBlock:(RequestFailed)failedBlock;

@end


#pragma mark - MD5加密
@interface NSString (MD5)
///MD5加密
- (NSString *)Md5;
@end

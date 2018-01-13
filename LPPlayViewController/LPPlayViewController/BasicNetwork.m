//
//  BasicNetwork.m
//  Desire
//
//  Created by liuping on 16/8/15.
//  Copyright © 2016年 刘平. All rights reserved.
//

#import <CommonCrypto/CommonCrypto.h>
#import "AFNetworking.h"
#import "JSONKit.h"
#import "BasicNetwork.h"

#pragma mark - 平台鉴权AppSecret
static NSString *AppSecret = @"d9gtowwqzksnyhyofu9m8wp5ctuuwjhuq";



#pragma mark - 页码模型解析
NetworkPage NetworkPageMake(NSDictionary *modelDic) {
    NetworkPage page;
    page.pageNum = [[modelDic objectForKey:kNetworkPageNum]?:@"0" integerValue];
    page.pageCount = [[modelDic objectForKey:kNetworkPageCount]?:@"0" integerValue];
    page.dataTotal = [[modelDic objectForKey:kNetworkDataTotal]?:@"0" integerValue];
    return page;
}

NetworkPage NetworkPageMaked(NSInteger pageCount, NSInteger pageNum, NSInteger dataTotal) {
    NetworkPage page;
    page.pageNum   = pageCount>0?pageCount:0;
    page.pageCount = pageNum>0?pageNum:0;
    page.dataTotal = dataTotal>0?dataTotal:0;
    return page;
}



#pragma mark - 网络请求
/// 网络请求超时时间
NSTimeInterval RequestTimeout = 30;

@implementation BasicNetwork

#pragma mark - Post异步请求
+ (void)postDataToURL:(NSString *)url token:(NSString *)token userId:(NSString *)userId param:(NSDictionary *)params succeedBlock:(RequestSucceed)succeedBlock failedBlock:(RequestFailed)failedBlock
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    [manager.requestSerializer setTimeoutInterval:RequestTimeout];
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    //配置头信息
    [self requestHeaderForManager:manager token:token userId:userId];
    //URL
    NSCharacterSet *charSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *utf8Url = [url stringByAddingPercentEncodingWithAllowedCharacters:charSet];
    //加密
    NSDictionary *newParam = [self encryptParams:params url:url];
    [manager POST:utf8Url parameters:newParam progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self dealData:responseObject succeedBlock:succeedBlock failedBlock:failedBlock];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self dealWhenFailedWithError:error failedBlock:failedBlock];
    }];
}

#pragma mark - Get异步请求
+ (void)getDataFromURL:(NSString *)url token:(NSString *)token userId:(NSString *)userId param:(NSDictionary *)params succeedBlock:(RequestSucceed)succeedBlock failedBlock:(RequestFailed)failedBlock
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    [manager.requestSerializer setTimeoutInterval:RequestTimeout];
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    //配置头信息
    [self requestHeaderForManager:manager token:token userId:userId];
    //URL
    NSCharacterSet *charSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *utf8Url = [url stringByAddingPercentEncodingWithAllowedCharacters:charSet];
    //加密
    NSDictionary *newParam = [self encryptParams:params url:url];
    [manager GET:utf8Url parameters:newParam progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self dealData:responseObject succeedBlock:succeedBlock failedBlock:failedBlock];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self dealWhenFailedWithError:error failedBlock:failedBlock];
    }];
}



#pragma mark - 通用Header
+ (void)requestHeaderForManager:(AFHTTPSessionManager *)manager token:(NSString *)token userId:(NSString *)userId {
    NSCharacterSet *charSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    
    //用户ID
    NSString *userKey = [@"userID" stringByAddingPercentEncodingWithAllowedCharacters:charSet];
    NSString *user = [userId?:@"" stringByAddingPercentEncodingWithAllowedCharacters:charSet];
    [manager.requestSerializer setValue:user forHTTPHeaderField:userKey];
    
    //用户ID
    NSString *tokenKey = [@"authorization" stringByAddingPercentEncodingWithAllowedCharacters:charSet];
    NSString *tokenValue = [token?:@"" stringByAddingPercentEncodingWithAllowedCharacters:charSet];
    [manager.requestSerializer setValue:tokenValue forHTTPHeaderField:tokenKey];
}


#pragma mark - 请求前参数加密
+ (NSDictionary *)encryptParams:(NSDictionary *)param url:(NSString *)url {
    
    NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
    //将参数字典中文编码 创建新字典
    [param enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[NSString class]]) {
            
            obj = [obj stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [mDic setObject:obj forKey:key];
            
        }
        
    }];
    NSMutableDictionary *aParam = [NSMutableDictionary dictionaryWithDictionary:mDic];
    
    //①时间戳
    NSString *timestamp = [NSString stringWithFormat:@"%.0lf", [[NSDate date] timeIntervalSince1970]];
    [aParam setObject:timestamp forKey:@"timestamp"];
    //tickets
    NSString *tickets = [[NSString stringWithFormat:@"%@%@%@", url, timestamp, AppSecret] Md5];
    //字典排序的参数
    NSMutableArray *array = [NSMutableArray arrayWithArray:aParam.allKeys];
    [array sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *str1 = (NSString *)obj1;
        NSString *str2 = (NSString *)obj2;
        return [str1 compare:str2];
    }];
    NSMutableString *paramStr = [NSMutableString string];
    for (int i=0; i<array.count; i++) {
        [paramStr appendFormat:@"%@", [aParam objectForKey:array[i]]];
    }
    //②signature
    NSString *signature = [[NSString stringWithFormat:@"%@%@", paramStr, tickets] Md5];
    [aParam setObject:signature forKey:@"signature"];
    return aParam;
}


#pragma mark - 请求结果处理，业务错误编码
+ (void)dealData:(id)responseObject succeedBlock:(RequestSucceed)succeedBlock failedBlock:(RequestFailed)failedBlock {
    __autoreleasing NSError* eror;
    NSDictionary *result =[NSJSONSerialization JSONObjectWithData:responseObject
                                                          options:kNilOptions
                                                            error:&eror];
    if (!eror && result) {
        NSInteger code = [[result objectForKey:kNetworkCode] integerValue];
        if (code == 10000) {//成功
            if (succeedBlock) {
                id data = [result objectForKey:kNetworkData];
                NSString *token = [result objectForKey:kNetworkToken];
                succeedBlock(data, token);
            };
        }else {//失败
            NSLog(@"业务类错误：%ld, %@", code, [result objectForKey:kNetworkMsg]);
            if (code==10024 || code==10025) {//登录过期
                if (failedBlock) failedBlock(code, @"数据解析出错!");
            }
            else {//失败
                if (failedBlock) failedBlock(code, [result objectForKey:kNetworkMsg]);
            }
        }
    }
    else {
        NSLog(@"数据解析出错!");
        if (failedBlock) {
            failedBlock(-20000, @"数据解析出错!");
        }
    }
}


#pragma mark - 请求失败处理, http错误编码
+ (void)dealWhenFailedWithError:(NSError *)error failedBlock:(RequestFailed)failedBlock {
//    NSLog(@"Get请求失败，错误：%@",error.debugDescription);
    NSString *description = @"数据解析出错!";
    switch (error.code) {
        case -1001: {
            description = @"数据解析出错!";
            NSLog(@"请求超时");
        }
            break;
        case -1004: {
            description = @"数据解析出错!";
            NSLog(@"无法连接服务器");
        }
            break;
        case -1009: {
            description = @"数据解析出错!";
            NSLog(@"网络未连接");
        }
            break;
        default:
        {
            NSLog(@"%@", error.debugDescription);
        }
            break;
    }
    if (failedBlock) {
        failedBlock(error.code, description);
    }
}

@end




@implementation NSString (MD5)
#pragma mark - MD5加密
- (NSString *)Md5 {
    const char* str = [[self copy] UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02X",result[i]];
    }
    return [ret lowercaseString];
}
@end

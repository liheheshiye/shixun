//
//  ServiceAPIManager.h
//  test
//
//  Created by apple on 2018/1/5.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import <SVProgressHUD.h>

@protocol ServiceAPIDelegete <NSObject>

-(void)getDataFromService;

@end

@interface ServiceAPIManager : NSObject

/*------   批注   ------*
 
 ///本整理内容需要导入第三方库:   AFNetworking   /  SVProgressHUD
 
 *  get请求  并通过block返回json数据
 *  URLString  ----> 网络地址
 *  parameters  ----> 参数请求体
 *  success       ----> 请求成功
 *  failure         ----> 请求失败
 */

//创建get请求
+(void)ServiceAPIManagerForGET:(nullable NSString *)URLString parameters:( nullable NSDictionary *)parameters success:(nullable void(^)(id _Nonnull json))success failure:(nullable void(^)(NSURLSessionDataTask *_Nullable task,NSError *_Nonnull error))failure;

//创建post请求
+(void)ServiceAPIManagerForPOST:(nullable NSString *)URLString parameters:( nullable NSDictionary *)parameters success:(nullable void(^)(id _Nonnull json))success failure:(nullable void(^)(NSURLSessionDataTask *_Nullable task,NSError *_Nonnull error))failure;

/*!**销毁单例***/
+ (void)destroyInstance;

@end

//
//  ServiceAPIManager.m
//  test
//
//  Created by apple on 2018/1/5.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "ServiceAPIManager.h"
#import "NSXLoginViewController.h"

//#define ServiceUrl @"http://baidu.com" 

#define Token SERVICEAPITOKEN

static AFHTTPSessionManager * _manager = nil;

static dispatch_once_t Token;

@implementation ServiceAPIManager

//实现单例请求类对象
+(AFHTTPSessionManager *)shareManager;
{
    dispatch_once(&Token, ^{
        if(_manager==nil){
            _manager=[AFHTTPSessionManager manager];
            //        JSESSIONID=5af93736-7f9d-4373-99f3-17548f62127c; Path=/shixun; HttpOnly, rememberMe=deleteMe; Path=/shixun; Max-Age=0; Expires=Mon, 12-Feb-2018 08:33:49 GMT
            NSLog(@"%@",[SXAccount sharedAccount].jsessionID);
            [_manager.requestSerializer setValue:[SXAccount sharedAccount].jsessionID forHTTPHeaderField:@"Cookie"];
            _manager.responseSerializer.acceptableContentTypes =[NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html",@"text/plain",nil];
            [_manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
            _manager.requestSerializer.timeoutInterval = 15.f;
            [_manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        }
    });
    return _manager;
}

+(AFHTTPSessionManager *)manager;
{
    AFHTTPSessionManager * manager =[AFHTTPSessionManager manager];
    manager.securityPolicy.allowInvalidCertificates =true;
    
    return manager;
}

//创建get请求
+(void)ServiceAPIManagerForGET:(nullable NSString *)URLString parameters:( nullable NSDictionary *)parameters success:(nullable void(^)(id _Nonnull json))success failure:(nullable void(^)(NSURLSessionDataTask *_Nullable task,NSError *_Nonnull error))failure;
{
    NSString * fullUrl=[NSString stringWithFormat:@"%@%@",SXAPIURL,URLString];
    //字符串处理
    NSString * string =[fullUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:fullUrl]];
    [SVProgressHUD showWithStatus:@"数据加载中... "];
    //数据请求
    [[ServiceAPIManager shareManager]GET:string parameters:parameters progress:^(NSProgress *_Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task,id _Nullable responseObject) {
        [SVProgressHUD dismiss];
        if (success) {
            // --- > 字典类型 --- > json数据 --- >解析数据并传值
            NSError * error =nil;
            if (error !=nil) {
                [SVProgressHUD showErrorWithStatus:@"数据解析失败,请稍后尝试!"];
                return;
            }
            success(responseObject);
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *_Nonnull error) {
        
        [SVProgressHUD showErrorWithStatus:@"请求数据失败,请检查网络后重试!"];
        if (failure) {
            failure(task,error);
        }
    }];
    
}
//创建post请求
+(void)ServiceAPIManagerForPOST:(nullable NSString *)URLString parameters:( nullable NSDictionary *)parameters success:(nullable void(^)(id _Nonnull json))success failure:(nullable void(^)(NSURLSessionDataTask *_Nullable task,NSError *_Nonnull error))failure;
{
    NSString * fullUrl=[NSString stringWithFormat:@"%@%@",SXAPIURL,URLString];
    //字符串处理
    NSString * string =[fullUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:fullUrl]];
    [SVProgressHUD showWithStatus:@"数据加载中... "];
    
    [[ServiceAPIManager shareManager]POST:string parameters:parameters progress:^(NSProgress *_Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task,id _Nullable responseObject) {
        [SVProgressHUD dismiss];
        if (success) {
            // --- > 字典类型 --- > json数据 --- >解析数据并传值
            NSError * error =nil;
            //判断是否超时，超时返回登陆页
//            if([responseObject[@"msg"] isEqualToString:@"system.session.timeout"]){
//                UIViewController * vc = [self currentViewController];
//                NSXLoginViewController * loginVC = [NSXLoginViewController new];
//                [vc.navigationController pushViewController:loginVC animated:YES];
//                return;
//            }
            
            if (error !=nil) {
                [SVProgressHUD showErrorWithStatus:@"数据解析失败,请稍后尝试!"];
                return ;
            }
            
            success(responseObject);
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *_Nonnull error) {
        
        [SVProgressHUD showErrorWithStatus:@"请求数据失败,请检查网络后重试!"];
        if (failure) {
            failure(task,error);
        }
    }];
}

+ (void)destroyInstance {
    Token = 0;
    _manager=nil;
}

+ (UIViewController*)currentViewController{
    
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (1) {
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
        }
        
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController*)vc).visibleViewController;
        }
        
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    return vc;
}

@end

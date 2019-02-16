//
//  CommonCodeManager.m
//  shixunLive
//
//  Created by apple on 2018/1/26.
//  Copyright © 2018年 xsili. All rights reserved.
//

#import "CommonCodeManager.h"
#import <ShareSDK/ShareSDK.h>
// 导入头文件
#import <ShareSDKExtension/SSEThirdPartyLoginHelper.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>

#define Token COMMONCODETOKEN
#define UserDataUrl @"/portal/mycenter/getLoginUser"

@implementation CommonCodeManager

+(CommonCodeManager *)shareManager{
    static CommonCodeManager * manager;
    static dispatch_once_t COMMONCODETOKEN;
    dispatch_once(&COMMONCODETOKEN, ^{
        manager =[CommonCodeManager new];
    });
    return manager;
}

//时间戳转换成日期
+(NSString *)changeTimestamp:(NSString *)timeStampString returnType:(int)dateType{
    // iOS 生成的时间戳是10位
    NSTimeInterval interval =[timeStampString doubleValue]/1000.0;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    switch (dateType) {
        case 0:
        {
            [formatter setDateFormat:@"MM月dd日"];
        }
            break;
        case 1:
        {
            [formatter setDateFormat:@"MM月dd日 hh:mm"];
        }
            break;
        case 2:
        {
            [formatter setDateFormat:@"YYYY年-MM月dd日 hh:mm"];
        }
            break;
        case 3:
        {
            [formatter setDateFormat:@"YYYY-MM-dd"];
        }
            break;
        case 4:
        {
            [formatter setDateFormat:@"YYYY-MM-dd hh:mm"];
        }
            break;
        case 5:
        {
            [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
        }
            break;
        default:
            break;
    }
    return [formatter stringFromDate: date];
}

//获取当地时间
- (NSString *)getCurrentTimeWithType:(int)type {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if(type==0){
        [formatter setDateFormat:@"YYYY-MM-dd"];
    }else if(type==1){
        [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    }else if(type==2){
        [formatter setDateFormat:@"MM月dd日"];
    }else if(type==3){
        [formatter setDateFormat:@"YYYY年MM月dd日"];
    }
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    return dateTime;
}

//将字符串转成NSDate类型
- (NSDate *)dateFromString:(NSString *)dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"YYYY年MM月dd日"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    return destDate;
}

- (NSString *)getCurrentDate{
    NSDate*date = [NSDate date];
    NSCalendar*calendar = [NSCalendar currentCalendar];
    NSDateComponents*comps;
    comps =[calendar components:(NSWeekCalendarUnit | NSWeekdayCalendarUnit |NSWeekdayOrdinalCalendarUnit)
                       fromDate:date];
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateFormat:@"MM月dd日EEEE"];
    return [dateFormatter stringFromDate:date];
}

//字符串转换成时间戳
- (NSString *)timestampFromString:(NSString *)dateString withType:(int)type{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if(type==0){
        [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    }else if(type==1){
        [dateFormatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    }else if(type==2){
        [dateFormatter setDateFormat:@"YYYY年MM月dd日"];
    }
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[destDate timeIntervalSince1970]];
    return timeSp;
}

//传入今天的时间，返回明天的时间
- (NSString *)GetTomorrowDay:(NSDate *)Date {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:Date];
    [components setDay:([components day]+1)];
    
    NSDate *beginningOfWeek = [gregorian dateFromComponents:components];
    NSDateFormatter *dateday = [[NSDateFormatter alloc] init];
    [dateday setDateFormat:@"YYYY年MM月dd日"];
    return [dateday stringFromDate:beginningOfWeek];
}

//获取未来一个星期日期数组
-(NSMutableArray *)getOneWeekDateArray{
    NSString * today=[self getCurrentTimeWithType:3];
    NSString * tomorrowDay=[[NSString alloc]init];
    NSMutableArray * dateArray=[NSMutableArray new];
    [dateArray addObject:today];
    for(int i=0;i<6;i++){
        if(i>0){
            today=tomorrowDay;
        }
        tomorrowDay=[self GetTomorrowDay:[self dateFromString:today]];
        [dateArray addObject:tomorrowDay];
    }
    return dateArray;
}


//手机号正则表达式
-(BOOL)checkPhoneNum:(NSString *)mobileNum{
    NSString *MOBILE = @"^1(3[0-9]|4[57]|5[0-35-9]|8[0-9]|7[0678])\\d{8}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    return [regextestmobile evaluateWithObject:mobileNum];
}

-(void)startTimeWithBtn:(UIButton *)btn{
    __block int timeout=59; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置（倒计时结束后调用）
                [btn setTitle:@"获取验证码" forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor lightGrayColor] forState:0];
                btn.layer.borderColor=[UIColor lightGrayColor].CGColor;
                //设置不可点击
                btn.userInteractionEnabled = YES;
                btn.backgroundColor = [UIColor clearColor];
                
            });
        }else{
            //            int minutes = timeout / 60;    //这里注释掉了，这个是用来测试多于60秒时计算分钟的。
            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"%d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                //                NSLog(@"____%@",strTime);
                [btn setTitle:[NSString stringWithFormat:@"%@秒后可重新发送",strTime] forState:UIControlStateNormal];
                //设置可点击
                btn.userInteractionEnabled = NO;
                btn.backgroundColor = [UIColor lightGrayColor];
            });
            timeout--;
        }
    });
    
    dispatch_resume(_timer);
    
}

+ (void)share:(NSString *)url and:(NSString *)title and:(NSString *)description andCoverImg:(NSString *)imgUrl {
    //1、创建分享参数
    NSArray* imageArray = @[imgUrl];
    //（注意：图片必须要在Xcode左边目录里面，名称必须要传正确，如果要分享网络图片，可以这样传iamge参数 images:@[@"http://mob.com/Assets/images/logo.png?v=20150320"]）
    NSString *shareTitle = [title isEqualToString:@""] ? @"分享" : title;
    NSString *sharedescription = [title isEqualToString:@""] ? @"" : description;
    if (imageArray) {
        
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        
        [shareParams SSDKSetupShareParamsByText:sharedescription
                                         images:imageArray
                                            url:[NSURL URLWithString:url]
                                          title:shareTitle
                                           type:SSDKContentTypeAuto];
        //有的平台要客户端分享需要加此方法，例如微博
        //        [shareParams SSDKEnableUseClientShare];
        //2、分享（可以弹出我们的分享菜单和编辑界面）
        [ShareSDK showShareActionSheet:nil //要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图，只有传这个才可以弹出我们的分享菜单，可以传分享的按钮对象或者自己创建小的view 对象，iPhone可以传nil不会影响
                                 items:nil
                           shareParams:shareParams
                   onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                       
                       switch (state) {
                           case SSDKResponseStateSuccess:
                           {
                               NSNotification *notification =[NSNotification notificationWithName:@"shareSuccess" object:nil userInfo:nil];
                               [[NSNotificationCenter defaultCenter] postNotification:notification];
                               //                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                               //                                                                                   message:nil
                               //                                                                                  delegate:nil
                               //                                                                         cancelButtonTitle:@"确定"
                               //                                                                         otherButtonTitles:nil];
                               //                               [alertView show];
                               break;
                           }
                           case SSDKResponseStateFail:
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                               message:[NSString stringWithFormat:@"%@",error]
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                               break;
                           }
                           default:
                               break;
                       }
                   }
         ];}
}

- (void)getUser
{
    [ServiceAPIManager ServiceAPIManagerForGET:UserDataUrl parameters:nil success:^(id  _Nonnull json) {
        NSDictionary *data = [json objectForKey:@"data"];
        NSLog(@"%@",data);
        NSNumber *errorCode = json[@"errorCode"];
        if ([errorCode isEqualToNumber:@0]) {
            NSString *userName = [NSString new];
            if ((NSString *)data[@"userName"] != nil &&  !((data[@"userName"] == [NSNull null]))) {
                userName = [data objectForKey:@"userName"];
            }
            NSString *headerImg = [NSString new];
            if ((NSString *)data[@"headerImg"] != nil && !(data[@"headerImg"] == [NSNull null])) {
                headerImg = [data objectForKey:@"headerImg"];
            }
            NSString *userID = [NSString new];
            if ((NSString *)data[@"id"] != nil && !(data[@"id"] == [NSNull null])) {
                userID = [data objectForKey:@"id"];
            }
            
            int isVip = 0;
            if (data[@"isVip"] != nil && !(data[@"isVip"] == [NSNull null])) {
                isVip = [[data objectForKey:@"isVip"] intValue];
            }
            
            int sex = 0;
            if (data[@"sex"] != nil && !(data[@"sex"] == [NSNull null])) {
                sex = [[data objectForKey:@"sex"] intValue];
            }
            
            NSString *phone = [NSString new];
            if ((NSString *)data[@"phone"] != nil && !(data[@"phone"] == [NSNull null])) {
                phone = [data objectForKey:@"phone"];
            }
            
            NSString *introduceCode = [NSString new];
            if ((NSString *)data[@"introduceCode"] != nil && !(data[@"introduceCode"] == [NSNull null])) {
                introduceCode = [data objectForKey:@"introduceCode"];
            }
            
            NSString * userType = [NSString new];
            if ((NSString *)data[@"typeValue"] != nil && !(data[@"typeValue"] == [NSNull null])) {
                userType = [data objectForKey:@"typeValue"];
            }
            
            NSString * followNum = [NSString new];
            if ((NSString *)data[@"followNum"] != nil && !(data[@"followNum"] == [NSNull null])) {
                followNum = [data objectForKey:@"followNum"];
            }else{
                followNum = @"0";
            }
            
            NSString * fansNum = [NSString new];
            if ((NSString *)data[@"fansNum"] != nil && !(data[@"fansNum"] == [NSNull null] &&[data[@"fansNum"] isKindOfClass:[NSNull class]])) {
                fansNum = [data objectForKey:@"fansNum"];
            }else{
                fansNum = @"0";
            }
            
            [SXAccount sharedAccount].userName = userName;
            [SXAccount sharedAccount].headerImg = headerImg;
            [SXAccount sharedAccount].userID = userID;
            [SXAccount sharedAccount].isVip =isVip;
            [SXAccount sharedAccount].sex=sex;
            [SXAccount sharedAccount].phone = phone;
            [SXAccount sharedAccount].inviteCode = introduceCode;
            [SXAccount sharedAccount].loginUserType = userType;
            [SXAccount sharedAccount].followNum = followNum;
            [SXAccount sharedAccount].fansNum = fansNum;
            [[SXAccount sharedAccount] saveToSandBox];
            NSNotification *noti = [NSNotification notificationWithName:@"account1" object:[SXAccount sharedAccount]];
            [MYNotiCenter postNotification:noti];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSString *errorStr = [error.userInfo objectForKey:@"NSLocalizedDescription"];
        if ([errorStr isEqualToString:@""] || errorStr == NULL) {
            NSLog(@"errorcode 为空");
        }else{
            [SVProgressHUD showErrorWithStatus:errorStr];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
        }
    }];
}

- (NSString *)digitalEmojiToUnicode:(NSString *)string
{
    NSString *version= [UIDevice currentDevice].systemVersion;
    if(version.doubleValue <10.0){
        if(![self stringContainsEmoji:string]){
            return string;
        }
    }
    
    //把微信端上传的表情处理成iOS字符串
    NSString *text = [self htmlToString:string];
    //匹配HTML格式表情正则
    NSString *prefix = @"[^&#]*\\;";
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:prefix
                                                                             options:NSRegularExpressionCaseInsensitive
                                                                               error:nil];
    // 对text字符串进行匹配
    NSArray *matches = [regular matchesInString:text
                                        options:0
                                          range:NSMakeRange(0, text.length)];
    // 遍历匹配后的每一条记录
    NSString *result =  text;
    for (NSTextCheckingResult *match in matches) {
        NSRange range = [match range];
        NSString *target = [text substringWithRange:range];
        NSLog(@"%@", target);
        //把HTML格式的表情转换为Unicode格式的
        NSString *emojiS =[self emojiHTMLToUnicode:target];
        //iOS 端直接支持unicode字符 (有一些高级表情会失败，返回nil)
        NSString *convertUnicode = [self convertSimpleUnicodeStr:emojiS];
        if (convertUnicode.length ==0) {
            convertUnicode = @"❓";
        }
        //把表情替换回原来的位置，然后就能直接用UILabel显示表情了
        result = [result stringByReplacingOccurrencesOfString:[@"&#" stringByAppendingString:target] withString:convertUnicode];
        
    }
    return result;
}

- (BOOL)stringContainsEmoji:(NSString *)string

{
    
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
     
                               options:NSStringEnumerationByComposedCharacterSequences
     
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                
                                const unichar hs = [substring characterAtIndex:0];
                                
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    
                                    if (substring.length > 1) {
                                        
                                        const unichar ls = [substring characterAtIndex:1];
                                        
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            
                                            returnValue = YES;
                                            
                                        }
                                        
                                    }
                                    
                                } else if (substring.length > 1) {
                                    
                                    const unichar ls = [substring characterAtIndex:1];
                                    
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    return returnValue;
}

- (NSString *)emojiHTMLToUnicode:(NSString *)str{
    NSString *result = [str stringByReplacingOccurrencesOfString:@"&#" withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@";" withString:@""];
    NSString *hexString = [NSString stringWithFormat:@"U+%@",[[NSString alloc] initWithFormat:@"%1X",[result intValue]]];
    return hexString;
}

- (NSString *)convertSimpleUnicodeStr:(NSString *)str{
    NSString *strUrl = [str stringByReplacingOccurrencesOfString:@"U+" withString:@""];
    unsigned long  unicodeIntValue= strtoul([strUrl UTF8String],0,16);
    //   UTF32Char inputChar = unicodeIntValue ;// 变成utf32
    unsigned long inputChar = unicodeIntValue ;// 变成utf32
    //    inputChar = NSSwapHostIntToLittle(inputChar); // 转换成Little 如果需要
    inputChar = NSSwapHostLongToLittle(inputChar); // 转换成Little 如果需要
    NSString *sendStr = [[NSString alloc] initWithBytes:&inputChar length:4 encoding:NSUTF32LittleEndianStringEncoding];
    NSLog(@"%@",sendStr);
    return sendStr;
}

- (NSString *)htmlToString:(NSString *)str{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length > 0) {
        return  [[NSAttributedString alloc] initWithData:data options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:[NSNumber numberWithInteger:NSUTF8StringEncoding]} documentAttributes:nil error:nil].string;
    }
    return @"";
}

-(NSString *)ret32bitString{
    NSMutableString * str = [NSMutableString new];
    for(int i = 0 ;i<32;i++){
        int x = arc4random() % 10;
        [str appendString:[NSString stringWithFormat:@"%d",x]];
    }
    return str;
}

@end


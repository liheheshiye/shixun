//
//  CommonCodeManager.h
//  shixunLive
//
//  Created by apple on 2018/1/26.
//  Copyright © 2018年 xsili. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonCodeManager : NSObject

+(CommonCodeManager *)shareManager;
///时间戳转换成日期
+(NSString *)changeTimestamp:(NSString *)timeStampString returnType:(int)dateType;
///获取当前日期
-(NSString *)getCurrentDate;
///获取当地时间
- (NSString *)getCurrentTimeWithType:(int)type;
///将字符串转成NSDate类型
-(NSDate *)dateFromString:(NSString *)dateString;
///字符串转换成时间戳
- (NSString *)timestampFromString:(NSString *)dateString withType:(int)type;
///传入今天的时间，返回明天的时间
-(NSString *)GetTomorrowDay:(NSDate *)Date;
///获取未来一个星期日期数组
-(NSMutableArray *)getOneWeekDateArray;
///手机号正则表达式
-(BOOL)checkPhoneNum:(NSString *)mobileNum;
///验证码倒数计时
-(void)startTimeWithBtn:(UIButton *)btn;
///分享
+ (void)share:(NSString *)url and:(NSString *)title and:(NSString *)description andCoverImg:(NSString *)imgUrl;
///获取用户信息
-(void)getUser;
///表情转换
- (NSString *)digitalEmojiToUnicode:(NSString *)string;
- (BOOL)stringContainsEmoji:(NSString *)string;
///生成32位随机数
-(NSString *)ret32bitString;

@end


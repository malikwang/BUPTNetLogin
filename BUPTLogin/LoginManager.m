//
//  LoginManager.m
//  BUPTLogin
//
//  Created by 王一凡 on 2017/8/17.
//  Copyright © 2017年 王一凡. All rights reserved.
//

#import "LoginManager.h"
#import "AFSessionSingleton.h"

@implementation LoginManager


//刷新页面，返回多种情况


- (void)refreshAndWhetherSendNotification:(BOOL)flag andCompletionBlock:(void (^)(NSDictionary *))completionBlock{
    __block NSString *resHtml = nil;
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);  //很关键
    __block NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    AFHTTPSessionManager *manager = [AFSessionSingleton sharedHttpSessionManager];
    [manager GET:@"http://10.3.8.211" parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        resHtml = [[NSString alloc] initWithData:responseObject encoding:encoding];
        //        NSLog(@"%@",resHtml);
        dispatch_group_leave(group);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        //1代表无法连接
        [data setValue:@"1" forKey:@"responseCode"];
        if (flag) {
            [self sendNotification:@"网络断开" andMessage:@"请检查您的网络连接"];
        }
        dispatch_group_leave(group);
    }];
    dispatch_group_notify(group,dispatch_get_main_queue(),^{
        // 子任务全部完成后，才执行
        if (resHtml != nil && [resHtml rangeOfString:@"请您输入用户名"].location != NSNotFound) {
            //当前未登录且不是网络原因
            if (flag) {
                [self sendNotification:@"提示" andMessage:@"当前未登录，请登录账号"];
            }
            //2代表未登录账户
            [data setValue:@"2" forKey:@"responseCode"];
        } else if (resHtml != nil && [resHtml rangeOfString:@"请您输入用户名"].location == NSNotFound){
            NSString *pattern = @"flow='\\d*";
            NSRange range = [resHtml rangeOfString:pattern options:NSRegularExpressionSearch];
            NSString *substr = [resHtml substringWithRange:range];
            //截取字符串
            NSString *flow = [substr substringFromIndex:6];
            pattern = @"fee='\\d*";
            range = [resHtml rangeOfString:pattern options:NSRegularExpressionSearch];
            substr = [resHtml substringWithRange:range];
            //截取字符串
            NSString *fee = [substr substringFromIndex:5];
            //将字节转换为MB
            float flowMB = [flow floatValue] / 1024;
            float feeY = [fee floatValue] / 10000;
            //0代表已登录状态
            [data setValue:@"0" forKey:@"responseCode"];
            [data setValue:[NSString stringWithFormat:@"%.1f",flowMB] forKey:@"flowUsage"];
            [data setValue:[NSString stringWithFormat:@"%.2f",feeY] forKey:@"feeRemain"];
        }
        completionBlock(data);
    });
}

- (void)loginOut{
    AFHTTPSessionManager *manager = [AFSessionSingleton sharedHttpSessionManager];
    [manager GET:@"http://10.3.8.211/F.htm" parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [self sendNotification:@"提示" andMessage:@"注销成功"];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)loginWithUser:(NSString *)userID andPwd:(NSString *)pwd whetherSendNotification:(BOOL)flag andCompletionBlock:(void (^)(BOOL))completionBlock{
    __block NSString *resHtml = nil;
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);  //很关键
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        AFHTTPSessionManager *manager = [AFSessionSingleton sharedHttpSessionManager];
        NSDictionary *param = @{@"DDDDD":userID,@"upass":pwd,@"savePWD":@"0",@"0MKKey":@""};
        [manager POST:@"http://10.3.8.211" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            resHtml = [[NSString alloc] initWithData:responseObject encoding:encoding];
            dispatch_group_leave(group);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@",error);
            //避免在使用自动登录时，一直弹出提示
            if (flag) {
               [self sendNotification:@"网络断开" andMessage:@"请检查您的网络连接"];
            }
            dispatch_group_leave(group);
            completionBlock(false);
        }];
    });
    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        //说明未能成功登录且不是网络原因
        if (resHtml != nil && [resHtml rangeOfString:@"登录成功窗"].location == NSNotFound) {
            NSString *pattern = @"Msg=\\d\\d";
            NSRange range = [resHtml rangeOfString:pattern options:NSRegularExpressionSearch];
            NSString *substr = [resHtml substringWithRange:range];
            //截取字符串
            NSString *msgCode = [substr substringFromIndex:5];
            NSString *errorStr = [self errorStrReturn:[msgCode intValue]];
            if (flag) {
               [self sendNotification:@"登录失败" andMessage:errorStr]; 
            }
            completionBlock(false);
        } else if (resHtml != nil && [resHtml rangeOfString:@"登录成功窗"].location != NSNotFound){
            [self sendNotification:@"提示" andMessage:@"登录成功"];
            completionBlock(true);
        }
    });
}

//通过错误码返回无法登录的原因
- (NSString *)errorStrReturn:(int)msgCode{
    switch (msgCode) {
        case 4:
            return @"本账号费用超支或时长流量超过限制";
        default:
            return @"账号或密码不对，请重新输入";
    }
}

- (void)sendNotification:(NSString *)title andMessage:(NSString *)message{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = title;
    notification.informativeText = message;
    notification.hasActionButton = YES;
    notification.actionButtonTitle = @"确定";
    notification.otherButtonTitle = @"取消";
    //递交通知
    [[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:notification];
}


//返回当前登录用户账号，暂时难以实现
- (NSString *)whoAmI{
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];  //很关键
//    [manager GET:@"http://10.3.8.211" parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
//        NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);  //很关键
//        resHtml = [NSString stringWithCString:[responseObject bytes] encoding:encoding];
//    } failure:^(NSURLSessionTask *operation, NSError *error) {
//        //检查网络连接提示
//        NSLog(@"Error: %@", error);
//    }];
    return @"";
}



@end

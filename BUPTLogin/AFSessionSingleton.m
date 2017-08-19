//
//  AFSessionSingleton.m
//  BUPTLogin
//
//  Created by 王一凡 on 2017/8/19.
//  Copyright © 2017年 王一凡. All rights reserved.
//

#import "AFSessionSingleton.h"
#import <AFHTTPSessionManager.h>

@implementation AFSessionSingleton

static AFHTTPSessionManager *manager;

+(AFHTTPSessionManager *)sharedHttpSessionManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
        manager.requestSerializer.timeoutInterval = 10.0;
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];  //很关键
    });
    
    return manager;
}

@end

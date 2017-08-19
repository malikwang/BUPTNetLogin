//
//  AFSessionSingleton.h
//  BUPTLogin
//
//  Created by 王一凡 on 2017/8/19.
//  Copyright © 2017年 王一凡. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFHTTPSessionManager.h>

@interface AFSessionSingleton : NSObject
+ (AFHTTPSessionManager *)sharedHttpSessionManager;
@end

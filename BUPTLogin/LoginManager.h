//
//  LoginManager.h
//  BUPTLogin
//
//  Created by 王一凡 on 2017/8/17.
//  Copyright © 2017年 王一凡. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginManager : NSObject

- (void)refreshAndWhetherSendNotification:(BOOL)flag andCompletionBlock:(void (^)(NSDictionary *))completionBlock;
- (void)loginWithUser:(NSString *)userID andPwd:(NSString *)pwd whetherSendNotification:(BOOL)flag andCompletionBlock:(void (^)(BOOL))completionBlock;
- (void)loginOut;
- (NSString *)whoAmI;
@end

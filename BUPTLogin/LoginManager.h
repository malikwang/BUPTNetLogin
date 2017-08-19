//
//  LoginManager.h
//  BUPTLogin
//
//  Created by 王一凡 on 2017/8/17.
//  Copyright © 2017年 王一凡. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginManager : NSObject

- (void)refresh:(void (^)(NSDictionary *))completionBlock;
- (void)loginWithUser:(NSString *)userID andPwd:(NSString *)pwd andCompletionBlock:(void (^)(BOOL))completionBlock;
- (NSString *)whoAmI;
@end

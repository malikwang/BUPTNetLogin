//
//  StatusItemView.h
//  BUPTLogin
//
//  Created by 王一凡 on 2017/8/17.
//  Copyright © 2017年 王一凡. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AccountManager.h"
#import "LoginManager.h"

@interface StatusItemView : NSView

@property (strong, nonatomic) NSStatusItem *item;
@property (nonatomic) BOOL isHighlight;
@property (nonatomic, strong) NSString *flowUsage;
@property (nonatomic, strong) NSString *feeRemain;
@property (strong, nonatomic) NSMutableArray *accountArray;
@property (nonatomic, strong) NSString *currentUser;
@property (nonatomic, strong) NSString *currentPwd;
@property (nonatomic, strong) NSString *plistPath;
@property (nonatomic, strong) AccountManager *accountManager;
@property (nonatomic, strong) LoginManager *loginManager;
- (id)initWithStatusItem:(NSStatusItem *)statusItem;
- (void)refreshStatusBarWithFlow:(NSString *)flow andFee:(NSString *)fee;
- (BOOL)refreshStatusBarAndMenu:(NSMenu *)mainMenu;
@end

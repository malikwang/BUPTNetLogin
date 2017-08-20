//
//  AccountManager.h
//  BUPTLogin
//
//  Created by 王一凡 on 2017/8/17.
//  Copyright © 2017年 王一凡. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AccountManager : NSWindowController
@property (strong, nonatomic) NSMutableArray *accountArray;
@property (weak) IBOutlet NSTableView *accountTableView;
- (IBAction)addAccount:(id)sender;
@property (weak) IBOutlet NSButton *deleteButton;
- (IBAction)deleteAccount:(id)sender;
@property (weak) IBOutlet NSTextField *userID;
@property (weak) IBOutlet NSSecureTextField *userPwd;
- (IBAction)userDidEndEdit:(NSTextField *)sender;
- (IBAction)pwdDidEndEdit:(id)sender;
@property (nonatomic, strong) NSString *plistPath;
@end

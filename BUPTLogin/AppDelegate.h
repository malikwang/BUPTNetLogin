//
//  AppDelegate.h
//  BUPTLogin
//
//  Created by 王一凡 on 2017/8/17.
//  Copyright © 2017年 王一凡. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "StatusItemView.h"
#import "AccountManager.h"
#import "LoginManager.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSMenu *mainMenu;
@property (weak) IBOutlet NSMenuItem *autoRefreshItem;
- (IBAction)login:(id)sender;
- (IBAction)autoRefreshAccount:(id)sender;
- (IBAction)refreshAccount:(id)sender;
- (IBAction)quit:(id)sender;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) StatusItemView *statusItemView;
@property (strong, nonatomic) LoginManager *loginManager;
@property (assign) NSTimer* timer;
@end


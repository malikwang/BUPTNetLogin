//
//  AppDelegate.m
//  BUPTLogin
//
//  Created by 王一凡 on 2017/8/17.
//  Copyright © 2017年 王一凡. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize mainMenu,statusItem,statusItemView,loginManager,timer,autoRefreshItem;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)awakeFromNib{
    [super awakeFromNib];
    loginManager = [[LoginManager alloc] init];
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:40];
    statusItemView = [[StatusItemView alloc] initWithStatusItem:statusItem];
    statusItem.view = statusItemView;
    statusItemView.menu = mainMenu;
    [self refresh];
}



- (IBAction)login:(id)sender {
    [loginManager loginWithUser:statusItemView.currentUser andPwd:statusItemView.currentPwd andCompletionBlock:^(BOOL flag){
        if (flag) {
            [self refresh];
        }
    }];
}

- (void)refresh{
    [statusItemView refreshMenu:mainMenu whetherRefreshStatusBar:YES andCompletionBlock:^(BOOL flag){
        if (!flag) {
            [timer invalidate];
            timer = nil;
            [autoRefreshItem setState:0];
        }
    }];
}

- (IBAction)autoRefreshAccount:(id)sender {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    autoRefreshItem.state = 1;
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector: @selector(refresh) userInfo: nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (IBAction)refreshAccount:(id)sender {
    [self refresh];
}

- (IBAction)quit:(id)sender {
    [NSApp terminate:self];
}

@end

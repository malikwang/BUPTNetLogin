//
//  AppDelegate.m
//  BUPTLogin
//
//  Created by 王一凡 on 2017/8/17.
//  Copyright © 2017年 王一凡. All rights reserved.
//

#import "AppDelegate.h"
#import <AFNetworkReachabilityManager.h>
#import <CoreWLAN/CoreWLAN.h>


@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize mainMenu,statusItem,statusItemView,loginManager,autoRefreshItem,refreshTimer,loginTimer;

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
    [statusItemView refreshStatusBar:NO];
    [statusItemView refreshMenu:mainMenu whetherSendNotification:YES];
}



- (IBAction)loginOut:(id)sender {
    [loginManager loginOut];
}

- (IBAction)login:(id)sender {
    [loginManager loginWithUser:statusItemView.currentUser andPwd:statusItemView.currentPwd whetherSendNotification:YES andCompletionBlock:^(BOOL flag){
        if (flag) {
            [statusItemView refreshStatusBar:NO];
        }
    }];
}

- (void)refresh{
    [statusItemView refreshStatusBar:NO];
}

//为自动登录服务，登录失败不提示
- (void)loginWithoutErrorNotification{
    [loginManager loginWithUser:statusItemView.currentUser andPwd:statusItemView.currentPwd whetherSendNotification:NO andCompletionBlock:^(BOOL flag){
        if (flag) {
            [self refresh];
            [loginTimer invalidate];
            loginTimer = nil;
        }
    }];
}

- (IBAction)autoRefreshAccount:(id)sender {
    [refreshTimer invalidate];
    refreshTimer = nil;
    if (autoRefreshItem.state == 1) {
        [autoRefreshItem setState:0];
    } else {
        [autoRefreshItem setState:1];
        refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector: @selector(refresh) userInfo: nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:refreshTimer forMode:NSRunLoopCommonModes];
    }
}

- (IBAction)refreshAccount:(id)sender {
    [statusItemView refreshStatusBar:YES];
}

- (IBAction)quit:(id)sender {
    [NSApp terminate:self];
}

- (IBAction)autoLogin:(id)sender {
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    NSMenuItem *item = (NSMenuItem *)sender;
    if (item.state == 1) {
        [item setState:0];
        [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
        [loginTimer invalidate];
        loginTimer = nil;
    } else {
        [item setState:1];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        // 检测网络连接的单例,网络变化时的回调方法
        [[AFNetworkReachabilityManager sharedManager]setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            NSLog(@"%ld",(long)status);
            switch (status) {
                case AFNetworkReachabilityStatusUnknown:
                    NSLog(@"网络错误");
                    break;
                    
                case AFNetworkReachabilityStatusNotReachable:
                    NSLog(@"没有连接网络");
                    break;
                    
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    NSLog(@"手机自带网络");
                    break;
                    
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    NSLog(@"有网连接");
                    [loginTimer invalidate];
                    loginTimer = nil;
                    CWInterface* wifi = [[CWWiFiClient sharedWiFiClient] interface];
                    if ([wifi.ssid isEqualToString:@"BUPT-mobile"] || [wifi.ssid isEqualToString:@"bykyl626"]) {
                        break;
                    }
                    loginTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector: @selector(loginWithoutErrorNotification) userInfo: nil repeats:YES];
                    [[NSRunLoop currentRunLoop] addTimer:loginTimer forMode:NSRunLoopCommonModes];
                    break;
                    
            }
        }];
    }
}

@end

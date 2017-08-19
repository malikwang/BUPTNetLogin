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
    [self refresh:^(BOOL flag){
        
    }];
    statusItem.view = statusItemView;
    statusItemView.menu = mainMenu;
    [statusItemView refreshMenu:mainMenu];
}

//刷新，同时返回是否继续的标记
- (void)refresh:(void (^)(BOOL))completionBlock{
    [loginManager refresh:^(NSDictionary *data){
        NSString *responseCode = [data valueForKey:@"responseCode"];
        //说明已登录
        if ([responseCode isEqualToString:@"0"]) {
            NSString *flowUsage = [NSString stringWithFormat:@"%@MB",[data valueForKey:@"flowUsage"]];
            NSString *feeRemain = [NSString stringWithFormat:@"%@元",[data valueForKey:@"feeRemain"]];
            [statusItemView refreshStatusBarWithFlow:flowUsage andFee:feeRemain];
            completionBlock(true);
            NSLog(@"刷新了1");
        } else {
            [statusItemView refreshStatusBarWithFlow:@"null" andFee:@"null"];
            completionBlock(false);
            [timer invalidate];
            timer = nil;
            autoRefreshItem.state = 0;
            NSLog(@"刷新了2");
        }
        data = nil;
    }];
}


- (IBAction)login:(id)sender {
    [loginManager loginWithUser:statusItemView.currentUser andPwd:statusItemView.currentPwd andCompletionBlock:^(BOOL flag){
        if (flag) {
            [self refresh:^(BOOL flag){
                
            }];
            [statusItemView refreshMenu:mainMenu];
        }
    }];
}

- (void)sss{
    dispatch_group_t group = dispatch_group_create();
    // 某个任务放进 group
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"ssss");
    });
    NSLog(@"zzzz");
}

- (IBAction)autoRefreshAccount:(id)sender {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    autoRefreshItem.state = 1;
    timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector: @selector(refresh:) userInfo: nil repeats:NO];
}

- (IBAction)refreshAccount:(id)sender {
    [self refresh:^(BOOL flag){
        
    }];
}

- (IBAction)quit:(id)sender {
    [NSApp terminate:self];
}

@end

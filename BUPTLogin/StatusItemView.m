//
//  StatusItemView.m
//  BUPTLogin
//
//  Created by 王一凡 on 2017/8/17.
//  Copyright © 2017年 王一凡. All rights reserved.
//

#import "StatusItemView.h"
#import "AccountManager.h"

@implementation StatusItemView

@synthesize item,isHighlight,flowUsage,feeRemain,accountArray,currentUser,currentPwd,plistPath,accountManager,loginManager;

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [item drawStatusBarBackgroundInRect:dirtyRect withHighlight: isHighlight];
    NSMutableDictionary *textFormatting = [[self stringAttributes] mutableCopy];
    if (isHighlight) {
        textFormatting[NSForegroundColorAttributeName] = [NSColor whiteColor];
    } else {
        textFormatting[NSForegroundColorAttributeName] = [NSColor blackColor];
    }
    [flowUsage drawInRect:CGRectMake(0, 2, self.frame.size.width, 11) withAttributes:textFormatting];
    [feeRemain drawInRect:CGRectMake(0, 11, self.frame.size.width, 11) withAttributes:textFormatting];
}

- (id)initWithStatusItem: (NSStatusItem *)statusItem{
    self = [super init];
    if (self) {
        item = statusItem;
        loginManager = [[LoginManager alloc] init];
        //为了载入用户以及密码
        NSMenu *menu = [super menu];
        [self refreshAccountMenu:menu];
        isHighlight = NO;
    }
    return self;
}

//更新状态栏
- (void)refreshStatusBarWithFlow:(NSString *)flow andFee:(NSString *)fee{
    //加上单位
    flowUsage = flow;
    feeRemain = fee;
    NSSize s1 = [flowUsage sizeWithAttributes: [self stringAttributes]];
    NSSize s2 = [feeRemain sizeWithAttributes: [self stringAttributes]];
    CGFloat width = s1.width > s2.width ? s1.width : s2.width;
    item.length = width;
    [self setNeedsDisplay:YES];
}



//更新主菜单栏，主要更新账户、登录、是否登录。
- (BOOL)refreshStatusBarAndMenu:(NSMenu *)mainMenu{
    //先刷新账户一栏
    __block BOOL flag = true;
    [self refreshAccountMenu:mainMenu];
    [loginManager refresh:^(NSDictionary *data){
        NSString *responseCode = [data valueForKey:@"responseCode"];
        //说明已登录
        if ([responseCode isEqualToString:@"0"]) {
            [mainMenu itemAtIndex:2].title = @"已登录";
            //登录设置为不可点
            [mainMenu itemAtIndex:3].enabled = NO;
            flowUsage = [NSString stringWithFormat:@"%@MB",[data valueForKey:@"flowUsage"]];
            feeRemain = [NSString stringWithFormat:@"%@元",[data valueForKey:@"feeRemain"]];
            [self refreshStatusBarWithFlow:flowUsage andFee:feeRemain];
        } else if ([responseCode isEqualToString:@"1"]){
            [mainMenu itemAtIndex:2].title = @"请检查您的网络连接";
            //登录设置为不可点
            [mainMenu itemAtIndex:3].enabled = YES;
            [self refreshStatusBarWithFlow:@"null" andFee:@"null"];
            flag = false;
        } else if ([responseCode isEqualToString:@"2"]){
            [mainMenu itemAtIndex:2].title = @"未登录";
            //登录设置为可点
            [mainMenu itemAtIndex:3].enabled = YES;
            [self refreshStatusBarWithFlow:@"null" andFee:@"null"];
            flag = false;
        }
    }];
    return flag;
}

- (void)refreshAccountMenu:(NSMenu *)mainMenu{
    NSMenu *subMenu = [[NSMenu alloc] init];
    subMenu.autoenablesItems = NO;
    plistPath = [[NSBundle mainBundle] pathForResource:@"Account" ofType:@"plist"];
    accountArray = [NSMutableArray arrayWithContentsOfFile:plistPath];
    for (NSDictionary *account in accountArray) {
        if ([[account valueForKey:@"selectState"] intValue] == 1) {
            currentUser = [account valueForKey:@"id"];
            currentPwd = [account valueForKey:@"pwd"];
            //设置账户Item显示当前选择的ID
            [mainMenu itemAtIndex:0].title = [NSString stringWithFormat:@"账户：%@",currentUser];
        }
    }
    if (accountArray == nil) {
        NSMenuItem *tipItem = [[NSMenuItem alloc] init];
        tipItem.title = @"当前无账号";
        tipItem.enabled = NO;
        [subMenu addItem:tipItem];
    } else {
        for (NSDictionary *account in accountArray) {
            NSMenuItem *accountItem = [[NSMenuItem alloc] initWithTitle:[account valueForKey:@"id"] action:@selector(itemSelected:) keyEquivalent:@""];
            //这个很重要
            accountItem.target = self;
            if ([[account valueForKey:@"selectState"] isEqualToString:@"1"]) {
                [accountItem setState:1];
            }
            [subMenu addItem:accountItem];
        }
    }
    [subMenu addItem:[NSMenuItem separatorItem]];
    NSMenuItem *addAccountItem = [[NSMenuItem alloc] initWithTitle:@"添加账号" action:@selector(showAccountWindow) keyEquivalent:@""];
    addAccountItem.target = self;
    //添加动作
    addAccountItem.enabled = YES;
    [subMenu addItem:addAccountItem];
    [[mainMenu itemAtIndex:0] setSubmenu:subMenu];
}

- (void)itemSelected:(NSMenuItem *)accountItem{
    [self updateSelectInPlist:accountItem.title];
}

//更新Plist中的选中状态
- (void)updateSelectInPlist:(NSString *)userID{
    for (NSDictionary *account in accountArray) {
        if ([[account valueForKey:@"id"] isEqualToString:userID]) {
            [account setValue:@"1" forKey:@"selectState"];
        } else{
            [account setValue:@"0" forKey:@"selectState"];
        }
    }
    [accountArray writeToFile:plistPath atomically:YES];
    //再次更新
    [self refreshAccountMenu:[super menu]];
}

- (void)showAccountWindow{
    if (!accountManager) {
        accountManager = [[AccountManager alloc] initWithWindowNibName: @"AccountManager"];
    }
    [NSApp activateIgnoringOtherApps:YES];
    [[accountManager window] center];
    [accountManager showWindow: self];
}

- (void)mouseDown:(NSEvent *)event{
    NSMenu *menu = [super menu];
    [item popUpStatusItemMenu:menu];
    [self refreshStatusBarAndMenu:menu];
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)event{
    isHighlight = NO;
    [self setNeedsDisplay:YES];
}

////右键显示菜单
//- (void)rightMouseDown:(NSEvent *)event{
//    NSMenu *menu = [super menu];
//    [item popUpStatusItemMenu:menu];
//    [self refreshMenu:menu];
//    [self setNeedsDisplay:YES];
//}

- (void)willOpenMenu:(NSMenu *)menu withEvent:(NSEvent *)event{
    isHighlight = YES;
    [self setNeedsDisplay:YES];
}

- (void)didCloseMenu:(NSMenu *)menu withEvent:(NSEvent *)event{
    isHighlight = NO;
    [self setNeedsDisplay:YES];
}

- (NSDictionary *)stringAttributes{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentRight;
    return @{ NSFontAttributeName : [NSFont menuBarFontOfSize: 9],NSParagraphStyleAttributeName : style};
}



@end

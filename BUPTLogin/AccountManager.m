//
//  AccountManager.m
//  BUPTLogin
//
//  Created by 王一凡 on 2017/8/17.
//  Copyright © 2017年 王一凡. All rights reserved.
//

#import "AccountManager.h"

@interface AccountManager ()<NSTableViewDelegate,NSTableViewDataSource>

@end

@implementation AccountManager

@synthesize accountArray,accountTableView,deleteButton,userID,userPwd,plistPath;

- (void)windowDidLoad {
    [super windowDidLoad];
    plistPath = [[NSBundle mainBundle] pathForResource:@"Account" ofType:@"plist"];
    accountArray = [NSMutableArray arrayWithContentsOfFile:plistPath];
    deleteButton.enabled = NO;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return accountArray.count;
}

//选中并更新账号与密码输入框
- (void)tableViewSelectionDidChange:(NSNotification *)notification{
//    NSLog(@"%lu",[accountTableView selectedRow]);
    NSInteger selectedRow = [accountTableView selectedRow];
    if (selectedRow >= 0 && accountArray.count > selectedRow) {
        deleteButton.enabled = YES;
        userID.stringValue = [accountArray[selectedRow] valueForKey:@"id"];
        userPwd.stringValue = [accountArray[selectedRow] valueForKey:@"pwd"];
    } else {
        deleteButton.enabled = NO;
        userID.stringValue = @"";
        userPwd.stringValue = @"";
    }
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    // 1.创建可重用的cell:
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    // 2. 根据重用标识，设置cell 数据
    if( [tableColumn.identifier isEqualToString:@"AccountColumn"]){
        cellView.textField.stringValue = [accountArray[row] valueForKey:@"id"];
        //根据状态显示当前前面是否有图片
        if ([[accountArray[row] valueForKey:@"selectState"] isEqualToString:@"0"]) {
            cellView.imageView.image = nil;
        }
        return cellView;
    }
    return cellView;
}

//添加新账号
- (IBAction)addAccount:(id)sender {
    [self addAccountInArray];
    NSInteger newRowIndex = accountArray.count - 1;
    // 1. 在table view 中插入新行
    [accountTableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:newRowIndex] withAnimation:NSTableViewAnimationEffectGap];
    // 2. 设置新行选中，并可见，此时重新更新了视图！！
    [accountTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:newRowIndex] byExtendingSelection:NO];
    [accountTableView scrollRowToVisible:newRowIndex];
    
}

- (void)addAccountInArray{
    NSMutableDictionary *account = [[NSMutableDictionary alloc] init];
    [account setValue:@"新账号" forKey:@"id"];
    [account setValue:@"" forKey:@"pwd"];
    [account setValue:@"0" forKey:@"selectState"];
    //添加到数组中
    [accountArray addObject:account];
    [accountArray writeToFile:plistPath atomically:YES];
}

- (void)deleteAccountInArray:(NSInteger)selectRow{
    [accountArray removeObjectAtIndex:selectRow];
    [accountArray writeToFile:plistPath atomically:YES];
}

- (void)updateAccountArray:(NSInteger)selectRow{
    NSMutableDictionary *account = accountArray[selectRow];
    [account setValue:userID.stringValue forKey:@"id"];
    [account setValue:userPwd.stringValue forKey:@"pwd"];
    [accountArray writeToFile:plistPath atomically:YES];
}

- (IBAction)deleteAccount:(id)sender {
    NSInteger selectedRow = [accountTableView selectedRow];
    [self deleteAccountInArray:selectedRow];
    [accountTableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:selectedRow] withAnimation:NSTableViewAnimationEffectGap];
    //如果删除第一行，显示下一个
    if (selectedRow == 0) {
        selectedRow = 1;
    }
    [accountTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow - 1] byExtendingSelection:NO];
    [accountTableView scrollRowToVisible:selectedRow - 1];
}

//离开点击的输入框，会触发该事件
- (IBAction)userDidEndEdit:(NSTextField *)sender {
    NSInteger selectedRow = [accountTableView selectedRow];
    [self updateAccountArray:selectedRow];
    [accountTableView reloadData];
}

- (IBAction)pwdDidEndEdit:(id)sender {
    NSInteger selectedRow = [accountTableView selectedRow];
    [self updateAccountArray:selectedRow];
}


@end

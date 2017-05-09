//
//  RemindViewController.m
//  Oncenote
//
//  Created by user on 16/8/3.
//  Copyright © 2016年 chenyufengweb. All rights reserved.
//

#import "RemindViewController.h"
#import "AllUtils.h"

@interface RemindViewController ()

@property (weak, nonatomic) UITextView *remindTextView; // 提醒功能中的TextView
@end

@implementation RemindViewController
//通知
- (void)scheduleLocalNotificationWithDate:(NSDate *)fireDate
{
    //0.创建推送
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    //1.设置推送类型
    UIUserNotificationType type = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    //2.设置setting(设置类型)
    UIUserNotificationSettings *setting  = [UIUserNotificationSettings settingsForTypes:type categories:nil];
    //3.主动授权
    [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    //4.设置推送时间
    [localNotification setFireDate:fireDate];
    //5.设置时区
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    //6.推送内容
    [localNotification setAlertBody:@"Time to wake up!"];
    //7.推送声音
    [localNotification setSoundName:@"Thunder Song.m4r"];
    //8.添加推送到UIApplication
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}


- (void)testMethod
{
    CGFloat space = 20;
    CGFloat remindViewW = super.view.bounds.size.width - space * 2;
    CGFloat remindViewH = (super.view.bounds.size.height)/2;
    CGFloat x = space;
    CGFloat y = remindViewH / 2;
    UIView *remindView = [[UIView alloc] initWithFrame:CGRectMake(x, y, remindViewW, remindViewH)];
    remindView.backgroundColor = [UIColor blackColor];
    remindView.layer.cornerRadius = 10;
    UIDatePicker *datePicker = [[UIDatePicker alloc] init]; datePicker.datePickerMode = UIDatePickerModeDate;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n" message:nil 　　preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert.view addSubview:datePicker];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        
        //实例化一个NSDateFormatter对象
        
        [dateFormat setDateFormat:@"yyyy-MM-dd"];//设定时间格式
        
        NSString *dateString = [dateFormat stringFromDate:datePicker.date];
        
        //求出当天的时间字符串
        
        NSLog(@"%@",dateString);
        
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        　 }];
    
    [alert addAction:ok];
    
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:^{ }];
}






- (void)remindAction
{
    NSLog(@"调用了提醒的监听方法");
    
    CGFloat space = 20;
    CGFloat remindViewW = self.view.bounds.size.width - space * 2;
    CGFloat remindViewH = (self.view.bounds.size.height)/2;
    CGFloat x = space;
    CGFloat y = remindViewH / 2;
    UIView *remindView = [[UIView alloc] initWithFrame:CGRectMake(x, y, remindViewW, remindViewH)];
    remindView.backgroundColor = [UIColor blackColor];
    remindView.layer.cornerRadius = 10;
    
    
    // 添加取消按钮
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(space, space-5, 40, 40)];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor colorWithRed:0 green:0.6 blue:0.26 alpha:1] forState:UIControlStateNormal];
    
    [cancelBtn addTarget:self action:@selector(cancelBtnACtion) forControlEvents:UIControlEventTouchUpInside];
    
    [remindView addSubview:cancelBtn];
    
    
    // 添加确定按钮
    UIButton *OKBtn = [[UIButton alloc]initWithFrame:CGRectMake(remindViewW-space*3, space-5, 40, 40)];
    [OKBtn setTitle:@"确定" forState:UIControlStateNormal];
    [OKBtn setTitleColor:[UIColor colorWithRed:0 green:0.6 blue:0.26 alpha:1] forState:UIControlStateNormal];
    [OKBtn addTarget:self action:@selector(OKRemindAction) forControlEvents:UIControlEventTouchUpInside];
    
    [remindView addSubview:OKBtn];
    
    
    
    // 提醒时间
    UIButton *remindDateBtn = [[UIButton alloc] initWithFrame:CGRectMake(remindViewW / 2 - 35, space-5, 80, 40)];
    [remindDateBtn setTitle:@"提醒时间" forState:UIControlStateNormal];
    
    [remindDateBtn setTitleColor:[UIColor colorWithRed:0 green:0.6 blue:0.26 alpha:1] forState:UIControlStateNormal];
    [remindDateBtn addTarget:self action:@selector(remindDate) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    [remindView addSubview:remindDateBtn];
    
    
    // textView
    self.remindTextView.frame = CGRectMake(0, space*3, remindViewW, remindViewH-space*2);
    [remindView addSubview:self.remindTextView];
    
    
    [super.view addSubview:remindView];

}


//  提醒 功能 确定  按钮 监听方法
- (void)OKRemindAction
{
    NSLog(@"调用了提醒 功能 确定  按钮 监听方法");
    NSString *noteText = [self.remindTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    
    
}


// 提醒时间的监听方法
- (void)remindDate
{
    NSLog(@"调用了提醒时间的监听方法");
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"时间" message:nil 　preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert.view addSubview:datePicker];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        
        //实例化一个NSDateFormatter对象
        
        [dateFormat setDateFormat:@"yyyy-MM-dd"];//设定时间格式
        
        NSString *dateString = [dateFormat stringFromDate:datePicker.date];
        
        //求出当天的时间字符串
        
        NSLog(@"%@",dateString);
        
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        　 }];
    
    [alert addAction:ok];
    
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:^{ }];
    
    
    
}

// 提示视图 取消按钮  的监听方法
- (void)cancelBtnACtion
{
    [AllUtils jumpToViewController:@"MainViewController" contextViewController:self handler:nil];
    
}




@end

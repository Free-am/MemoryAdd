//
//  RemindView.m
//  Menory
//
//  Created by user on 16/10/21.
//  Copyright © 2016年 Corbin. All rights reserved.
//

#import "RemindView.h"

@implementation RemindView

+ (instancetype)defaultPopupView{
    return [[RemindView alloc]initWithFrame:CGRectMake(0, 0, 298, 300)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSBundle mainBundle] loadNibNamed:@"RemindView" owner:self options:nil];
        self.remindView.frame = frame;
        self.remindView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        
        self.remindView.alpha = 0;
        self.remindView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.remindView];
        [UIView animateWithDuration:0.5 animations:^{
            self.remindView.transform = CGAffineTransformMakeScale(1, 1);
            self.remindView.alpha = 1;
        } completion:^(BOOL finished) {
            
            
            
        }];

//        [self addSubview:self.remindView];
    }
    self.remindView.layer.cornerRadius = 10;
    self.barView.layer.cornerRadius = 10;
    return self;
}

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










@end

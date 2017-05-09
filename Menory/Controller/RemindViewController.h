//
//  RemindViewController.h
//  Oncenote
//
//  Created by user on 16/8/3.
//  Copyright © 2016年 chenyufengweb. All rights reserved.
//

#import "MainViewController.h"

@interface RemindViewController : MainViewController

- (void)test;
- (void)remindAction;
- (void)scheduleLocalNotificationWithDate:(NSDate *)fireDate;
@end

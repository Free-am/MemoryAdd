//
//  RemindView.h
//  Menory
//
//  Created by user on 16/10/21.
//  Copyright © 2016年 Corbin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMCalendar.h"
@interface RemindView : UIView <PMCalendarControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *remindView;
@property (weak, nonatomic) IBOutlet UIView *barView;

@property (weak, nonatomic) IBOutlet UITextView *remindText;

@property (weak, nonatomic) IBOutlet UILabel *dateLbl;


@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UIButton *DateBtn;
@property (weak, nonatomic) IBOutlet UIImageView *img;

+ (instancetype)defaultPopupView;
- (void)scheduleLocalNotificationWithDate:(NSDate *)fireDate;
@end

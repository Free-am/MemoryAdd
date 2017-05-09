//
//  billCount.h
//  Menory
//
//  Created by user on 16/10/31.
//  Copyright © 2016年 Corbin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface billCountView : UIView
@property (strong, nonatomic) IBOutlet UIView *billCountView;
@property (weak, nonatomic) IBOutlet UITextField *billCountText;
@property (weak, nonatomic) IBOutlet UIButton *billViewXibSave;
@property (weak, nonatomic) IBOutlet UITextField *billComment;
@property (weak, nonatomic) IBOutlet UILabel *billDate;
@property (weak, nonatomic) IBOutlet UIButton *billDateBtn;
+ (instancetype)defaultPopupView;

@end

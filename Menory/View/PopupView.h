//
//  PopupView.h
//  LewPopupViewController
//
//  Created by deng on 15/3/5.
//  Copyright (c) 2015年 pljhonglu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopupView : UIView
@property (strong, nonatomic) IBOutlet UITableView *innerView;

@property (nonatomic, weak)UIViewController *parentVC;


+ (instancetype)defaultPopupView;
@end

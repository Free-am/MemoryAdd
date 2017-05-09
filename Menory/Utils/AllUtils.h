//
//  AllUtils.h
//  Oncenote
//
//  Created by chenyufeng on 15/11/15.
//  Copyright © 2015年 chenyufengweb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AllUtils : NSObject

+ (NSString *)getDateFromString:(NSString*)date;

+ (UIAlertController*)showPromptDialog:(NSString*)title andMessage:(NSString*)message OKButton:(NSString*)OKButtonTitle OKButtonAction:(void (^)(UIAlertAction *action))OKButtonHandler cancelButton:(NSString*)cancelButtonTitle cancelButtonAction:(void (^)(UIAlertAction *action))cancelButtonHandler contextViewController:(UIViewController*)contextViewController;

+ (void)jumpToViewController:(NSString*)viewControllerIdentifier contextViewController:(UIViewController*)contextViewController handler:(void (^)(void))handler;

//  设置View的背景图片
+ (void)setBackImage:(UIView *)myView imageName:(NSString *)imgName;

// 弹出label显示提醒
+ (void)showLblToRemind:(UIView *)view backgroundColor:(UIColor*)myBackgroundColor textColor:(UIColor*)textColor message:(NSString*)message animateWithDuration:(double)time alpha:(CGFloat)alpha;

// 计算天数
+ (int)intervalSinceNow1: (NSString *) theDate;
@end

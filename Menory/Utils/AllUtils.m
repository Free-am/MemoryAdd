
//
//  AllUtils.m
//  Oncenote
//
//  Created by chenyufeng on 15/11/15.
//  Copyright © 2015年 chenyufengweb. All rights reserved.
//

#import "AllUtils.h"

@implementation AllUtils

#pragma mark - 获取日期
+ (NSString *)getDateFromString:(NSString*)date{
  
  NSString *str = date;
  NSMutableString *reverseString = [NSMutableString string];
  for(int i = 0 ; i < str.length; i ++){

    //倒序读取字符并且存到可变数组数组中
    unichar c = [str characterAtIndex:str.length- i -1];
    [reverseString appendFormat:@"%c",c];
  }
  str = reverseString;
  //  NSLog(@"%@",str);//date已经逆转；
  NSString *b = [str substringFromIndex:8];//截取后8位；
  NSString * str2 = b;
  NSMutableString * reverseString2 = [NSMutableString string];
  for(int i = 0 ; i < str2.length; i ++){

    //倒序读取字符并且存到可变数组数组中
    unichar c = [str2 characterAtIndex:str2.length- i -1];
    [reverseString2 appendFormat:@"%c",c];
  }
  str2 = reverseString2;
  //  NSLog(@"%@",str2);//date转换完毕
  return str2;
}

#pragma mark - 弹出提示对话框
+ (UIAlertController*)showPromptDialog:(NSString*)title andMessage:(NSString*)message OKButton:(NSString*)OKButtonTitle OKButtonAction:(void (^)(UIAlertAction *action))OKButtonHandler cancelButton:(NSString*)cancelButtonTitle cancelButtonAction:(void (^)(UIAlertAction *action))cancelButtonHandler contextViewController:(UIViewController*)contextViewController{
  
  //尝试使用新的弹出对话框；
  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
  [alertController addAction:[UIAlertAction actionWithTitle:OKButtonTitle style:UIAlertActionStyleDefault handler:OKButtonHandler]];
  
  if ([cancelButtonTitle isEqualToString:@""]) {

    //表示不需要“取消”按钮；
  }else{

  //需要“取消”按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleDefault handler:cancelButtonHandler]];
  }
  //弹出提示框；
  [contextViewController presentViewController:alertController animated:true completion:nil];
  return alertController;
}

#pragma mark - 界面跳转封装
//该方法的界面跳转不能传递数据；


+ (void)jumpToViewController:(NSString*)viewControllerIdentifier contextViewController:(UIViewController*)contextViewController handler:(void (^)(void))handler{

  UIViewController *viewController = [[UIViewController alloc] init];
  viewController = [contextViewController.storyboard instantiateViewControllerWithIdentifier:viewControllerIdentifier];
  [contextViewController presentViewController:viewController animated:true completion:handler];
}

+ (void)setBackImage:(UIView *)myView imageName:(NSString *)imgName
{
    UIImage *image = [UIImage imageNamed:imgName];
    myView.layer.contents = (id)image.CGImage; // 设置背景透明
    
    myView.layer.backgroundColor = [UIColor clearColor].CGColor;
}

// 弹出label 提醒
+ (void)showLblToRemind:(UIView *)view backgroundColor:(UIColor*)myBackgroundColor textColor:(UIColor*)textColor message:(NSString*)message animateWithDuration:(double)time alpha:(CGFloat)alpha
{
    //    2创建一个Label来显示提示信息
    //    2.1 创建一个Label
    UILabel *msgLabel = [[UILabel alloc] init];
    //    2.2 设置Label的位置
    CGFloat msgLabelW = 150;
    CGFloat msgLabelH = 30;
    CGFloat msgLabelX = (view.frame.size.width - msgLabelW) * 0.5;
    CGFloat msgLabelY = (view.frame.size.height - msgLabelH) * 0.5;
    msgLabel.frame = CGRectMake(msgLabelX, msgLabelY, msgLabelW, msgLabelH);
    //    2.3 添加
    [view addSubview:msgLabel];
    //    2.4 设置背景颜色
    msgLabel.backgroundColor = myBackgroundColor;
    //    2.5 设置透明度
    msgLabel.alpha = 0.0;
    //    2.6 设置文字
    msgLabel.text = message;
    //    2.7 设置文字颜色
    [msgLabel setTextColor:textColor];
    //    2.8  使文字居中
    msgLabel.textAlignment = NSTextAlignmentCenter;
    //    2.9  圆角
    //    2.9.1 设置半径
    msgLabel.layer.cornerRadius = 8;
    //    2.9.2 切掉多余的部分
    msgLabel.layer.masksToBounds = YES;
    //     设置动画
    //    animateWithDuration:执行动画的时间
    //    animations:执行动画代码
    //    completion:动画完成后做的事情
    [UIView animateWithDuration:time animations:^{
        msgLabel.alpha = alpha;
    } completion:^(BOOL finished) {
        if (finished) {
            //            delay:表示动画延迟多长时间后执行
            [UIView animateWithDuration:time delay:time options:UIViewAnimationOptionCurveLinear animations:^{
                msgLabel.alpha = 0.0;
            } completion:^(BOOL finished) {
                [msgLabel removeFromSuperview];
            }];
        }
    }];

}


// 计算天数
//计算两个日期之间的天数
+ (int)intervalSinceNow1: (NSString *) theDate
{
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd"];//设置时间格式//很重要
    NSDate *d=[date dateFromString:theDate];
    NSLog(@"d--%@",d);
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSLog(@"dat---%@",dat);
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    NSTimeInterval cha=now-late;
    if (cha/86400>1) {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        return [timeString intValue];
    }
    return -1;
}

@end

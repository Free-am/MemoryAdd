//
//  MLFloatButton.h
//  MartinDemos
//
//  Created by Gao Huang on 14-11-25.
//  Copyright (c) 2014年 Martin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MLFloatButtonDelegate <NSObject>
-(void)buttonTouchAction;

@end

@interface MLFloatButton : UIButton
+(MLFloatButton *)loadFromNibWithFrame:(CGRect)frame addTarget:(id)target InSuperView:(UIView *)superView;
-(void)showInFatherView:(UIView *)fatherView;
@property(nonatomic,strong)UIView *fatherView;
@property(nonatomic,strong)id<MLFloatButtonDelegate> floatButtonDelegate;
@end

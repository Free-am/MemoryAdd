//
//  billCount.m
//  Menory
//
//  Created by user on 16/10/31.
//  Copyright © 2016年 Corbin. All rights reserved.
//

#import "billCountView.h"

@implementation billCountView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSBundle mainBundle] loadNibNamed:[[self class] description] owner:self options:nil];
        _billCountView.frame = frame;
        [self addSubview:_billCountView];
    }
    return self;
}

+ (instancetype)defaultPopupView{
    return [[billCountView alloc]initWithFrame:CGRectMake(0, 0, 227, 187)];
}


@end

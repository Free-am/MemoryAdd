//
//  MLFloatButton.m
//  MartinDemos
//
//  Created by Gao Huang on 14-11-25.
//  Copyright (c) 2014年 Martin. All rights reserved.
//

#import "MLFloatButton.h"
#define StatusBarFrame [[UIApplication sharedApplication] statusBarFrame]
@interface MLFloatButton()
{
    BOOL isMoving;
}
@end
@implementation MLFloatButton

+(MLFloatButton *)loadFromNibWithFrame:(CGRect)frame addTarget:(id)target InSuperView:(UIView *)superView{
    static MLFloatButton *button = nil;
    static dispatch_once_t once;
    dispatch_once(&once,^{
        NSString *xibName = NSStringFromClass([self class]);
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:xibName owner:self options:nil];
        button = nib[0];
        [button addTarget:button action:@selector(dragDidMoving:withEvent:) forControlEvents:UIControlEventTouchDragInside];
        [button addTarget:button action:@selector(didTouched:withEvent:) forControlEvents:UIControlEventTouchUpInside];
        button.frame = frame;
    });
    button.floatButtonDelegate = target;
    [superView addSubview:button];
    button.fatherView = superView;

    return button;
}

-(void)showInFatherView:(UIView *)fatherView{
    [fatherView addSubview:self];
    self.fatherView = fatherView;
}

- (void)dragDidMoving:(MLFloatButton *)button withEvent:(UIEvent *)ev
{
    isMoving = YES;
    CGPoint point = [[[ev allTouches] anyObject] locationInView:button.fatherView];
    float halfWidth = button.frame.size.width/2;
    float halfHeight = button.frame.size.height/2;
    float rightEdge = button.fatherView.frame.size.width-halfWidth;
    float topEdge = button.fatherView.frame.origin.y+StatusBarFrame.size.height+44+halfHeight;
    float bottomEdge = button.fatherView.frame.size.height-halfHeight;
    if (point.x<=halfWidth) {
        point.x=halfWidth;
    }else if(point.x>=rightEdge){
        point.x = rightEdge;
    }
    if(point.y<=topEdge){
        point.y = topEdge;
    }else if(point.y>=bottomEdge){
        point.y = bottomEdge;
    }
    button.center = point;
}

- (void)didTouched:(MLFloatButton *)button withEvent:(UIEvent *)ev{
    if (!isMoving) {
        [button.floatButtonDelegate buttonTouchAction];
    }else{
        isMoving = NO;
        
        CGPoint point = [[[ev allTouches] anyObject] locationInView:button.fatherView];
        float halfWidth = button.frame.size.width/2;
        float halfHeight = button.frame.size.height/2;
        float rightEdge = button.fatherView.frame.size.width-halfWidth;
        float topEdge = button.fatherView.frame.origin.y+StatusBarFrame.size.height+44+halfHeight;
        float bottomEdge = button.fatherView.frame.size.height-halfHeight;
        
        //上右下左 0 1 2 3
        float valueTop = point.y-topEdge;  //0
        float valueRight = rightEdge-point.x;  //1
        float valueBottom = bottomEdge-point.y;  //2
        float valueLeft = point.x-halfWidth;  //3
        
        float min = valueTop;
        int tag = 0;

        if (valueRight<min) {
            min=valueRight;
            tag = 1;
        }
        if (valueBottom<min) {
            min=valueBottom;
            tag =2;
        }
        if (valueLeft<min) {
            min = valueLeft;
            tag = 1;  //由于考虑到navigation左滑会有返回的效果，所以尽量不让button停靠在左边。
        }
        
        if (tag==0) {
            [UIView animateWithDuration:0.5 animations:^(void){
                button.center = CGPointMake(point.x, topEdge);
            }];
        }else if(tag==1){
            [UIView animateWithDuration:0.5 animations:^(void){
                button.center = CGPointMake(rightEdge, point.y);
            }];
        }else if(tag==2){
            [UIView animateWithDuration:0.5 animations:^(void){
                button.center = CGPointMake(point.x, bottomEdge);
            }];
        }else if(tag==3){
            [UIView animateWithDuration:0.5 animations:^(void){
                button.center = CGPointMake(halfWidth, point.y);
            }];
        }
        
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


@end

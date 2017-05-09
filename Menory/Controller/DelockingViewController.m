//
//  DelockingViewController.m
//  Menory
//
//  Created by user on 16/9/20.
//  Copyright © 2016年 Corbin. All rights reserved.
//

#import "DelockingViewController.h"
#import "CLLockVC.h"
#import "AllUtils.h"

@interface DelockingViewController ()

@end

@implementation DelockingViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    BOOL hasPwd = [CLLockVC hasPwd];
    
    if (!hasPwd) {
        [self setPwd];
    }else {
        [self verifyPwd];
        
    }

}


- (void)viewDidLoad {
    [super viewDidLoad];
    
      
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
  
}


/*
 *  设置密码
 */

- (void)setPwd {
    
    
    BOOL hasPwd = [CLLockVC hasPwd];
    hasPwd = NO;
    if(hasPwd){
        
        NSLog(@"已经设置过密码了，你可以验证或者修改密码");
    }else{
        
        [CLLockVC showSettingLockVCInVC:self successBlock:^(CLLockVC *lockVC, NSString *pwd) {
                        NSLog(@"密码设置成功");
            [lockVC dismiss:1.0f];
            

        }];
    }
}


//   验证密码

- (void)verifyPwd {
    
    BOOL hasPwd = [CLLockVC hasPwd];
    
    if(!hasPwd){
        
        NSLog(@"你还没有设置密码，请先设置密码");
    }else {
        
        [CLLockVC showVerifyLockVCInVC:self forgetPwdBlock:^{
            NSLog(@"忘记密码");
        } successBlock:^(CLLockVC *lockVC, NSString *pwd) {
            [AllUtils jumpToViewController:@"MainViewController" contextViewController:self handler:nil];

            NSLog(@"密码正确");
//            [lockVC dismiss:1.0f];
           
            
            

        }];
    }
}



//  修改密码

- (void)modifyPwd {
    
    BOOL hasPwd = [CLLockVC hasPwd];
    
    if(!hasPwd){
        
        NSLog(@"你还没有设置密码，请先设置密码");
        
    }else {
        
        [CLLockVC showModifyLockVCInVC:self successBlock:^(CLLockVC *lockVC, NSString *pwd) {
            
            [lockVC dismiss:.5f];
        }];
    }
    
}




@end

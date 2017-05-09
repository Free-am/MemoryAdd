//
//  AboutAppViewController.m
//  Oncenote
//
//  Created by chenyufeng on 15/11/17.
//  Copyright © 2015年 chenyufengweb. All rights reserved.
//

#import "AboutAppViewController.h"
#import "AllUtils.h"

@interface AboutAppViewController ()
@property (strong, nonatomic) IBOutlet UIView *allview;

@end

@implementation AboutAppViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    [AllUtils setBackImage:self.allview imageName:@"主页背景.png"];
}

- (IBAction)naviBackButtonPressed:(id)sender {
  
  [AllUtils jumpToViewController:@"SettingViewController" contextViewController:self handler:nil];
}

@end

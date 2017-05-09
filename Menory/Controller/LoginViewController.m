
//
//  LoginViewController.m
//  Oncenote
//
//  Created by chenyufeng on 15/11/13.
//  Copyright © 2015年 chenyufengweb. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"
#import <BmobSDK/Bmob.h>
#import "AppDelegate.h"
#import "AllUtils.h"
#import "Constant.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property(nonatomic,strong) AppDelegate *globalApp;
- (IBAction)visitorLogin:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIView *myView;

// 忘记密码
@property (weak, nonatomic) IBOutlet UIButton *forgetPwsBtn;
// 登录
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
// 创建账户
@property (weak, nonatomic) IBOutlet UIButton *creatUseBtn;


//  单例 对象
@property(nonatomic,strong) NSUserDefaults *userDefaults;

@end

@implementation LoginViewController

- (void)viewDidLoad {

  [super viewDidLoad];
  self.globalApp = [[UIApplication sharedApplication] delegate];
  self.userDefaults = [NSUserDefaults standardUserDefaults];
    [AllUtils setBackImage:self.myView imageName:@"木质背景.png"];
    
    // 字体适配
    UIFont *fontSize = [UIFont systemFontOfSize:14*self.view.bounds.size.width/320];
    
    self.forgetPwsBtn.font = fontSize;
    self.loginBtn.font = fontSize;
    self.creatUseBtn.font = fontSize;

}

#pragma mark - 所有的按钮点击；
//   登陆按钮
- (IBAction)loginButtonPressed:(id)sender {
  NSString *username = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  //在这里进行查询，登录；
  BmobQuery *query = [BmobQuery queryWithClassName:USER_TABLE];
   
    
  [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
    if (!error) {
      
//        BOOL isSuccessful = true;
      BOOL isSuccessful = false;
        
        
      for (BmobObject *obj in array) {
        
        if ([[obj objectForKey:@"username"] isEqualToString:username] && [[obj objectForKey:@"Password"] isEqualToString:password]) {
          //表示登录成功；
          //登录成功要进行一次查询，查询出该用户的nickname；
          NSString *nickname = [obj objectForKey:@"nickname"];
          
          self.globalApp.GLOBAL_NICKNAME = nickname;
          self.globalApp.GLOBAL_USERNAME = username;
          self.globalApp.GLOBAL_USERID = [obj objectForKey:@"objectId"];
          self.globalApp.GLOBAL_PASSWORD = password;
          
          [self.userDefaults setObject:[obj objectForKey:@"objectId"] forKey:@"userId"];
          [self.userDefaults setObject:username forKey:@"username"];
          [self.userDefaults setObject:password forKey:@"Password"];
          [self.userDefaults setObject:nickname forKey:@"nickname"];

          isSuccessful = true;
          break;
        }//if();
      }//for();
         
      if (isSuccessful) {

        //界面跳转；
        [AllUtils jumpToViewController:@"MainViewController" contextViewController:self handler:nil];
      } else {

        // 弹框 封装 方法
        [AllUtils showPromptDialog:@"提示" andMessage:@"登录失败，请输入正确的用户名和密码！" OKButton:@"确定" OKButtonAction:nil cancelButton:@"" cancelButtonAction:nil contextViewController:self];
      }
    }else{

      [AllUtils showPromptDialog:@"提示" andMessage:@"网络异常，请稍候再试！" OKButton:@"确定" OKButtonAction:nil cancelButton:@"" cancelButtonAction:nil contextViewController:self];
    }
  }];
}

// 忘记密码
- (IBAction)forgetPasswordButtonPressed:(id)sender {
  
    // 调用 封装 的 界面 方法
  [AllUtils jumpToViewController:@"ForgetPasswordViewController" contextViewController:self handler:nil];
}

//  创建账户
- (IBAction)createAccountButtonPressed:(id)sender {
  
  [AllUtils jumpToViewController:@"RegisterViewController" contextViewController:self handler:nil];
}

#pragma mark - 触摸屏幕隐藏键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
  
  [self.usernameTextField resignFirstResponder];
  [self.passwordTextField resignFirstResponder];
}

- (IBAction)visitorLogin:(UIButton *)sender {
    [AllUtils jumpToViewController:@"MainViewController" contextViewController:self handler:nil];
}
@end

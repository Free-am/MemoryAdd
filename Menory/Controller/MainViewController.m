//
//  ViewController.m
//  Oncenote
//
//  Created by chenyufeng on 15/11/12.
//  Copyright © 2015年 chenyufengweb. All rights reserved.
//


/*
 界面的背景灰色：[UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1] = 227，227，227
 主色调绿色：[UIColor colorWithRed:0 green:0.6 blue:0.26 alpha:1] = 0，135，66
 */

#import "MainViewController.h"
#import <BmobSDK/Bmob.h>
#import "AppDelegate.h"
#import "Notes.h"
#import "AllNotesViewController.h"
#import "Constant.h"
#import "AllUtils.h"
#import "SettingViewController.h"
#import "RemindViewController.h"
#import "AddNoteViewController.h"

#import <AVFoundation/AVFoundation.h>
#import "RemindView.h"
#import "Remind.h"
#import "LewPopupViewController.h"
#import <Masonry.h>

@interface MainViewController ()<UITableViewDataSource,UITableViewDelegate>
// 提醒
@property (nonatomic,weak) UIButton *cover;
@property (strong, nonatomic) IBOutlet UIImageView *remindImage;
@property (strong, nonatomic) IBOutlet UIView *myView;

@property (weak, nonatomic) IBOutlet UITableView *noteTableView;//“笔记”的TableView
@property (weak, nonatomic) IBOutlet UIImageView *naviSettingImage;
@property (weak, nonatomic) IBOutlet UIImageView *naviRefreshImage;
@property (weak, nonatomic) IBOutlet UIImageView *naviSearchImage;
@property (weak, nonatomic) IBOutlet UILabel *naviUsername;
@property (weak, nonatomic) IBOutlet UIImageView *textImageView;
@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;
@property (weak, nonatomic) IBOutlet UIButton *noteCategory;


@property (nonatomic,strong) RemindView *remindView;//提醒界面
@property (nonatomic,strong) UIDatePicker *datePicker;// 时间选择器

//存放笔记对象的可变数组；
@property(nonatomic,strong) NSMutableArray *notesArray;

// 存放remind数组
@property(nonatomic,strong) NSMutableArray *remindAry;


// 字体适配
@property (weak, nonatomic) IBOutlet UILabel *takeNoteLbl;
@property (weak, nonatomic) IBOutlet UILabel *categoryLbl;
@property (weak, nonatomic) IBOutlet UILabel *countBookLbl;
@property (weak, nonatomic) IBOutlet UILabel *memoLbl;
@property (weak, nonatomic) IBOutlet UILabel *takeDownDayLbl;



@end

@implementation MainViewController



- (void)viewDidLoad {

  [super viewDidLoad];
    
    UIFont *fontSize = [UIFont systemFontOfSize:14*self.view.bounds.size.width/320];
    // 字体适配
    self.takeNoteLbl.font = fontSize;
    self.categoryLbl.font = fontSize;
    self.countBookLbl.font = fontSize;
    self.memoLbl.font = fontSize;
    self.takeDownDayLbl.font = fontSize;
    self.naviUsername.font = [UIFont systemFontOfSize:17*self.view.bounds.size.width/320];
    
    self.myView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"高清壁纸4.png"]];
    self.noteTableView.alpha = 0.7;
    self.naviSettingImage.layer.masksToBounds = YES;
    self.naviSettingImage.layer.cornerRadius = 50/2.0f;
    self.naviSettingImage.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.naviSettingImage.image = [UIImage imageNamed:@"头像.png"];
    
    // 长按时间
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(btnLong)];
         longPress.minimumPressDuration = 0.8; //定义按的时间
         [self.remindImage addGestureRecognizer:longPress];
    
    
  //设置navi中的用户名
  AppDelegate *app = [[UIApplication sharedApplication] delegate];
//    NSLog(@"22222222222222用户的昵称是:%@",app.GLOBAL_NICKNAME);
  if (app.GLOBAL_NICKNAME == nil || [app.GLOBAL_NICKNAME isEqualToString:@""]) {

    self.naviUsername.text = app.GLOBAL_USERNAME;
  } else {

    self.naviUsername.text = app.GLOBAL_NICKNAME;
  }
  //绑定控件；
  
    // 设置按钮
  [self.naviSettingImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(naviSettingButtonPressed:)]];
    // 分类按钮
    [self.noteCategory addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpNoteBook)]];
    
    // 更新按钮
  [self.naviRefreshImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(naviRefreshButtonPressed:)]];
    
    // 搜索
  [self.naviSearchImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(naviSearchButtonPressed:)]];
    
   // 文字
  [self.textImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textImageButtonPressed:)]];
    
    
    // 提醒
    [self.remindImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(remindImageAction)]];
    
    
    
   
    
  //查询用户的笔记；
  [self queryNoteByUserId:NOTE_TABLE userId:app.GLOBAL_USERID limitCount:50];
}

#pragma mark - 所有的按钮点击事件


- (void) btnLong{
    [AllUtils jumpToViewController:@"RemindLongBtnViewController" contextViewController:self handler:nil];
}

// 跳转到分类界面
- (void)jumpNoteBook
{
    [AllUtils jumpToViewController:@"noteCateory" contextViewController:self handler:nil];
}

// 提醒
- (void)remindImageAction
{
    NSLog(@"调用了提醒的监听方法");
    
    
    
    self.remindView = [RemindView defaultPopupView];
    
    [AllUtils setBackImage:self.remindView.barView imageName:@"倒计时木背景.png"];
    [self lew_presentPopupView:self.remindView animation:[LewPopupViewAnimationDrop new] dismissed:^{
        NSLog(@"动画结束");
        [self.remindView removeFromSuperview];
        [self.datePicker removeFromSuperview];
    }];
       
    
    self.remindView.remindText.attributedText = nil;
    self.remindView.remindText.layer.borderColor = UIColor.grayColor.CGColor;
    self.remindView.remindText.layer.borderWidth = 1;
    self.remindView.remindText.layer.cornerRadius = 6;
    self.remindView.remindText.layer.masksToBounds = YES;
   
    [self.remindView.cancelBtn addTarget:self action:@selector(remindViewCancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self.remindView.DateBtn addTarget:self action:@selector(remindShowDate) forControlEvents:UIControlEventTouchUpInside];
    [self.remindView.saveBtn addTarget:self action:@selector(remindViewSaveAction) forControlEvents:UIControlEventTouchUpInside];
    /*
    
    UIDatePicker *datePicker = [[UIDatePicker alloc]init];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    
    
    NSString *title = @"输入事件";
    //
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];

    
    
    //  添加文字输入
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    textField.placeholder = @"输入";
        
    }];
    
    
    //  确定按钮
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"调用确定方法");
        //将选择的时间传给本地通知
        RemindViewController *remindViewCon = [[RemindViewController alloc]init];
     [remindViewCon scheduleLocalNotificationWithDate:datePicker.date];
     [self remindController:@"提醒已添加"];
    } ]];
    
    [alert.view addSubview:datePicker];
     

   
   
    //  监听取消按钮
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [self remindController:@"提醒已取消"];
        
    }]];
    
    
    [self presentViewController:alert animated:YES completion:^{ }];
     */
    
}

// remindView 保存
- (void)remindViewSaveAction
{
    
    
    NSLog(@"调用保存方法");
    
    //0.创建推送
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    //1.设置推送类型
    UIUserNotificationType type = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    //2.设置setting(设置类型)
    UIUserNotificationSettings *setting  = [UIUserNotificationSettings settingsForTypes:type categories:nil];
    //3.主动授权
    [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    //4.设置推送时间
    [localNotification setFireDate:self.datePicker.date];
    NSLog(@"推送的时间%@",self.datePicker.date);
    //5.设置时区
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    //6.推送内容
    NSString *str = self.remindView.remindText.text;
    [localNotification setAlertBody:str];
    NSLog(@"推送内容%@",str);
    //7.推送声音
    [localNotification setSoundName:@"Thunder Song.m4r"];
    //8.添加推送到UIApplication
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    [self remindController:@"提醒已添加"];
    
    
    
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSString *userId = app.GLOBAL_USERID;
     BmobObject *obj = [BmobObject objectWithClassName:Remind_TABLE];
    if (!(str==nil)){
        [obj setObject:userId forKey:@"userId"];
       
        [obj setObject:str forKey:@"remind"];

    }else{
        
        UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提醒" message:@"内容不能为空" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertCon removeFromParentViewController];
        }];
        [alertCon addAction:okAction];
        [self presentViewController:alertCon animated:YES completion:nil];
        
    }
    
    if (!(self.datePicker.date==nil)) {
         [obj setObject:self.datePicker.date forKey:@"date"];
    }else{
        UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提醒" message:@"时间不能为空" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertCon removeFromParentViewController];
        }];
        [alertCon addAction:okAction];
        [self presentViewController:alertCon animated:YES completion:nil];

    }
    
    //异步保存到服务器
    [obj saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            //创建成功后会返回objectId，updatedAt，createdAt等信息
            //创建对象成功，打印对象值
            NSLog(@"%@",obj);
            
        } else if (error){
            //发生错误后的动作
            NSLog(@"%@",error);
        } else {
            NSLog(@"Unknow error");
        }
    }];
    
    [self remindViewCancelAction];
   
}


// remindView 取消方法
- (void)remindViewCancelAction
{
    
    self.noteTableView.delegate = self;
    self.noteTableView.dataSource = self;
    [self.noteTableView reloadData];
  
    NSLog(@"调用了remindViewCancelActin");
    self.remindView.transform = CGAffineTransformMakeScale(1, 1);
    self.remindView.alpha = 1;
    [UIView animateWithDuration:0.5 animations:^{
        self.remindView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        self.remindView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.remindView removeFromSuperview];
        [self.datePicker removeFromSuperview];
    }];
}

// remindView 显示时间选择器
- (void)remindShowDate
{
    
   
    NSLog(@"调用了remindShowDate");
    [self.remindView.remindText resignFirstResponder];
    self.datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(10, 400, 290, 216)];
   
//    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    
    [self.view addSubview:self.datePicker];
    
    // masonry适配
    [self.datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.remindView.mas_bottom).offset(10);
        make.left.equalTo(self.view.mas_left).offset(10);
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.bottom.equalTo(self.view.mas_bottom).offset(-10);
    }];
}



//提示页面
- (void)remindController:(NSString *)remindText
{
    //提示页面（8.0出现）
    /**
     *  1.创建UIAlertController的对象
     2.创建UIAlertController的方法
     3.控制器添加action
     4.用presentViewController模态视图控制器
     */
    UIAlertController *alart = [UIAlertController alertControllerWithTitle:@"提示" message:remindText preferredStyle:UIAlertControllerStyleActionSheet];
    [self presentViewController:alart animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alart dismissViewControllerAnimated:YES completion:nil];
        });
    }];
}

-  (AVSpeechSynthesizer *)synthesizer
{
    if (!_synthesizer) {
        _synthesizer = [[AVSpeechSynthesizer alloc] init];
    }
    return _synthesizer;
}







//点击导航栏左侧的设置按钮；
- (void)naviSettingButtonPressed:(id)sender{

  [AllUtils jumpToViewController:@"SettingViewController" contextViewController:self handler:nil];
}

- (void)naviRefreshButtonPressed:(id)sender{
  
}

//点击导航栏搜索按钮；
- (void)naviSearchButtonPressed:(id)sender{

}

//点击Header,跳转到所有笔记页面；
- (void)noteHeaderPressed:(id)sender{

  [AllUtils jumpToViewController:@"AllNotesViewController" contextViewController:self handler:nil];
}

// 跳转到笔记本页面
- (void)noteBookCategoryPressed
{
    [AllUtils jumpToViewController:@"noteCateory" contextViewController:self handler:nil];
}

//跳转到新增笔记的页面-->AddNoteViewController;
- (void)textImageButtonPressed:(id)sender{
  
  [AllUtils jumpToViewController:@"AddNoteViewController" contextViewController:self handler:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
  return [self.notesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  //设置TableView的圆角；
  tableView.layer.cornerRadius = 10;
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoteCell" forIndexPath:indexPath];
  UILabel *noteTitle = (UILabel*)[cell viewWithTag:101];
  UILabel *noteTime = (UILabel*)[cell viewWithTag:102];
    
    
  noteTitle.text = [[self.notesArray objectAtIndex:indexPath.row] valueForKey:@"noteTitle"];
    noteTitle.font = [UIFont systemFontOfSize:14*self.view.bounds.size.width/320];
  //这里需要截取字符串，只要显示日期即可，不需要时分秒
  noteTime.text = [[self.notesArray objectAtIndex:indexPath.row] valueForKey:@"noteCreatedAt"];
    noteTime.font = [UIFont systemFontOfSize:11*self.view.bounds.size.width/320];
  
  return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

  return 50;
}
 


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

  return 50;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *rootView = [[UIView alloc] init];
    if (tableView.tag == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width , 40 )];
        //需要在Header底部加一条细线，用来分隔第一个cell；默认Header和第一个cell之间是没有分隔线的；
        
        // 笔记icon
        UIImageView *noteIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 30, 40)];
        [noteIcon setImage:[UIImage imageNamed:@"记事本1.png"]];
        
        // label “笔记”
        UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 10, 50, 30)];
        noteLabel.text = @"笔记";
        
        noteLabel.textColor = [UIColor blackColor];
        noteLabel.font = [UIFont systemFontOfSize:17*self.view.bounds.size.width/320];
        
        // label “全部”
        UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableView.bounds.size.width - 60, 10, 50, 30)];
        totalLabel.text = @"全部";
        totalLabel.textColor = [UIColor blackColor];
        totalLabel.font = [UIFont systemFontOfSize:14*self.view.bounds.size.width/320];
        
        // 箭头
        UIImageView *arrowIcon = [[UIImageView alloc] initWithFrame:CGRectMake(tableView.bounds.size.width - 30, 10, 30, 30)];
        [arrowIcon setImage:[UIImage imageNamed:@"向右箭头.png"]];
        
        //在Header底部绘制一条线；
        UIView *drawLine = [[UIView alloc] initWithFrame:CGRectMake(0, 49, tableView.bounds.size.width, 1)];
        drawLine.backgroundColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1];
        view.backgroundColor = [UIColor whiteColor];
        [view addSubview:noteIcon];
        [view addSubview:noteLabel];
        [view addSubview:totalLabel];
        [view addSubview:arrowIcon];
        [view addSubview:drawLine];
        //增加Header的点击事件；
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(noteHeaderPressed:)]];
        rootView = view;
    }
    
    if (tableView.tag == 1) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width , 50 )];
        //需要在Header底部加一条细线，用来分隔第一个cell；默认Header和第一个cell之间是没有分隔线的；
        
        // 笔记icon
        UIImageView *noteIcon = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
        [noteIcon setImage:[UIImage imageNamed:@"笔记本.png"]];
        
        // label “笔记”
        UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 10, 50, 30)];
        noteLabel.text = @"笔记本";
        noteLabel.textColor = [UIColor blackColor];
        
        // label “全部”
        UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableView.bounds.size.width - 60, 10, 50, 30)];
        totalLabel.text = @"全部";
        totalLabel.textColor = [UIColor blackColor];
        totalLabel.font = [UIFont systemFontOfSize:12];
        
        // 箭头
        UIImageView *arrowIcon = [[UIImageView alloc] initWithFrame:CGRectMake(tableView.bounds.size.width - 30, 10, 30, 30)];
        [arrowIcon setImage:[UIImage imageNamed:@"向右箭头.png"]];

        
        //在Header底部绘制一条线；
        UIView *drawLine = [[UIView alloc] initWithFrame:CGRectMake(0, 49, tableView.bounds.size.width, 1)];
        drawLine.backgroundColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1];
        
        [view addSubview:noteIcon];
        [view addSubview:noteLabel];
        [view addSubview:totalLabel];
        [view addSubview:arrowIcon];
        [view addSubview:drawLine];
        //增加Header的点击事件；
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(noteBookCategoryPressed)]];
        rootView = view;

    }
    

    return rootView;
  
  
}






#pragma mark - 查询该用户的笔记
- (void) queryNoteByUserId:(NSString*)tableName userId:(NSString*)userId limitCount:(int)limitCount{
  
  BmobQuery *queryNote = [BmobQuery queryWithClassName:NOTE_TABLE];
  //以updatedAt进行降序排列；
  [queryNote orderByDescending:@"updatedAt"];
  queryNote.limit = limitCount;
  [queryNote findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
    
    if (error) {

      //      NSLog(@"查询笔记错误");
    } else {

      //      NSLog(@"正在查询笔记。。。");
      for (BmobObject *obj in array) {
        
        Notes *note = [[Notes alloc] init];
        if ([(NSString*)[obj objectForKey:@"userId"] isEqualToString:userId]) {
          
          note.noteId = [obj objectForKey:@"objectId"];
          note.userId = [obj objectForKey:@"userId"];
          note.username = [obj objectForKey:@"username"];
          note.noteTitle = [obj objectForKey:@"noteTitle"];
          note.noteText = [obj objectForKey:@"noteText"];
            note.noteBook = [obj objectForKey:@"noteBook"];

            // 获取日期
          note.noteCreatedAt = [AllUtils getDateFromString:[obj objectForKey:@"createdAt"]];
          
          [_notesArray addObject:note];
        }//if();
      }//for();
      
      if (self.tempTitle != nil && self.tempText != nil && self.tempIndexPath != nil) {
        
        [[self.notesArray objectAtIndex:self.tempIndexPath.row] setValue:self.tempTitle forKey:@"noteTitle"];
        [[self.notesArray objectAtIndex:self.tempIndexPath.row] setValue:self.tempText forKey:@"noteText"];
        for (int i = (int)self.tempIndexPath.row ; i >= 1; i--) {

          [self.notesArray exchangeObjectAtIndex:i withObjectAtIndex:i-1];//这样是可以的；
        }//for()
      }
    }//else();
    
    //    NSLog(@"笔记数组的count = %lu",(unsigned long)[self.notesArray count]);
    self.noteTableView.frame = CGRectMake(self.noteTableView.frame.origin.x, self.noteTableView.frame.origin.y, self.noteTableView.frame.size.width, (([self.notesArray count] > 3 ? 3 : [self.notesArray count]) + 2) * 50);
    [self.noteTableView reloadData];
  }];
}

#pragma mark - 懒加载显示笔记内容
//这里标题的添加也使用懒加载；
- (NSMutableArray *)notesArray{
  
  Notes *note = [[Notes alloc] init];
  note.noteId = @"";
  note.userId = @"";
  note.username = @"";
  note.noteTitle = @"";
  note.noteText = @"";
  note.noteCreatedAt = @"";
    note.noteBook = @"";

  if (!_notesArray) {

    self.notesArray = [[NSMutableArray alloc] initWithCapacity:3];
  }
  return _notesArray;
}

#pragma mark - 界面跳转传递数据

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"%@",segue.identifier);
    if ([segue.identifier isEqualToString:@"AddNoteViewController"]) {
    AddNoteViewController *detail = (AddNoteViewController*)segue.destinationViewController;
    NSIndexPath *indePath = self.noteTableView.indexPathForSelectedRow;
    detail.noteId = [[self.notesArray objectAtIndex:indePath.row] valueForKey:@"noteId"];
    detail.noteTitle = [[self.notesArray objectAtIndex:indePath.row] valueForKey:@"noteTitle"];
    detail.noteText = [[self.notesArray objectAtIndex:indePath.row] valueForKey:@"noteText"];
        detail.category = [[self.notesArray objectAtIndex:indePath.row] valueForKey:@"noteBook"];

    detail.indexPath = indePath;
    
}

  
}
 

//  点击屏幕隐藏键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.remindView.remindText resignFirstResponder];
}


- (void)findRemind
{
    BmobQuery *query = [BmobQuery queryWithClassName:Remind_TABLE];
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSString *userId = app.GLOBAL_USERID;
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        for (BmobObject *obj in array) {
            if ([[obj objectForKey:@"userId"] isEqualToString:userId]) {
                Remind *remind = [[Remind alloc] init];
                remind.remind = [obj objectForKey:@"remind"];
                remind.date = [obj objectForKey:@"date"];
                [self.remindAry addObject:remind];
            }
            
            
            
        }
    }];
}



// 懒加载
- (NSMutableArray *)remindAry
{
    Remind *remind = [[Remind alloc] init];
    remind.userId = @"";
    remind.remind = @"";
    remind.date = nil;
    if (!_remindAry) {
        self.remindAry = [[NSMutableArray alloc] init];
    }
    return _remindAry;
    
}
@end

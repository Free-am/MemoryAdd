//
//  RemindLongBtnViewController.m
//  Menory
//
//  Created by user on 16/11/11.
//  Copyright © 2016年 Corbin. All rights reserved.
//

#import "RemindLongBtnViewController.h"
#import "AllUtils.h"
#import "Remind.h"
#import <BmobSDK/Bmob.h>
#import "Constant.h"
#import "AppDelegate.h"
#import "BmobOperation.h"
@interface RemindLongBtnViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIView *allView;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic,strong) NSMutableArray *remidAry;
- (IBAction)backBtn:(UIButton *)sender;

@end

@implementation RemindLongBtnViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [AllUtils setBackImage:self.allView imageName:@"主页背景.png"];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.alpha = 0.7;
    self.tableview.layer.cornerRadius = 10;
    [self findTable];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark tableview

// 显示cell的个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.remidAry.count;
}

- ( CGFloat )tableView:( UITableView *)tableView heightForRowAtIndexPath:( NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
   
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"remindCell" forIndexPath:indexPath];
    
    UILabel *remindLbl = (UILabel*)[cell viewWithTag:2];
    UILabel *date = (UILabel*)[cell viewWithTag:3];
    UIImageView *img = (UIImageView*)[cell viewWithTag:1];
    int index = self.remidAry.count - indexPath.row - 1;
    
    Remind *remind = [[Remind alloc] init];
    remind = [self.remidAry objectAtIndex:index];
    remindLbl.text = remind.remind;
    NSString *strDate = [NSString stringWithFormat:@"%@", remind.date];
    date.text = [strDate substringWithRange:NSMakeRange(0, 10)];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.alpha = 0.8;
    [cell.layer setMasksToBounds:YES];
    img.backgroundColor = [UIColor whiteColor];
    img.alpha = 0.8;
   
    
    return cell;
    
}

- (nullable UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *rootView = [[UIView alloc] init];
   
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width , 40 )];
    view.backgroundColor = [UIColor blackColor];
    //需要在Header底部加一条细线，用来分隔第一个cell；默认Header和第一个cell之间是没有分隔线的；
    
    
    
    // label “笔记”
    UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 40, 20)];
    noteLabel.text = @"名称";
    noteLabel.textColor = [UIColor blackColor];
    noteLabel.font = [UIFont systemFontOfSize:18];
    
    // label “全部”
    UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableView.bounds.size.width - 110, 10, 40, 20)];
    totalLabel.text = @"时间";
    totalLabel.textColor = [UIColor blackColor];
    totalLabel.font = [UIFont systemFontOfSize:18];
    
    // 箭头
    UIImageView *arrowIcon = [[UIImageView alloc] initWithFrame:CGRectMake(tableView.bounds.size.width - 30, 7, 30, 30)];
    [arrowIcon setImage:[UIImage imageNamed:@"向右箭头.png"]];
    
    //在Header底部绘制一条线；
    UIView *drawLine = [[UIView alloc] initWithFrame:CGRectMake(0, 40, tableView.bounds.size.width, 1)];
    drawLine.backgroundColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1];
    view.backgroundColor = [UIColor whiteColor];
    
    [view addSubview:noteLabel];
    [view addSubview:totalLabel];
    [view addSubview:arrowIcon];
    [view addSubview:drawLine];
    //    view.backgroundColor = [UIColor blackColor];
    //增加Header的点击事件；
    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(noteHeaderPressed:)]];
    rootView = view;
    return rootView;
    
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //左滑删除；
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //数据库删除；
        [BmobOperation deleteNoteFromDatabase:Remind_TABLE noteId:[[self.remidAry objectAtIndex:indexPath.row] valueForKey:@"userId"]];
        [self.remidAry removeObjectAtIndex:indexPath.row];//从数组中删除该值；
        [self.tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if (100 * [self.remidAry count] < [UIScreen mainScreen].bounds.size.height) {
            
            self.tableview.frame = CGRectMake(self.tableview.frame.origin.x, self.tableview.frame.origin.y, self.tableview.frame.size.width, 100 * [self.remidAry count]);
        }else{
            
            self.tableview.frame = CGRectMake(self.tableview.frame.origin.x, self.tableview.frame.origin.y, self.tableview.frame.size.width, [UIScreen mainScreen].bounds.size.height - 65);
        }
    }
}
#pragma mark 查询表
- (void)findTable
{
    
    BmobQuery *query = [BmobQuery queryWithClassName:Remind_TABLE];
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSString *userId = app.GLOBAL_USERID;
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            NSLog(@"error%@",error);
        }
        else{
            
            
            for (BmobObject *obj in array) {
                if ([(NSString*)[obj objectForKey:@"userId"] isEqualToString:userId]){
                    Remind *remind = [[Remind alloc] init];
                    remind.remind = [obj objectForKey:@"remind"];
                    remind.date = [obj objectForKey:@"date"];
                    [self.remidAry addObject:remind];
                    }
                
            }
            
        }
        
       
        
        [self.tableview reloadData];
        
    }];

}


#pragma mark 懒加载
- (NSMutableArray *)remidAry
{
    Remind *remind = [[Remind alloc] init];
    remind.remind = @"";
    remind.date = nil;
    if (!_remidAry) {
        self.remidAry = [[NSMutableArray alloc] init];
    }
    return _remidAry;
}

- (IBAction)backBtn:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

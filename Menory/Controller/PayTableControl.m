//
//  PayTableControl.m
//  Menory
//
//  Created by user on 16/10/24.
//  Copyright © 2016年 Corbin. All rights reserved.
//

#import "PayTableControl.h"
#import "AllUtils.h"
#import <BmobSDK/Bmob.h>
#import "Constant.h"
#import "AppDelegate.h"
#import "Finance.h"
#import "BmobOperation.h"
#import "PayViewController.h"
#import "MDayMatter.h"

@interface PayTableControl()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *allView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *financeAllAry;
@property (weak, nonatomic) IBOutlet UIImageView *backAction;

@end


@implementation PayTableControl 

-(void)viewDidLoad {
    [super viewDidLoad];
    [AllUtils setBackImage:self.allView imageName:@"主页背景.png"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self findFinanceAllValue];
//    self.tableView.backgroundColor = [UIColor clearColor];
    [self.backAction addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(back)]];
   
}

- (void)back
{
    
    [self dismissViewControllerAnimated:YES completion:^{
        PayViewController *con = [[PayViewController alloc] init];
        [con.tableview reloadData];
    }];
    
}

#pragma mark tableview

// 显示cell的个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"++++++++%lu",(unsigned long)self.financeAllAry.count);
    
    return self.financeAllAry.count;
}

- ( CGFloat )tableView:( UITableView *)tableView heightForRowAtIndexPath:( NSIndexPath *)indexPath
{
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    NSLog(@"cell");
    NSLog(@"------%@",self.financeAllAry);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableviewCell" forIndexPath:indexPath];
    
    UILabel *consumeLbl = (UILabel*)[cell viewWithTag:11];
    UILabel *categoryLbl = (UILabel*)[cell viewWithTag:12];
    UILabel *detailLbl = (UILabel*)[cell viewWithTag:13];
    UILabel *dateLbl = (UILabel*)[cell viewWithTag:14];
    UIImageView *img = (UILabel*)[cell viewWithTag:15];
    int index = self.financeAllAry.count - indexPath.row - 1;
    consumeLbl.text =[NSString stringWithFormat:@"%@",[[self.financeAllAry objectAtIndex:index] valueForKey:@"consume"] ] ;
    categoryLbl.text = [[self.financeAllAry objectAtIndex:index] valueForKey:@"category"];
    detailLbl.text = [[self.financeAllAry objectAtIndex:index] valueForKey:@"detail"];
    
    NSString *strDate = [NSString stringWithFormat:@"%@",[[self.financeAllAry objectAtIndex:index] valueForKey:@"financeDate"] ];
    dateLbl.text = [strDate substringWithRange:NSMakeRange(0, 10)];
    cell.backgroundColor = [UIColor clearColor];
    cell.alpha = 0.8;
    [cell.layer setMasksToBounds:YES];
    cell.layer.cornerRadius = 10;
    img.backgroundColor = [UIColor whiteColor];
    img.alpha = 0.8;
    img.layer.cornerRadius = 10;

    return cell;
    
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //左滑删除；
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //数据库删除；
        int index = self.financeAllAry.count - indexPath.row - 1;
        [BmobOperation deleteNoteFromDatabase:FINANCE_TABLE noteId:[[self.financeAllAry objectAtIndex:index] valueForKey:@"objId"]];
        [self.financeAllAry removeObjectAtIndex:index];//从数组中删除该值；
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        
        [self.tableView reloadData];
    }
    //    [self myReloadDate];
    
    
}



// 查找finance所有值
- (void)findFinanceAllValue
{
    BmobQuery *query = [BmobQuery queryWithClassName:FINANCE_TABLE];
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSString *userId = app.GLOBAL_USERID;
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            NSLog(@"error%@",error);
        }
        else{
            
            
            for (BmobObject *obj in array) {
                if ([(NSString*)[obj objectForKey:@"userId"] isEqualToString:userId]){
                    Finance *finance = [[Finance alloc] init];
                    finance.objId = [obj objectForKey:@"objectId"];
                    finance.category = [obj objectForKey:@"category"];
                    finance.consume = [obj objectForKey:@"consume"];
                    finance.detail = [obj objectForKey:@"detail"];
                    finance.financeDate = [obj objectForKey:@"financeDate"];
                    [self.financeAllAry addObject:finance];
                }
                
            }
            
        }
       
        [self.tableView reloadData];
        
        NSLog(@"++++++%@",self.financeAllAry);
    }];
    
}




// 懒加载
- (NSMutableArray *)financeAllAry
{
    Finance *finance = [[Finance alloc] init];
    finance.objId = @"";
    finance.category = @"";
    finance.consume = 0;
    finance.detail = @"";
    finance.financeDate = nil;
    if (!_financeAllAry) {
        self.financeAllAry = [[NSMutableArray alloc] initWithCapacity:10];
        
    }
    return _financeAllAry;
}


@end

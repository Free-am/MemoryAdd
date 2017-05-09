//
//  NoteCategryViewController.m
//  Menory
//
//  Created by user on 16/10/9.
//  Copyright © 2016年 Corbin. All rights reserved.
//

#import "NoteCategryViewController.h"
#import "AllNotesViewController.h"
#import "NoteDetailViewController.h"
#import <BmobSDK/Bmob.h>
#import "Constant.h"
#import "MainViewController.h"
#import "AllNoteDetailViewController.h"
#import "AppDelegate.h"
#import "AllUtils.h"
#import "BmobOperation.h"
#import "NoteCategory.h"
#import "Notes.h"
#import "AddNoteViewController.h"

@interface NoteCategryViewController () <UITableViewDataSource,UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UIImageView *shareImageView;
@property (weak, nonatomic) IBOutlet UIImageView *searchImageView;
@property (weak, nonatomic) IBOutlet UITableView *noteTableView;
//存放笔记对象的可变数组；
@property(nonatomic,strong) NSMutableArray *allNotesArray;
@property(nonatomic,strong) NSMutableDictionary *noteBookDict;
@property (strong, nonatomic) IBOutlet UIView *allView;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;


// 数组去重
@property(nonatomic,strong) NSMutableArray *noRepetitionArray;
@property(nonatomic,assign) NSInteger *tableRow;



@property (nonatomic,strong) NSMutableArray *selectedArray;// 是否被点击


@property (nonatomic,strong) UIImageView *img;
@property (nonatomic,strong) UIView *sectionView;
@end

@implementation NoteCategryViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    [AllUtils setBackImage:self.allView imageName:@"主页背景.png"];
    self.myTableView.backgroundColor = [UIColor clearColor];
    self.myTableView.layer.cornerRadius = 10;
    //设置navi中的用户名；
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    //控件绑定操作；
    [self.backImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(allNotesBackButtonPressed:)]];
    //查询用户的笔记；
    //    [self queryNoteByUserId:NOTE_TABLE userId:app.GLOBAL_USERID limitCount:50];
    [self queryNoteBookByUserId:NOTEBOOK_TABLE userId:app.GLOBAL_USERID limitCount:50];
    self.noteTableView.delegate = self;
    self.noteTableView.dataSource = self;
    self.noteTableView.layer.cornerRadius = 10;
    //    self.noteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, 320, 502)];
    self.noteBookDict = [[NSMutableDictionary alloc]init];
    
    
}

#pragma mark - 所有的按钮点击操作
- (void) allNotesBackButtonPressed:(id)sender{
    //使用显式界面跳转,因为需要执行MainViewController的viewDidLoad()方法；
    [AllUtils jumpToViewController:@"MainViewController" contextViewController:self handler:nil];
}

#pragma mark - UITableViewDataSource

// 表格有几个分组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return [self.allNotesCategory count];
}

// 有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    for (int i=0; i<self.allNotesCategory.count; i++) {
        [self.selectedArray addObject:@"0"];
    }
    if ([self.selectedArray[section] isEqualToString:@"1"]) {
        NSString *key = [self.allNotesCategory objectAtIndex:section];
        NSArray *noteArray = [self.noteBookDict objectForKey:key];
        
        return noteArray.count;
        
    }
    return 0;
}

// 每行显示什么内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoteCell" forIndexPath:indexPath];
    UILabel *noteTitle = (UILabel*)[cell viewWithTag:101];
    UILabel *noteTime = (UILabel*)[cell viewWithTag:102];
    UILabel *noteText = (UILabel*)[cell viewWithTag:103];
    UIImageView *img = (UIImageView *)[cell viewWithTag:100];
    NSString *key = [self.allNotesCategory objectAtIndex:indexPath.section];
    NSArray *noteArray = [self.noteBookDict objectForKey:key];
    
    noteTitle.text = [[noteArray objectAtIndex:indexPath.row] valueForKey:@"noteTitle"];
    noteTime.text = [[noteArray objectAtIndex:indexPath.row] valueForKey:@"noteCreatedAt"];
    noteText.text = [[noteArray objectAtIndex:indexPath.row] valueForKey:@"noteText"];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.alpha = 0.8;
    [cell.layer setMasksToBounds:YES];
    cell.layer.cornerRadius = 10;
    img.backgroundColor = [UIColor whiteColor];
    img.alpha = 0.8;
    img.layer.cornerRadius = 10;
    return cell;
}

// 每个分组的名字
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *noteCategoryName = [self.allNotesCategory objectAtIndex:section];
    //    NSString *noteCategoryName = @"test";
    return noteCategoryName;
}

////  快速定位组名  位置
//
//- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//
//    return self.allNotesCategory;
//}



#pragma mark - UITableViewDelegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return true;
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *key = [self.allNotesCategory objectAtIndex:indexPath.section];
    NSArray *noteArray = [self.noteBookDict objectForKey:key];
    //左滑删除；
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //数据库删除；
        [BmobOperation deleteNoteFromDatabase:NOTE_TABLE noteId:[[noteArray objectAtIndex:indexPath.row] valueForKey:@"noteId"]];
        
        //从数组中删除该值；
        [[self.noteBookDict objectForKey:key]  removeObjectAtIndex:indexPath.row];
        [self.noteTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if (100 * (int)self.tableRow < [UIScreen mainScreen].bounds.size.height) {
            
            self.noteTableView.frame = CGRectMake(self.noteTableView.frame.origin.x, self.noteTableView.frame.origin.y, self.noteTableView.frame.size.width, 100 * (int)self.tableRow);
        }else{
            
            self.noteTableView.frame = CGRectMake(self.noteTableView.frame.origin.x, self.noteTableView.frame.origin.y, self.noteTableView.frame.size.width, [UIScreen mainScreen].bounds.size.height - 65);
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 105;
}


#pragma mark - section内容
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    for (int i=0; i<self.allNotesCategory.count; i++) {
        [self.selectedArray addObject:@"0"];
    }
    //每个section上面有一个button,给button一个tag值,用于在点击事件中改变_selectedArray[button.tag - 1000]的值
    self.sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 414, 40)];
    self.sectionView.backgroundColor = [UIColor clearColor];
    UIButton *sectionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sectionButton.frame = CGRectMake(20, 5, 90, 40);
    self.img = [[UIImageView alloc] init];
    [self.img setImage:[UIImage imageNamed:@"白色向右.png"]];
    self.img.frame = CGRectMake(11, 5, 20, 40);
    [self.sectionView addSubview:self.img];
    [sectionButton setTitle:[self.allNotesCategory objectAtIndex:section] forState:UIControlStateNormal];
    [sectionButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    sectionButton.tag = 1000 + section;
    [self.sectionView addSubview:sectionButton];
    return self.sectionView;
}
#pragma mark button点击方法
-(void)buttonAction:(UIButton *)button
{
    if ([self.selectedArray[button.tag - 1000] isEqualToString:@"0"]) {
        
        for (NSInteger i = 0; i < self.allNotesCategory.count; i++) {
            [self.selectedArray replaceObjectAtIndex:i withObject:@"0"];
            [self.noteTableView reloadSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        
        //如果当前点击的section是缩回的,那么点击后就需要把它展开,是_selectedArray对应的值为1,这样当前section返回cell的个数就变为真实个数,然后刷新这个section就行了
        [self.selectedArray replaceObjectAtIndex:button.tag - 1000 withObject:@"1"];
        [self.noteTableView reloadSections:[NSIndexSet indexSetWithIndex:button.tag - 1000] withRowAnimation:UITableViewRowAnimationFade];
        [self.img removeFromSuperview];
        [self.img setImage:[UIImage imageNamed:@"白色向下.png"]];
        [self.sectionView addSubview:self.img];
    }
    else
    {
        //如果当前点击的section是展开的,那么点击后就需要把它缩回,使_selectedArray对应的值为0,这样当前section返回cell的个数变成0,然后刷新这个section就行了
        [self.selectedArray replaceObjectAtIndex:button.tag - 1000 withObject:@"0"];
        [self.noteTableView reloadSections:[NSIndexSet indexSetWithIndex:button.tag - 1000] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - 界面跳转传递数据

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"%@",segue.identifier);
    if ([segue.identifier isEqualToString:@"AddNoteViewController"]) {
        AddNoteViewController *detail = (AddNoteViewController*)segue.destinationViewController;
        NSIndexPath *indePath = self.noteTableView.indexPathForSelectedRow;
        
        NSString *key = [self.allNotesCategory objectAtIndex:indePath.section];
        NSArray *noteArray = [self.noteBookDict objectForKey:key];
        
        
        
        detail.noteTitle = [[noteArray objectAtIndex:indePath.row] valueForKey:@"noteTitle"];
        detail.noteText = [[noteArray objectAtIndex:indePath.row] valueForKey:@"noteText"];
        
        detail.indexPath = indePath;
    }
}
#pragma mark - 查询该用户的笔记

//  查询 笔记 类别
- (void) queryNoteBookByUserId:(NSString*)tableName userId:(NSString*)userId limitCount:(int)limitCount{
    
    BmobQuery *queryNoteBook = [BmobQuery queryWithClassName:tableName];
    [queryNoteBook orderByDescending:@"updatedAt"];
    queryNoteBook.limit = limitCount;
    [queryNoteBook findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            NSLog(@"查询笔记本错误");
        } else {
            //      NSLog(@"正在查询笔记。。。");
            
            NoteCategory *noteCategory = [[NoteCategory alloc] init];
            
            for (BmobObject *obj in array) {
                
                if ([(NSString*)[obj objectForKey:@"userId"] isEqualToString:userId]) {
                    //                    noteCategory.userId = [obj objectForKey:@"userId"];
                    //                    noteCategory.username = [obj objectForKey:@"username"];
                    noteCategory.noteBookCategory = [obj objectForKey:@"noteBookCategoy"];
                    //                    [self.allNotesCategory addObject:noteCategory];
                    [self.allNotesCategory addObject:noteCategory.noteBookCategory];
                    
                }//if(
            }//for();
        }//else();
        [self repetitionToNo:self.allNotesCategory];
        [self.noteTableView reloadData];
        
        
        
        
        
        
        BmobQuery *queryNote = [BmobQuery queryWithClassName:NOTE_TABLE];
        
        [queryNote orderByDescending:@"updatedAt"];
        queryNote.limit = limitCount;
        
        for (int i=0; i<self.allNotesCategory.count; i++) {
            NSMutableArray *mutArray = [[NSMutableArray alloc] initWithCapacity:10];
            NSLog(@"%@",self.allNotesCategory[i]);
            [queryNote whereKey:@"noteBook" equalTo:self.allNotesCategory[i] ];
            
            
            
            [queryNote findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
                //                NSLog(@"%@",array);
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
                            NSString *str   = [obj objectForKey:@"noteTitle"];
                            note.noteCreatedAt = [AllUtils getDateFromString:[obj objectForKey:@"createdAt"]];
                            
                            [self.allNotesArray addObject:note];
                            [mutArray addObject:note];
                        }//if();
                    }//for();
                    if (self.tempTitle != nil && self.tempText != nil && self.tempIndexPath != nil) {
                        
                        [[self.allNotesArray objectAtIndex:self.tempIndexPath.row] setValue:self.tempTitle forKey:@"noteTitle"];
                        [[self.allNotesArray objectAtIndex:self.tempIndexPath.row] setValue:self.tempText forKey:@"noteText"];
                        for (int i = (int)self.tempIndexPath.row ; i >= 1; i--) {
                            
                            [self.allNotesArray exchangeObjectAtIndex:i withObjectAtIndex:i-1];//这样是可以的；
                        }//for()
                    }
                }//else();
                NSLog(@"笔记数组的count = %lu",(unsigned long)[self.allNotesArray count]);
                /*
                 //解决TableView不能滚到最下面的bug；注意如何设置TableView的长度；
                 if (100 * (int)self.tableRow < [UIScreen mainScreen].bounds.size.height) {
                 
                 self.noteTableView.frame = CGRectMake(self.noteTableView.frame.origin.x, self.noteTableView.frame.origin.y, self.noteTableView.frame.size.width, 100 * (int)self.tableRow);
                 }else{
                 
                 self.noteTableView.frame = CGRectMake(self.noteTableView.frame.origin.x, self.noteTableView.frame.origin.y, self.noteTableView.frame.size.width, [UIScreen mainScreen].bounds.size.height - 65);
                 }
                 */
                
                
                //把数组赋值到字典
                [self.noteBookDict setObject:self.allNotesArray forKey:self.allNotesCategory[i]];
                self.tableRow = self.tableRow + self.allNotesArray.count;
                self.allNotesArray = nil;
                
                
                [self.noteTableView reloadData];
                NSLog(@"输出字典%@",self.noteBookDict);
                
                
                
            }];
            
        }
        
        
        
        
    }];
}


#pragma mark - 懒加载显示笔记内容
//这里标题的添加也使用懒加载；
// 懒加载 笔记内容
- (NSMutableArray *)allNotesArray{
    
    Notes *note = [[Notes alloc] init];
    note.noteId = @"";
    note.userId = @"";
    note.username = @"";
    note.noteTitle = @"";
    note.noteText = @"";
    note.noteCreatedAt = @"";
    note.noteBook = @"";
    if (!_allNotesArray) {
        
        self.allNotesArray = [[NSMutableArray alloc] init];
    }
    return _allNotesArray;
}


// 懒加载 笔记分类
- (NSMutableArray *)allNotesCategory
{
    NoteCategory *noteCategory = [[NoteCategory alloc]init];
    noteCategory.userId = @"";
    noteCategory.username = @"";
    noteCategory.noteBookCategory = @"";
    if (!_allNotesCategory) {
        self.allNotesCategory = [[NSMutableArray alloc]init];
    }
    return _allNotesCategory;
}


//  实现去重
- (void)repetitionToNo:(NSMutableArray *)allNotesCategory
{
    self.noRepetitionArray = [[NSMutableArray alloc] init];
    for (NSString *str in allNotesCategory) {
        if (![self.noRepetitionArray containsObject:str]) {
            [self.noRepetitionArray addObject:str];
        }
    }
}


- (NSMutableArray *)selectedArray
{
    if (!_selectedArray) {
        self.selectedArray = [[NSMutableArray alloc] init];
    }
    return _selectedArray;
}




@end

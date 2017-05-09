//
//  DaysMatterViewController.m
//  Menory
//
//  Created by user on 16/10/26.
//  Copyright © 2016年 Corbin. All rights reserved.
//

#define TAG 99

#import "DaysMatterViewController.h"
#import "RGCollectionViewCell.h"
#import "AllUtils.h"
#import "MLFloatButton.h"
#import "BmobOperation.h"
#import "Constant.h"
#import "AppDelegate.h"
#import "PMCalendar.h"
#import "MDayMatter.h"
#import <BmobSDK/Bmob.h>
#import "Constant.h"


@interface DaysMatterViewController ()<UICollectionViewDataSource,PMCalendarControllerDelegate>
{
    MLFloatButton *floatButton;
    
    int returnInt;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

//  xib属性
@property (weak, nonatomic) IBOutlet UITextField *titleDayMaterXib;
- (IBAction)btnDate:(UIButton *)sender;
- (IBAction)saveDayMatter:(UIButton *)sender;
- (IBAction)cancel:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UIView *dayMatterViewXib;
// 储存 dayMatter的数组
@property (nonatomic,strong) NSMutableArray *dayMatterArray;

// 日历
@property (nonatomic,strong) PMCalendarController *pmCC;

@property (nonatomic,weak) NSData *dateDayMatter;
@property (nonatomic,strong) AppDelegate *app;

@end

@implementation DaysMatterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 13, 30, 40)];
    [AllUtils setBackImage:backBtn imageName:@"白色向左.png"];
    [self.view addSubview:backBtn];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.app = [[UIApplication sharedApplication] delegate];
    
    [AllUtils setBackImage:self.collectionView imageName:@"主页背景.png"];
    [self findMDayMatter];
  
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    //设置轻扫的方向
    swipeGesture.direction = UISwipeGestureRecognizerDirectionUp; //向右
    [self.view addGestureRecognizer:swipeGesture];
    
    [self.view addGestureRecognizer:swipeGesture];
    
   
    
    
   }

- (void)backAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    // 悬浮按钮
    floatButton = [MLFloatButton loadFromNibWithFrame:CGRectMake(100, 100, 32, 32) addTarget:self InSuperView:self.view];
   
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(presentMenu:)];
    longPressRecognizer.minimumPressDuration = 1;
    
    [self.view addGestureRecognizer:longPressRecognizer];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    int count = self.dayMatterArray.count;
    NSLog(@"%d",count);
    return count;
}



-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    RGCollectionViewCell *cell = (RGCollectionViewCell  *)[collectionView dequeueReusableCellWithReuseIdentifier:@"reuse" forIndexPath:indexPath];
    [self configureCell:cell withIndexPath:indexPath];
    UIView *view = [cell.contentView viewWithTag:122];
    view.layer.cornerRadius = 10;
    UIView *barView = [cell.contentView viewWithTag:123];
    barView.layer.cornerRadius = 10;
    
    return cell;
}


- (void)configureCell:(RGCollectionViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    UIView  *subview = [cell.contentView viewWithTag:TAG];
    [subview removeFromSuperview];
 
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    // 获取日期
    NSDate *endDate = [[self.dayMatterArray objectAtIndex:indexPath.section] valueForKey:@"MADdate"];
    
    // date 转 string
    NSString *strEndDate = [dateFormatter stringFromDate:endDate];
    // int 转 string
    cell.MDdate.text = strEndDate;
    
    //  计算天数
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd"];//设置时间格式//很重要
    NSDate *d=[date dateFromString:strEndDate];
    NSLog(@"d%@",d);
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSLog(@"dat---%@",dat);
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    NSTimeInterval cha=late-now;
    
    timeString = [NSString stringWithFormat:@"%f", cha/86400];
    timeString = [timeString substringToIndex:timeString.length-7];
    int day = [timeString intValue] + 1;
    // 天数  int转string
    NSString *strDay = [NSString stringWithFormat:@"%d",day];
    NSLog(@"day%@",strDay);
    cell.MDday.text = strDay;
    
    NSString *title = [[self.dayMatterArray objectAtIndex:indexPath.section] valueForKey:@"MDMtitle"];
    cell.MDTitle.text = [NSString stringWithFormat:@"距离%@还有",title];
  
    
    
}



//轻扫手势触发方法
-(void)swipeGesture:(id)sender
{
    UISwipeGestureRecognizer *swipe = sender;
    if (swipe.direction == UISwipeGestureRecognizerDirectionUp)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

#pragma mark - 悬浮按钮点击弹出画板
- (void)buttonTouchAction {
    NSLog(@"点击了悬浮按钮");
    [[NSBundle mainBundle] loadNibNamed:[[self class] description] owner:self options:nil];
    self.dayMatterViewXib.frame = CGRectMake((self.view.frame.size.width-self.dayMatterViewXib.frame.size.width)/2 , 0, 200, 200);
    self.dayMatterViewXib.backgroundColor = [UIColor clearColor];
   
    [self.view addSubview:self.dayMatterViewXib];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.titleDayMaterXib resignFirstResponder];
    
}






- (IBAction)btnDate:(UIButton *)sender {
    self.pmCC = [[PMCalendarController alloc]init];
    self.pmCC.delegate = self;
    self.pmCC.mondayFirstDayOfWeek = YES;
    [self.pmCC presentCalendarFromView:self.dayMatterViewXib permittedArrowDirections:PMCalendarArrowDirectionDown animated:YES];

    [self calendarController:self.pmCC didChangePeriod:self.pmCC.period];
}

- (IBAction)saveDayMatter:(UIButton *)sender {
    NSLog(@"点击了保存按钮");
    if (self.titleDayMaterXib.text == nil || self.dateDayMatter == nil) {
        [AllUtils showLblToRemind:self.view backgroundColor:[UIColor blueColor] textColor:[UIColor whiteColor] message:@"标题&时间不能为空" animateWithDuration:0.8 alpha:0.8];
    } else {
        NSLog(@"app%@",self.app.GLOBAL_USERID);
        [BmobOperation addDataToMDayMatter:DAYMATTER_TABLE userId:self.app.GLOBAL_USERID title:self.titleDayMaterXib.text date:self.dateDayMatter todo:^(BOOL isSuccessful, NSError *error) {
            
            
            if (isSuccessful) {
                NSLog(@"成功");
                [AllUtils showLblToRemind:self.view backgroundColor:[UIColor blueColor] textColor:[UIColor whiteColor] message:@"保存成功" animateWithDuration:0.8 alpha:0.8];
                
            }
            if (error) {
                [AllUtils showLblToRemind:self.view backgroundColor:[UIColor blueColor] textColor:[UIColor whiteColor] message:@"保存失败" animateWithDuration:0.8 alpha:0.8];
                NSLog(@"失败哦");
                
            }
        }];
        
        [self.dayMatterViewXib removeFromSuperview];
        

        
    }
}

- (IBAction)cancel:(UIButton *)sender {
    [self.dayMatterViewXib removeFromSuperview];
}

- (void) dimissAlert:(UIAlertController *)alert {
    if(alert){
        [alert removeFromParentViewController];
    }
    
}
- (void)calendarController:(PMCalendarController *)calendarController didChangePeriod:(PMPeriod *)newPeriod
{
    self.dateDayMatter = newPeriod.startDate ;
    NSLog(@"%@",self.dateDayMatter);
}


// 懒加载
- (NSMutableArray *)dayMatterArray
{
    MDayMatter *mDayMatter = [[MDayMatter alloc] init];
    mDayMatter.MDMtitle = @"";
    mDayMatter.MDMUserId = @"";
    if (!_dayMatterArray) {
        self.dayMatterArray = [[NSMutableArray alloc]  initWithCapacity:3];
        
    }
    
    return _dayMatterArray;
}



// 查询MDayMatter表
- (void)findMDayMatter
{
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    BmobQuery *query = [BmobQuery queryWithClassName:DAYMATTER_TABLE];
    
    [query orderByDescending:@"updatedAt"];
    query.limit = 10;
    
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        NSLog(@"调用block");
        if (error) {
            NSLog(@"查询失败");
        }else {
            for (BmobObject *obj in array) {
                MDayMatter *mDayMatter = [[MDayMatter alloc] init];
                
                if ([(NSString*)[obj objectForKey:@"MDMUserId"] isEqualToString:app.GLOBAL_USERID]) {
                    mDayMatter.MADdate = [obj objectForKey:@"MDMdate"];
                    mDayMatter.MDMtitle = [obj objectForKey:@"MDMtitle"];
                    mDayMatter.MAMCreatDate = [obj objectForKey:@"createdAt"];
                    [self.dayMatterArray addObject:mDayMatter];
                }
                
                
            }
          
            
        }
        [self.collectionView reloadData];
    }];
    

    
   
}



- (IBAction)backBtn:(UIButton *)sender {
}
@end

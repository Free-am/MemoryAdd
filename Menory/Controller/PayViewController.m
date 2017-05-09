//
//  PayViewController.m
//  Oncenote
//
//  Created by user on 16/9/3.
//  Copyright © 2016年 chenyufengweb. All rights reserved.
//

#import "PayViewController.h"
#import "MainViewController.h"
#import <BmobSDK/Bmob.h>
#import "Constant.h"
#import "BmobOperation.h"
#import "AppDelegate.h"
#import "AllUtils.h"
#import "Finance.h"
#import <PNChart.h>
#import "PMCalendar.h"
#import "HistoryViewCell.h"

#import "MLFloatButton.h"
#import "ConstantCategory.h"
#import "LewPopupViewController.h"
#import "billCountView.h"


#import <objc/runtime.h>
#import <objc/message.h>
#import <libkern/OSAtomic.h>
#import <pthread.h>
#import "PayTableControl.h"

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDKUI.h>

#import <Masonry.h>
@interface PayViewController () <PMCalendarControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITableViewDataSource,UITableViewDelegate>
{
    MLFloatButton *floatButton;

}
//输入 字数 属性
@property (strong, nonatomic) IBOutlet UIView *myView;

@property (weak, nonatomic) IBOutlet UIView *firstCuttingLineView;


// 网格
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) HistoryViewCell *cell;
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic,strong) NSMutableArray *categoryArray;

// XIb属性
@property (weak, nonatomic) IBOutlet UITextField *billCount;
@property (weak, nonatomic) IBOutlet UITextField *billCategory;
- (IBAction)billDate:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIView *billViewXib;
@property (weak, nonatomic) IBOutlet UIButton *save;


@property (nonatomic,strong) billCountView *billCountXib;
@property (weak, nonatomic) IBOutlet UITextField *billRemark;

// 返回按钮的监听事件
- (IBAction)back;

@property (nonatomic,strong) PMCalendarController *pmCC;

@property (weak, nonatomic) IBOutlet UIView *myViewBar;


// 时间选择器
@property (strong, nonatomic) UIDatePicker *datePicker; //日期选择器
// 总开销
@property (weak, nonatomic) IBOutlet UILabel *sumPay;
@property (weak,nonatomic) NSNumber *total;


@property(nonatomic,assign) float sum;

@property(nonatomic,strong) PNPieChart *pieChart;

// 回调传值
@property (nonatomic,copy) void(^blockcategoryArray)(NSMutableArray *);

@property (nonatomic,copy) void(^blockFinanceAry)(NSMutableArray *);

@property (nonatomic,copy) void(^blockFinanceAryPutValue)(NSMutableArray *);// 把finance表的值传出去
@property (nonatomic,strong) NSMutableArray *financeAry;
@property (nonatomic,strong) NSMutableArray *financeCategorySum;
@property (nonatomic,strong) NSMutableDictionary *fianceDict;
@property(nonatomic,strong) NSMutableArray *financeAllAry;


- (IBAction)shareBtn:(UIButton *)sender;
@end

@implementation PayViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.categoryArray = [[NSMutableArray alloc] init];
    [self findFinanceAllValue];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    
    // 查找表
    [self findFinanceCategory];
    [_collectionView registerNib:[UINib nibWithNibName:@"HistoryViewCell" bundle:nil] forCellWithReuseIdentifier:@"HistoryViewCell"];
    
    
    
    
    [AllUtils setBackImage:self.myViewBar imageName:@"主页背景.png"];
    //    [self loadChart];
    //
    
    self.tableview.alpha = 0.9;
    self.tableview.layer.cornerRadius = 10;
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
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
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
    int index = self.financeAllAry.count - indexPath.row - 1;
    consumeLbl.text =[NSString stringWithFormat:@"%@",[[self.financeAllAry objectAtIndex:index] valueForKey:@"consume"] ] ;
    categoryLbl.text = [[self.financeAllAry objectAtIndex:index] valueForKey:@"category"];
    detailLbl.text = [[self.financeAllAry objectAtIndex:index] valueForKey:@"detail"];
    
    NSString *strDate = [NSString stringWithFormat:@"%@",[[self.financeAllAry objectAtIndex:index] valueForKey:@"financeDate"] ];
    dateLbl.text = [strDate substringWithRange:NSMakeRange(0, 10)];
    return cell;
    
}

- (nullable UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *rootView = [[UIView alloc] init];
    rootView.layer.cornerRadius = 10;
    rootView.alpha = 1;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width , 0 )];
    view.backgroundColor = [UIColor blackColor];
    //需要在Header底部加一条细线，用来分隔第一个cell；默认Header和第一个cell之间是没有分隔线的；
    
   
    
    // label “笔记”
    UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 40, 20)];
    noteLabel.text = @"名称";
    noteLabel.textColor = [UIColor blackColor];
    noteLabel.font = [UIFont systemFontOfSize:18];
    
    // label “全部”
    UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableView.bounds.size.width - 110, 10, 60, 20)];
    totalLabel.text = @"金额";
    totalLabel.textColor = [UIColor blackColor];
    totalLabel.font = [UIFont systemFontOfSize:20];
    
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
        int index = self.financeAllAry.count - indexPath.row - 1;
        //数据库删除；
        [BmobOperation deleteNoteFromDatabase:FINANCE_TABLE noteId:[[self.financeAllAry objectAtIndex:index] valueForKey:@"objId"]];
        [self.financeAllAry removeObjectAtIndex:index];//从数组中删除该值；
        [self.tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        
        self.fianceDict = nil;
        self.financeAry = nil;
        self.financeCategorySum = nil;
        self.categoryArray = nil;
        [self findFinanceCategory];
        [self.tableview reloadData];
            }
//    [self myReloadDate];
    

}


//点击Header,跳转到所有笔记页面；
- (void)noteHeaderPressed:(id)sender{
 
    [AllUtils jumpToViewController:@"PayTableControl" contextViewController:self handler:nil];
}








// 加载饼状图
- (void)loadChart
{
    [self.pieChart removeFromSuperview];
        UIColor *colorAry[6];
//    colorAry[0] = [UIColor colorWithRed:246 / 255.0 green:252 / 255.0 blue:174 / 255.0 alpha:1.0f];
        colorAry[0] = [UIColor orangeColor];
        colorAry[1] = [UIColor yellowColor];
        colorAry[2] = [UIColor greenColor];
        colorAry[3] = [UIColor cyanColor];
        colorAry[4] = [UIColor lightTextColor];
        colorAry[5] = [UIColor purpleColor];
    
    
        float financeSum = 0;
    
        NSMutableArray *itemMutAry = [[NSMutableArray alloc] initWithCapacity:3];
   
        for (int i=0; i<self.fianceDict.count; i++) {
            CGFloat _float = [self.financeCategorySum[i] floatValue];
            financeSum = financeSum + _float;
            PNPieChartDataItem *item = [PNPieChartDataItem dataItemWithValue:_float color:colorAry[i] description:self.categoryArray[i]];
            if (!(_float == 0)) {
                [itemMutAry addObject:item];
            }
            
        }
    self.sumPay.text = [NSString stringWithFormat:@"%.2f",financeSum];
        NSArray *itemAry = [NSArray arrayWithArray:itemMutAry];
    NSLog(@"itemAry%@",itemAry);
    
      
      
        // 初始化
        self.pieChart = [[PNPieChart alloc] initWithFrame:CGRectMake(10, 80, 150, 150) items:itemAry];
    
    CGFloat pieChartHeight = 150*self.view.bounds.size.width/320;

    
    
    
    
    
    
    
    _pieChart.descriptionTextColor = [UIColor blackColor];
    
        _pieChart.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:11.0];
        _pieChart.descriptionTextShadowColor = [UIColor clearColor]; // 阴影颜色
        _pieChart.showAbsoluteValues = YES; // 显示实际数值(不显示比例数字)
        _pieChart.showOnlyValues = NO; // 只显示数值不显示内容描述
        
        _pieChart.innerCircleRadius = 0;
      
        
        [self.
         
         pieChart strokeChart];
        
        
        
        _pieChart.legendStyle = PNLegendItemStyleStacked; // 标注排放样式
        _pieChart.legendFont = [UIFont boldSystemFontOfSize:12.0f];
        
    
        
        [self.view addSubview:_pieChart];
    
    
    // masonry 适配
    CGFloat pieChartWidth = pieChartHeight;
    [self.pieChart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(10);
        make.top.equalTo(self.firstCuttingLineView.mas_bottom).offset(10);
        make.width.mas_equalTo(pieChartWidth);
        make.height.mas_equalTo(pieChartHeight);
    }];
    
}

// 计算每个类别的值
- (void)calculateCategory
{
    NSLog(@"financedict%@",self.fianceDict);
//    for (int i=0; i<self.financeAry.count; i++) {
    for (int i=0; i<self.fianceDict.count; i++) {
    
//        NSArray *ary = self.financeAry[i];
        NSArray *ary1 = [self.fianceDict objectForKey:self.categoryArray[i]];
        
        NSNumber *sumNum;
        CGFloat sum = 0;
        NSLog(@"-----%lu",(unsigned long)ary1.count);
        if (!(ary1.count == 0)) {
            for (int j=0; j<ary1.count; j++) {
                //            CGFloat financeInt = [self.financeAry[i][j] floatValue];
                CGFloat financeInt = [ary1[j] floatValue];
                sum = sum + financeInt;
                sumNum = [NSNumber numberWithFloat:sum];
                
                
            }

        }else{
            sumNum = [NSNumber numberWithFloat:0.0];
        }
        [self.financeCategorySum addObject:sumNum];
        
    }
    [self loadChart];
   
}





// 悬浮按钮
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 这个一定要在这个方法里面，不然看不到效果
    // 悬浮按钮
    floatButton = [MLFloatButton loadFromNibWithFrame:CGRectMake(260, 280, 32, 32) addTarget:self InSuperView:self.view];
    
   

}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}











- (IBAction)back {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

//  点击屏幕隐藏键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.billCategory resignFirstResponder];
    [self.billCount resignFirstResponder];
    [self.billCountXib resignFirstResponder];
    [self.billCountXib.billCountText resignFirstResponder];
    [self.billCountXib resignFirstResponder];
    [self.billRemark resignFirstResponder];
    [self.billViewXib resignFirstResponder];
    [self.billCountXib.billComment resignFirstResponder];
}





- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}



#pragma  mark 网格

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.categoryArray.count;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(0, 10);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HistoryViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HistoryViewCell" forIndexPath:indexPath];
   
    cell.keyword = self.categoryArray[indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_cell == nil) {
        _cell = [[NSBundle mainBundle]loadNibNamed:@"HistoryViewCell" owner:nil options:nil][0];
    }
    _cell.keyword = self.categoryArray[indexPath.row];
    return [_cell sizeForCell];
}

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.tableview.delegate = nil;
    self.tableview.dataSource = nil;
    [self.tableview reloadData];
    self.billCountXib = [billCountView defaultPopupView];
    self.billCountXib.layer.cornerRadius = 10;
    self.billCountXib.alpha = 0.95;
    self.billCountXib.tag = 100;
    [self lew_presentPopupView:self.billCountXib animation:[LewPopupViewAnimationDrop new] dismissed:^{
        NSLog(@"动画结束");
        [self myReloadDate];
        
        
    }];
    


   
    [self.billCountXib.billViewXibSave addTarget:self action:@selector(saveConsumeAction:) forControlEvents:UIControlEventTouchDown];
    // 方法 传的参数
    [self.billCountXib.billViewXibSave setTag:indexPath.row];
    
   
}

#pragma  mark 刷新界面
- (void)myReloadDate
{
    
    
    self.fianceDict = nil;
    self.financeAry = nil;
    self.financeAllAry = nil;
    self.financeCategorySum = nil;
    self.categoryArray = nil;
    
    [self findFinanceAllValue];
    [self findFinanceCategory];
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    
}

//  保存监听方法
- (void) saveConsumeAction:(id)sender
{
    NSLog(@"sss");
    
    
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY/MM/dd hh:mm:ss SS"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    //这个sender其实就是UIButton，因此通过sender.tag就可以拿到刚才的参数
    int i = [sender tag];
    
    NSString *strCount = self.billCountXib.billCountText.text;
 
    NSString *strComment = self.billCountXib.billComment.text;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *numberCount = [numberFormatter numberFromString:strCount];
    
    NSString *strCategory = self.categoryArray[i];
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    NSString *userId = app.GLOBAL_USERID;
    BmobObject *obj = [BmobObject objectWithClassName:FINANCE_TABLE];
    if (numberCount) {
        [obj setObject:userId forKey:@"userId"];
        [obj setObject:strCategory forKey:@"category"];
        [obj setObject:numberCount forKey:@"consume"];
        [obj setObject:currentDate forKey:@"financeDate"];
        [obj setObject:strComment forKey:@"detail"];
        [obj saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            [AllUtils showLblToRemind:self.view backgroundColor:[UIColor blueColor] textColor:[UIColor redColor] message:@"保存成功" animateWithDuration:YES alpha:1];
            [self.billCountXib removeFromSuperview];
            self.fianceDict = nil;
            self.financeAry = nil;
            self.categoryArray = nil;
            [self findFinanceCategory];
        }];

    }else{
        UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提醒" message:@"金额不能为空" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertCon removeFromParentViewController];
        }];
        [alertCon addAction:okAction];
        [self presentViewController:alertCon animated:YES completion:nil];
        
    }
    }

#pragma mark - 悬浮按钮点击事件
- (void)buttonTouchAction {
    
    [[NSBundle mainBundle] loadNibNamed:[[self class] description] owner:self options:nil];
    self.billViewXib.frame = CGRectMake((self.view.frame.size.width-self.billViewXib.frame.size.width)/2 , 300, 300, 273);
    self.billViewXib.backgroundColor = [UIColor clearColor];
    [self lew_presentPopupView:self.billViewXib animation:[LewPopupViewAnimationSlide new] dismissed:^{
        NSLog(@"动画结束");
        [self.billViewXib removeFromSuperview];
        [self.datePicker removeFromSuperview];
        self.categoryArray = nil;
        self.fianceDict = nil;
        [self findFinanceCategory];
        
        self.financeAllAry = nil;
        [self findFinanceAllValue];
        
        self.tableview.delegate = self;
        self.tableview.dataSource = self;
        [self.tableview reloadData];
    }];
  

    [self.save addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchDown];
}

// 时间选择
- (IBAction)billDate:(UIButton *)sender {
    self.tableview.delegate = nil;
    self.tableview.dataSource = nil;
    [self.tableview reloadData];
    [self.billCategory resignFirstResponder];
    [self.billCount resignFirstResponder];
    [self.billCountXib resignFirstResponder];
    [self.billCountXib.billCountText resignFirstResponder];
    
    
    if (!self.datePicker) {
        self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 400, 300, 200)];
        [self.view addSubview:self.datePicker];
        
    }
}


- (void)saveAction
{
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    NSString *userId = app.GLOBAL_USERID;
    NSNumber *Consume = [NSNumber numberWithFloat:[self.billCount.text floatValue]] ;
    NSString *strCategory = self.billCategory.text;
    NSString *strRemark = self.billRemark.text;
    
    // 时间
    
    NSDate *date = self.datePicker.date;
    
    BmobObject *obj = [BmobObject objectWithClassName:FINANCE_TABLE];
    
    if (!(strCategory == nil)&&![strCategory  isEqual: @" "]) {
        
        [obj setObject:strCategory forKey:@"category"];
        [obj setObject:userId forKey:@"userId"];
        [obj setObject:strRemark forKey:@"detail"];
        
        
        BmobObject *bmob = [BmobObject objectWithClassName:FinanceCategory_TABLE];
        [bmob setObject:strCategory forKey:@"category"];
        [bmob setObject:userId forKey:@"userId"];
        [bmob saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            //进行操作
            if (isSuccessful) {
                NSLog(@"添加成功");
            }
            else{
                NSLog(@"添加失败");
            }
        }];

        
    
    }else{
        
        UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提醒" message:@"类别不能为空" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self buttonTouchAction];
            
        }];
        [alertCon addAction:okAction];
        [self presentViewController:alertCon animated:YES completion:nil];

        
    }
    
    
    if (!(Consume == nil)) {
        [obj setObject:Consume forKey:@"consume"];
    }else {
        UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提醒" message:@"金额不能为空" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self buttonTouchAction];
        }];
        [alertCon addAction:okAction];
        [self presentViewController:alertCon animated:YES completion:nil];

    }
    
    if (!(date == nil)) {
        [obj setObject:date forKey:@"financeDate"];
    }else{
        UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提醒" message:@"时间不能为空" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self buttonTouchAction];
        }];
        [alertCon addAction:okAction];
        [self presentViewController:alertCon animated:YES completion:nil];
    }
    
    [obj saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        //进行操作
        if (isSuccessful) {
            NSLog(@"添加成功");
            [AllUtils showLblToRemind:self.view backgroundColor:[UIColor blackColor] textColor:[UIColor redColor] message:@"保存成功" animateWithDuration:1 alpha:1];
            [self.billViewXib removeFromSuperview];
        }
        else{
            NSLog(@"添加失败");
        }
    }];
    
   
    [self.billViewXib removeFromSuperview];
    [self.datePicker removeFromSuperview];

}

- (NSMutableArray*)categoryArray
{
    if (!_categoryArray) {
        self.categoryArray = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return _categoryArray;
}
#pragma mark - 查询表 FinanceCateory

// 查询表 FinanceCateory
- (void)findFinanceCategory
{
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSString *userId = app.GLOBAL_USERID;
    BmobQuery *query = [BmobQuery queryWithClassName:FinanceCategory_TABLE];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            NSLog(@"错误");
        }else{
            for (BmobObject *obj in array) {
                if ([(NSString*)[obj objectForKey:@"userId"] isEqualToString:userId]) {
                    
                    NSString *str = [obj objectForKey:@"category"];
                    [self.categoryArray addObject:str];
                }
            }
            [self.collectionView reloadData];

            }

        [self findFinance];
        

    }];
    
}

// 查询表 Finance
- (void)findFinance
{
    
   
    
    
    
    
        NSLog(@"findFinance%@",self.categoryArray);
        __block int count = 0;
        for (int i=0; i<self.categoryArray.count; i++) {
            
                AppDelegate *app = [[UIApplication sharedApplication] delegate];
                NSString *userId = app.GLOBAL_USERID;
                BmobQuery *query = [BmobQuery queryWithClassName:FINANCE_TABLE];
                // 创建数组
                NSMutableArray *ary = [[NSMutableArray alloc] initWithCapacity:5];
                NSString *str = self.categoryArray[i];
                NSLog(@"在whereKey前输出i%d",i);
                
                [query whereKey:@"category" equalTo:str];
                
                [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
                    if (error) {
                        NSLog(@"error%@",error);
                    }else{
                        NSLog(@"i的值为%d",i);
                        ++count;
                        
                        for (BmobObject *obj in array) {
                            if ([(NSString*)[obj objectForKey:@"userId"] isEqualToString:userId]) {
                                
                                
                                NSNumber *numConsume = [obj objectForKey:@"consume"];
                                [ary addObject:numConsume];
                            }
                        }
                        
                        [self.financeAry addObject:ary];
                        [self.fianceDict setObject:ary forKey:self.categoryArray[i]];
                    }
                    //
                    if (count == self.categoryArray.count) {
                        //                     self.blockFinanceAryPutValue(self.financeAry);
                        NSLog(@"financeAry%@",self.financeAry);
                        [self calculateCategory];
                        
                    }
                    
                }];

            
            
            
            
        }
        
  
    
         

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
        self.tableview.frame = CGRectMake(self.tableview.frame.origin.x, self.tableview.frame.origin.y, self.tableview.frame.size.width, (([self.financeAllAry count] > 3 ? 3 : [self.financeAllAry count])+1 ) * 50);
        [self.tableview reloadData];
      
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








// 懒加载
- (NSMutableArray *)financeAry
{
    if (!_financeAry) {
        self.financeAry = [[NSMutableArray alloc] init];
    }
    return _financeAry;
    
}

- (NSMutableArray *)financeCategorySum
{
    if (!_financeCategorySum) {
        self.financeCategorySum = [[NSMutableArray alloc] initWithCapacity:5];
        
    }
    return _financeCategorySum;
}


- (NSMutableDictionary *)fianceDict
{
    if (!_fianceDict) {
        self.fianceDict = [[NSMutableDictionary alloc] init];
    }
    return _fianceDict;
}



- (IBAction)shareBtn:(UIButton *)sender {
    //1、创建分享参数
    NSArray* imageArray = @[[UIImage imageNamed:@"主页背景.png"]];
        if (imageArray) {
        
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:@"分享内容"
                                         images:imageArray
                                            url:[NSURL URLWithString:@"https://www.baidu.com/"]
                                          title:@"分享标题"
                                           type:SSDKContentTypeAuto];
        //2、分享（可以弹出我们的分享菜单和编辑界面）
        [ShareSDK showShareActionSheet:nil //要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图，只有传这个才可以弹出我们的分享菜单，可以传分享的按钮对象或者自己创建小的view 对象，iPhone可以传nil不会影响
                                 items:nil
                           shareParams:shareParams
                   onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                       
                       switch (state) {
                           case SSDKResponseStateSuccess:
                           {
                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                                   message:nil
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"确定"
                                                                         otherButtonTitles:nil];
                               [alertView show];
                               break;
                           }
                           case SSDKResponseStateFail:
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                               message:[NSString stringWithFormat:@"%@",error]
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                               break;
                           }
                           default:
                               break;
                       }
                   }
         ];}
}



@end

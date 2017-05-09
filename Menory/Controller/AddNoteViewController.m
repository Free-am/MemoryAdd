 //
//  AddNoteViewController.m
//  Oncenote
//
//  Created by chenyufeng on 15/11/13.
//  Copyright © 2015年 chenyufengweb. All rights reserved.
//

#import "AddNoteViewController.h"
#import "BmobOperation.h"
#import "Constant.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "AllUtils.h"
#import "MLFloatButton.h"
#import "BHBDrawBoarderView.h"
#import "LNERadialMenu.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <BmobSDK/Bmob.h>

#import "PopupView.h"
#import "LewPopupViewController.h"
#import "NoteCategryViewController.h"
#import "NoteCategory.h"
@interface AddNoteViewController () <LNERadialMenuDataSource,LNERadialMenuDelegate,UIImagePickerControllerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    MLFloatButton *floatButton;
    UIImagePickerController *_imagePickerController;
}
 
@property (weak, nonatomic) IBOutlet UIButton *categoryBtn;
@property (weak, nonatomic) IBOutlet UITextField *noteTitleTextField;
@property (weak, nonatomic) IBOutlet UITextView *noteTextTextView;

- (IBAction)noteCatagory;

@property(nonatomic,strong) NSMutableArray *allNotesCategory;
@property (weak, nonatomic) IBOutlet UIView *myView;
@property (strong, nonatomic) IBOutlet UIView *allView;

// 弹出画板属性

@property (nonatomic,strong) BHBDrawBoarderView * bv;

- (IBAction)drawAction:(UIButton *)sender;

@property(nonatomic,strong) NSMutableArray *categoryArray;
@property(nonatomic,weak) UITableView *tableView;
// 记录分类字符
@property(nonatomic,strong) NSString *noteBookStr;
@end

@implementation AddNoteViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.noteTitleTextField.text = self.noteTitle;
    self.noteTextTextView.text = self.noteText;
    
    if (self.category == nil) {
        [self.categoryBtn setTitle:@"选择类别" forState:UIControlStateNormal];
        [self.categoryBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else{
        
        [self.categoryBtn setTitle:self.category forState:UIControlStateNormal];
        [self.categoryBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.delegate = self;
    _imagePickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    _imagePickerController.allowsEditing = YES;
    
    self.noteTextTextView.layer.cornerRadius = 10;
    self.noteTextTextView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    self.categoryArray = [NSMutableArray array];// 储存类别名字的数组
    [AllUtils setBackImage:self.myView imageName:@"主页背景.png"];
    [AllUtils setBackImage:self.allView imageName:@"主页背景.png"];
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    [self queryNoteBookByUserId:NOTEBOOK_TABLE userId:app.GLOBAL_USERID limitCount:10];
}




// 悬浮按钮
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 这个一定要在这个方法里面，不然看不到效果
    // 悬浮按钮
    floatButton = [MLFloatButton loadFromNibWithFrame:CGRectMake(100, 100, 32, 32) addTarget:self InSuperView:self.view];
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(presentMenu:)];
    longPressRecognizer.minimumPressDuration = 1;
    
    [self.view addGestureRecognizer:longPressRecognizer];
}
#pragma mark 从摄像头获取图片或视频
- (void)selectImageFromCamera
{
    _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    //相机类型（拍照、录像...）字符串需要做相应的类型转换
    _imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
    
    
    
    //设置摄像头模式（拍照，录制视频）拍照模式
    _imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    [self presentViewController:_imagePickerController animated:YES completion:nil];
}

// 长按弹出按钮
-(void) presentMenu:(UILongPressGestureRecognizer *)gestureRecognizer{
    CGPoint location = [gestureRecognizer locationInView:self.view];
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
        LNERadialMenu *thisMenu = [[LNERadialMenu alloc] initFromPoint:location withDataSource:self andDelegate:self];
        
        [thisMenu showMenu];
    }
}

// 长按弹出按钮   代理
-(NSInteger) numberOfButtonsForRadialMenu:(LNERadialMenu *)radialMenu{
    return 2;
}

-(CGFloat) radiusLenghtForRadialMenu:(LNERadialMenu *)radialMenu{
    return 100;
}

-(UIButton *)radialMenu:(LNERadialMenu *)radialMenu elementAtIndex:(NSInteger)index{
    UIButton *element = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    element.backgroundColor = [UIColor whiteColor];
    element.layer.cornerRadius = element.bounds.size.height/2.0;
    element.layer.borderColor = [UIColor blackColor].CGColor;
    element.layer.borderWidth = 1;
    element.tag = index;
    
    return element;
}

-(void)radialMenu:(LNERadialMenu *)radialMenu didSelectButton:(UIButton *)button{
    NSLog(@"button(element) index:%ld",(long)button.tag);
    [radialMenu closeMenu];
}

-(UIView *)viewForCenterOfRadialMenu:(LNERadialMenu *)radialMenu{
    UIView *centerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
    
    centerView.backgroundColor = [UIColor blackColor];
    
    return centerView;
}

-(void)radialMenu:(LNERadialMenu *)radialMenu customizationForRadialMenuView:(UIView *)radialMenuView{
    CALayer *bgLayer = [CALayer layer];
    bgLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
    bgLayer.borderColor = [UIColor colorWithWhite:200.0/255.0 alpha:1].CGColor;
    bgLayer.borderWidth = 1;
    bgLayer.cornerRadius = radialMenu.menuRadius;
    bgLayer.frame = CGRectMake(radialMenuView.frame.size.width/2.0-radialMenu.menuRadius, radialMenuView.frame.size.height/2.0-radialMenu.menuRadius, radialMenu.menuRadius*2, radialMenu.menuRadius*2);
    [radialMenuView.layer insertSublayer:bgLayer atIndex:0];
}

-(BOOL)canDragRadialMenu:(LNERadialMenu *)radialMenu{
    return YES;
}


#pragma mark - 悬浮按钮点击弹出画板
- (void)buttonTouchAction {
    NSLog(@"点击了悬浮按钮");
    [self selectImageFromCamera];
    
}


// 当得到照片或者视频后，调用该方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"拍照成功");
    NSLog(@"%@", info);
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    // 判断获取类型：图片
    if ([mediaType isEqualToString:( NSString *)kUTTypeImage]){
        UIImage *theImage = nil;
        // 判断，图片是否允许修改
        if ([picker allowsEditing]){
            //获取用户编辑之后的图像
            theImage = [info objectForKey:UIImagePickerControllerEditedImage];
        } else {
            // 照片的元数据参数
            theImage = [info objectForKey:UIImagePickerControllerOriginalImage];
            
        }
        
        // 保存图片到相册中
        NSLog(@"--------%@",theImage);
        
        // 将拍照的图片显示到text中
        /*
        UIImageView *imgView = [[UIImageView alloc]init];
        imgView.image = theImage;
//        imgView.image = [UIImage imageNamed:@"guidepage0.png"];
        imgView.frame = CGRectMake(10, 10, 300, 300);
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        [self.noteTextTextView addSubview:imgView];
        */
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:self.noteTextTextView.attributedText];
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil] ;
        textAttachment.image = theImage;
        textAttachment.bounds = CGRectMake(0, 0, (theImage.size.width)/2 , (theImage.size.height)/2);
        
        
        NSAttributedString *textAttachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [string insertAttributedString:textAttachmentString atIndex:0];//index为用户指定要插入图片的位置
        
        self.noteTextTextView.attributedText = string;
        
        
        SEL selectorToCall = @selector(imageWasSavedSuccessfully:didFinishSavingWithError:contextInfo:);
        UIImageWriteToSavedPhotosAlbum(theImage, self,selectorToCall, NULL);
        
    }
    
    [picker dismissModalViewControllerAnimated:YES];
}

//保存照片
- (void) imageWasSavedSuccessfully:(UIImage *)paramImage didFinishSavingWithError:(NSError *)paramError contextInfo:(void *)paramContextInfo{
    if (paramError == nil){
        NSLog(@"图片保存成功");
        
    } else {
        NSLog(@"保存图片出错");
        NSLog(@"Error = %@", paramError);
    }
}

// 当用户取消时，调用该方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark - 相册操作

- (void)selectFromAlbum{
    
   
        UIImagePickerController *controller = [[UIImagePickerController alloc]init];
        [controller setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];// 设置类型
        NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
    
            [mediaTypes addObject:( NSString *)kUTTypeImage];
    
    
            [mediaTypes addObject:( NSString *)kUTTypeMovie];
    
        
        [controller setMediaTypes:mediaTypes];
        [controller setDelegate:self];// 设置代理
        [self presentViewController:_imagePickerController animated:YES completion:nil];
    
    
    
    
}




#pragma mark - 所有按钮的点击事件
- (IBAction)naviStoreButtonPressed:(id)sender {

  AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
  NSString *userId = app.GLOBAL_USERID;
  NSString *username = app.GLOBAL_USERNAME;
    
  NSString *noteTitle = [self.noteTitleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSString *noteText = [self.noteTextTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // 编辑笔记的时候，如果标题和内容 不为空 才可以添加
  if (![noteTitle  isEqual: @""] && ![noteText  isEqual: @""]){
    //    BmobOperation *operate = [[BmobOperation alloc] init];
      
      [BmobOperation addNoteToNoteTable:NOTE_TABLE userId:userId  username:username noteTitle:noteTitle noteText:noteText noteBookCategory:self.noteBookStr todo:^(BOOL isSuccessful, NSError *error) {
      if (isSuccessful) {
        
        [AllUtils showPromptDialog:@"提示" andMessage:@"增加一条笔记成功" OKButton:@"确定" OKButtonAction:^(UIAlertAction *action) {
          //跳回到主界面；
          [AllUtils jumpToViewController:@"MainViewController" contextViewController:self handler:nil];
          NSLog(@"回到主界面");
        } cancelButton:@"" cancelButtonAction:nil contextViewController:self];
      }else {

        [AllUtils showPromptDialog:@"提示" andMessage:@"服务器异常，增加笔记失败！" OKButton:@"确定" OKButtonAction:nil cancelButton:@"" cancelButtonAction:nil contextViewController:self];
      }
    }];
  }else{

    [AllUtils showPromptDialog:@"提示" andMessage:@"标题和内容缺一不可！" OKButton:@"确定" OKButtonAction:nil cancelButton:@"" cancelButtonAction:nil contextViewController:self];
  }
}

- (IBAction)drawAction:(UIButton *)sender {
    self.bv = [[BHBDrawBoarderView alloc] initWithFrame:CGRectZero];
    [self.bv show];
}

// 取消键盘第一响应者
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.noteTitleTextField resignFirstResponder];
    [self.noteTextTextView resignFirstResponder];

}

// 类别 按钮 监听方法
- (IBAction)noteCatagory {

   

    PopupView *view = [PopupView defaultPopupView];
    view.parentVC = self;
    view.innerView.delegate = self;
    view.innerView.dataSource = self;
    self.tableView = view.innerView;
    [self lew_presentPopupView:view animation:[LewPopupViewAnimationDrop new] dismissed:^{
        NSLog(@"动画结束");
    }];

    
}





#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.categoryArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"cell%@",self.categoryArray);

    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    NSUInteger row = [indexPath row];
    cell.textLabel.text = [self.categoryArray objectAtIndex:row];
    
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 60;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *rootView = [[UIView alloc] init];
    
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width , 100 )];
        //需要在Header底部加一条细线，用来分隔第一个cell；默认Header和第一个cell之间是没有分隔线的；
        
        // 笔记icon
        UIImageView *noteIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8, 50, 50)];
        [noteIcon setImage:[UIImage imageNamed:@"分类.png"]];
        
        // label “笔记”
        UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 10, 150, 40)];
        noteLabel.text = @"类别（点击）";
        noteLabel.textColor = [UIColor colorWithRed:0 green:0.6 blue:0.26 alpha:1];
        
   
        
        // 箭头
        UIImageView *arrowIcon = [[UIImageView alloc] initWithFrame:CGRectMake(tableView.bounds.size.width - 30, 10, 30, 30)];
        [arrowIcon setImage:[UIImage imageNamed:@"向右箭头.png"]];
        
        //在Header底部绘制一条线；
        UIView *drawLine = [[UIView alloc] initWithFrame:CGRectMake(0, 49, tableView.bounds.size.width, 1)];
        drawLine.backgroundColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1];
        
        [view addSubview:noteIcon];
        [view addSubview:noteLabel];
        [view addSubview:arrowIcon];
        [view addSubview:drawLine];
        //增加Header的点击事件；
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addCategory)]];
        rootView = view;
    
    
    
    return rootView;
    
    
}

// 监听 cell的点击方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
   

    self.noteBookStr = [self.categoryArray objectAtIndex:row];
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //左滑删除；
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        BmobQuery *bquery = [BmobQuery queryWithClassName:NOTEBOOK_TABLE];
        [bquery whereKey:@"noteBookCategoy" equalTo:[self.categoryArray objectAtIndex:indexPath.row]];
        [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            for (BmobObject *obj in array) {
                NSString *objId = [obj objectForKey:@"objectId"];
                //数据库删除；
                [BmobOperation deleteNoteFromDatabase:NOTEBOOK_TABLE noteId:objId];
                [self.categoryArray removeObjectAtIndex:indexPath.row];//从数组中删除该值；
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                
            }
            
            
        }];
    }
}

- (void)addCategory
{
    
    

    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"添加类别" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
    
    // 只有在alert情况下才可以添加文本框
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"输入类别的名字";
        textField.secureTextEntry = NO;
        textField.keyboardType = UIKeyboardTypeNamePhonePad;
    }];
    
    
    // 创建按钮
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        NSLog(@"注意确定");
        
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        NSString *text = alertController.textFields.firstObject.text;
//        [self.categoryArray addObject:text];
        BmobQuery *queryNote = [BmobQuery queryWithClassName:NOTEBOOK_TABLE];
        [queryNote orderByDescending:@"updatedAt"];
        queryNote.limit = 10;
        NSMutableArray *ary = [[NSMutableArray alloc] init];
        [queryNote findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            if (error) {
                NSLog(@"查询笔记本错误");
            } else {
                //      NSLog(@"正在查询笔记。。。");
                
                for (BmobObject *obj in array) {
                    
                    if ([(NSString*)[obj objectForKey:@"userId"] isEqualToString:app.GLOBAL_USERID]) {
                        
                        NSString *str = [obj objectForKey:@"noteBookCategoy"];
                        [ary addObject:str];
                        
                    }//if(
                }//for();
            }//else();
            BOOL isful = NO;
            for (NSString *str in ary) {
                if (str == text) {
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"类别已存在！" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
                    [alert show];
                    // 2秒后消失
                    [self performSelector:@selector(dimissAlert:) withObject:alert afterDelay:0.8];
                    isful = YES;

                    
                    }
                 }
            if (!isful) {
                [self.categoryArray addObject:text];
                NSLog(@"%@",self.categoryArray);
                [BmobOperation addCategoryToNotebook:NOTEBOOK_TABLE userId:app.GLOBAL_USERID username:app.GLOBAL_USERNAME noteBookCategory:(NSString*)text todo:^(BOOL isSuccessful, NSError *error) {
                } ];
            }
                        
//                        [self.categoryArray addObject:text];
//                        NSLog(@"%@",self.categoryArray);
//                        [BmobOperation addCategoryToNotebook:NOTEBOOK_TABLE userId:app.GLOBAL_USERID username:app.GLOBAL_USERNAME noteBookCategory:(NSString*)text todo:^(BOOL isSuccessful, NSError *error) {
//                        } ];
//

            
           
            
            
            [self.tableView reloadData];
        }];
        
        
        
        
        
        
        
        
        
        
        //        NoteCategryViewController *noteCategoryViewConroller = [[NoteCategryViewController alloc] init];
        
        //        NSLog(@"%@",noteCategoryViewConroller.allNotesCategory);
        
        
        
        
        
        
        // 刷新整个tableview
        [self.tableView reloadData];
        
        
    }];
    
    // 创建按钮
    // 注意取消按钮只能添加一个
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction *action) {
        // 点击按钮后的方法直接在这里面写
        NSLog(@"注意取消");
    }];
    
   
    // 添加按钮 将按钮添加到UIAlertController对象上
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    
    
    
    // 将UIAlertController模态出来 相当于UIAlertView show 的方法
    [self presentViewController:alertController animated:YES completion:nil];
    
    
    
    
    
    
}



//  查询 笔记 类别
- (void) queryNoteBookByUserId:(NSString*)tableName userId:(NSString*)userId limitCount:(int)limitCount{
    
    BmobQuery *queryNote = [BmobQuery queryWithClassName:tableName];
    [queryNote orderByDescending:@"updatedAt"];
    queryNote.limit = limitCount;
    [queryNote findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            NSLog(@"查询笔记本错误");
        } else {
            //      NSLog(@"正在查询笔记。。。");
            
            for (BmobObject *obj in array) {
                
                if ([(NSString*)[obj objectForKey:@"userId"] isEqualToString:userId]) {
                    NSString *str = [obj objectForKey:@"noteBookCategoy"];
                  [self.categoryArray addObject:str];
                    
                    
                }//if(
            }//for();
        }//else();
        NSLog(@"%@",self.categoryArray);
    }];
}

// 移除弹框
- (void) dimissAlert:(UIAlertView *)alert {
    if(alert){
        [alert dismissWithClickedButtonIndex:[alert cancelButtonIndex] animated:YES];
    }
    
}

@end

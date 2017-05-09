//
//  NoteCategryViewController.h
//  Menory
//
//  Created by user on 16/10/9.
//  Copyright © 2016年 Corbin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteCategryViewController : UIViewController

@property(nonatomic,copy) NSString* tempTitle;
@property(nonatomic,copy) NSString* tempText;
@property(nonatomic,strong) NSIndexPath* tempIndexPath;

@property(nonatomic,strong) NSMutableArray *allNotesCategory;

@end

//
//  AddNoteViewController.h
//  Oncenote
//
//  Created by chenyufeng on 15/11/13.
//  Copyright © 2015年 chenyufengweb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddNoteViewController : UIViewController


@property(nonatomic,copy) NSString *noteId;
@property(nonatomic,copy) NSString *noteTitle;
@property(nonatomic,copy) NSString *noteText;
@property(nonatomic,strong) NSIndexPath *indexPath;
@property(nonatomic,copy) NSString *category;

@end

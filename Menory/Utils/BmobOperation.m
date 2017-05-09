//
//  BmobOperation.m
//  Oncenote
//
//  Created by chenyufeng on 15/11/13.
//  Copyright © 2015年 chenyufengweb. All rights reserved.
//

#import "BmobOperation.h"
#import <BmobSDK/Bmob.h>

@implementation BmobOperation

#pragma mark - 往笔记本添加分类
+ (void)addCategoryToNotebook:(NSString*)tableName userId:(NSString*)userId username:(NSString*)username noteBookCategory:(NSString*)noteBookCategory todo:(void(^)(BOOL isSuccessful,NSError *error)) todo{
    
    BmobObject *noteBook = [BmobObject objectWithClassName:tableName];
    [noteBook setObject:userId forKey:@"userId"];
    [noteBook setObject:username forKey:@"username"];
    [noteBook setObject:noteBookCategory forKey:@"noteBookCategoy"];
    [noteBook saveInBackgroundWithResultBlock:todo];
}

#pragma mark - 往数据库中插入一条笔记
//插入一条笔记到Note表，包括，userId(用户ID),username(用户名)，noteTitle（笔记标题），noteText（笔记内容）;4个字段；
+ (void)addNoteToNoteTable:(NSString*)tableName userId:(NSString*)userId  username:(NSString*)username  noteTitle:(NSString*)noteTitle noteText:(NSString*)noteText noteBookCategory:(NSString*)noteBookCategory todo:(void(^)(BOOL isSuccessful, NSError *error)) todo{
  
  BmobObject *note = [BmobObject objectWithClassName:tableName];
  [note setObject:userId forKey:@"userId"];
  [note setObject:username forKey:@"username"];
  [note setObject:noteTitle forKey:@"noteTitle"];
  [note setObject:noteText forKey:@"noteText"];
  [note setObject:noteBookCategory forKey:@"noteBook"];
  [note saveInBackgroundWithResultBlock:todo];
}

#pragma mark - 往数据库中删除一条笔记
+ (void)deleteNoteFromDatabase:(NSString*)tableName noteId:(NSString*)noteId{
  
  BmobQuery *delete = [BmobQuery queryWithClassName:tableName];
  [delete getObjectInBackgroundWithId:noteId block:^(BmobObject *object, NSError *error){
    if (error) {
      //进行错误处理
    }
    else{
      if (object) {
        //异步删除object
        [object deleteInBackground];
      }
    }
  }];
    
}

//  插入记账
+ (void)addNNumberToFinanceTable:(NSString*)tableName userId:(NSString*)userId  username:(NSString*)username  meals:(NSNumber*)meals  other:(NSNumber*)other party:(NSNumber*)party livingGoods:(NSNumber*)livingGoods financeDate:(NSDate *)financeDate total:(NSNumber*)total todo:(void(^)(BOOL isSuccessful, NSError *error)) todo{
    BmobObject *finance = [BmobObject objectWithClassName:tableName];
    [finance setObject:userId forKey:@"userId"];
    [finance setObject:username forKey:@"username"];
    [finance setObject:meals forKey:@"meals"];
    [finance setObject:livingGoods forKey:@"livingGoods"];
    
    [finance setObject:other forKey:@"other"];
    [finance setObject:party forKey:@"party"];
    [finance setObject:financeDate forKey:@"financeDate"];
    [finance setObject:total forKey:@"total"];
    [finance saveInBackgroundWithResultBlock:todo];


}


// 向倒计时表添加数据
+(void)addDataToMDayMatter:(NSString *)tableName userId:(NSString *)userId title:(NSString *)title date:(NSData *)date todo:(void(^)(BOOL isSuccessful, NSError *error)) todo{
    BmobObject *MDatMatter = [BmobObject objectWithClassName:tableName];
    [MDatMatter setObject:userId forKey:@"MDMUserId"];
    [MDatMatter setObject:title forKey:@"MDMtitle"];
    [MDatMatter setObject:date forKey:@"MDMdate"];
    [MDatMatter saveInBackgroundWithResultBlock:todo];
}
#pragma mark - 修改用户的昵称
//+ (void)updateNicknameToUserTable:(NSString*)tableName userId:(NSString*)userId nickname:(NSString*)nickname{
//
//  BmobQuery *update = [BmobQuery queryWithClassName:tableName];
//  [update getObjectInBackgroundWithId:userId block:^(BmobObject *object,NSError *error){
//    if (!error) {
//      if (object) {
//        [object setObject:nickname forKey:@"nickname"];
//      
//        [object updateInBackground];
//      }
//    }else{
//      //进行错误处理
//    }
//  }];
//}

@end

//
//  BmobOperation.h
//  Oncenote
//
//  Created by chenyufeng on 15/11/13.
//  Copyright © 2015年 chenyufengweb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BmobOperation : NSObject

+ (void)addNoteToNoteTable:(NSString*)tableName userId:(NSString*)userId  username:(NSString*)username  noteTitle:(NSString*)noteTitle noteText:(NSString*)noteText noteBookCategory:(NSString*)noteBookCategory todo:(void(^)(BOOL isSuccessful, NSError *error)) todo;
+ (void)deleteNoteFromDatabase:(NSString*)tableName noteId:(NSString*)noteId;

// 记账方法
+ (void)addNNumberToFinanceTable:(NSString*)tableName userId:(NSString*)userId  username:(NSString*)username  meals:(NSNumber*)meals  other:(NSNumber*)other party:(NSNumber*)party livingGoods:(NSNumber*)livingGoods financeDate:(NSDate *)financeDate total:(NSNumber*)total todo:(void(^)(BOOL isSuccessful, NSError *error)) todo;

//+ (void)updateNicknameToUserTable:(NSString*)tableName userId:(NSString*)userId nickname:(NSString*)nickname;

// 往笔记本添加笔记分类
+ (void)addCategoryToNotebook:(NSString*)tableName userId:(NSString*)userId username:(NSString*)username noteBookCategory:(NSString*)noteBookCategory todo:(void(^)(BOOL isSuccessful,NSError *error)) todo;

// 往倒计时添加数据
+(void)addDataToMDayMatter:(NSString *)tableName userId:(NSString *)userId title:(NSString *)title date:(NSData *)date todo:(void(^)(BOOL isSuccessful, NSError *error)) todo;
@end

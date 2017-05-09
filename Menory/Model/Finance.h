//
//  Finance.h
//  Oncenote
//
//  Created by user on 16/9/5.
//  Copyright © 2016年 chenyufengweb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Finance : NSObject

@property(nonatomic,copy) NSString *objId;
@property(nonatomic,copy) NSString *userId;
@property(nonatomic,copy) NSNumber *breakfast;
@property(nonatomic,copy) NSNumber *lunch;
@property(nonatomic,copy) NSNumber *dinner;
@property(nonatomic,copy) NSNumber *other;
@property(nonatomic,copy) NSNumber *party;
@property(nonatomic,copy) NSNumber *total;
@property(nonatomic,copy) NSNumber *meals;
@property(nonatomic,copy) NSNumber *livingGoods;
@property(nonatomic,copy) NSDate *financeDate;
@property(nonatomic,copy) NSString *category;
@property(nonatomic,copy) NSNumber *consume;
@property(nonatomic,copy) NSString *detail;

@end

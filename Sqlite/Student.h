//
//  Student.h
//  Sqlite
//
//  Created by 未央生 on 2017/11/28.
//  Copyright © 2017年 未央生. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SqliteTbale.h"

@interface Student : SqliteTbale

@property (nonatomic , copy)NSString *name;
@property (nonatomic , assign)NSInteger age;
@property (nonatomic , copy)NSString *adress;
@property (nonatomic , assign)float height;

@end

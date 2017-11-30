//
//  Student.m
//  Sqlite
//
//  Created by 未央生 on 2017/11/28.
//  Copyright © 2017年 未央生. All rights reserved.
//

#import "Student.h"

@implementation Student

- (NSDictionary *)allFieldType{
    return @{@"age":@"integer",
             @"name":@"text",
             @"adress":@"text",
             @"height":@"REAL"
             };
}

- (NSString *)primaryKey{
    return @"name";
}

@end

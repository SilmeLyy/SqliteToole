//
//  SqliteTbale.m
//  Sqlite
//
//  Created by 未央生 on 2017/11/28.
//  Copyright © 2017年 未央生. All rights reserved.
//

#import "SqliteTbale.h"
#import "SqliteManager.h"

@implementation SqliteTbale

///建议子类都这样写建表
+ (void)initialize{
    SqliteTbale *table = [[self alloc] init];
    [SqliteManager createTbaleWihtTableClass:table];
}

- (NSDictionary *)allFieldType{
    return @{};
}

- (NSString *)primaryKey{
    return @"";
}

@end

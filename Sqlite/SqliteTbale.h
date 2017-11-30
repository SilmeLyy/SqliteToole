//
//  SqliteTbale.h
//  Sqlite
//
//  Created by 未央生 on 2017/11/28.
//  Copyright © 2017年 未央生. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SqliteTbale : NSObject
/*
 * 需要返回所有字段和对应的类型
 * 支持以下四个类型
 * {@"name"  :  @"TEXT",
 *  @"gae"   :  @"INTEGER",
 *  @"adress":  @"BLOB",
 *  @"height":  @"REAL"
 * }
 */
- (NSDictionary *)allFieldType;

/*
 * 需要返回那个字段是主键
 */
- (NSString *)primaryKey;

@end

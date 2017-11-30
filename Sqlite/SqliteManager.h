//
//  SqliteManager.h
//  Sqlite
//
//  Created by 未央生 on 2017/11/28.
//  Copyright © 2017年 未央生. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DATABASEPATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject] stringByAppendingPathComponent:@"PEPSIDataBase.db"]

@class SqliteTbale;
@interface SqliteManager : NSObject

/*
 * 建表表
 * @param table 表名，具体字段看SqliteTbale类
 */
+ (BOOL)createTbaleWihtTableClass:(SqliteTbale *)tableClass;

/*
 * 插入表
 * @param table 表
 * insert into table(name,age,height) values('name','age','height')
 *
 */
+ (BOOL)insertTbale:(SqliteTbale *)table;

/*
 * 插入表
 * @param table 表
 * @param values 插入那些字段[@"name",@"age"]
 * insert into table(name,age) values('name','age')
 *
 */
+ (BOOL)insertTbale:(SqliteTbale *)table andValues:(NSArray *)values;

/*
 * 更新
 * @param table 表
 * @param keys 更新那一条数据数组[@"name",@"age"]
 *             where name = %@ and age = %d
 * update table set table.name = %@, table.age = %d where name = %@ and gae = %d
 */
+ (BOOL)updateTbale:(SqliteTbale *)table andKeys:(NSArray *)keys;

/*
 * 插入表
 * @param table 表
 * @param keys 更新那一条数据数组[@"name",@"age"]
 *             where name = %@ and age = %d
 * @param values 更新那些字段 [@"name",@"age"]
 *               只会更新name和age字段
 * update table set name = %@, age = %d where name = %@ and gae = %d
 */
+ (BOOL)updateTbale:(SqliteTbale *)table andKeys:(NSArray *)keys andValues:(NSArray *)values;

/*
 * 升级数据库表
 * @param tableName 表名
 * @param version   表升级后的版本，不能低于之前的版本（初始版本为1）
 *                  更新的字段直接添加在【SqliteTbale allFieldType】方法里就行
 *
 */
+ (BOOL)upgradeTableWithTable:(SqliteTbale *)table andVersion:(NSInteger)version;

/*
 * 查询表
 * @param table 表
 * @param keys 查询那一条数据数组[@"name",@"age"]
 * select * from table where name = %@ and age = %d
 */
+ (NSArray *)getDataWithTable:(SqliteTbale *)table andKeys:(NSArray *)keys;

/*
 * 查询表里所以数据
 * @param table 表
 * select * from table
 */
+ (NSArray *)getDataWithAllTable:(SqliteTbale *)table;

/*
 * 清空一张表的数据
 * @param table 表
 * delete from table
 */
+ (BOOL)cleanTableWithTable:(SqliteTbale *)table;

/*
 * 删除表里的数据
 * @param table 表
 * @param keys 删除那一条数据数组[@"name",@"age"]
 * delete from table Where name = %@ and age = %d
 */
+ (BOOL)deleteDataWithAllTable:(SqliteTbale *)table andKeys:(NSArray *)keys;

@end

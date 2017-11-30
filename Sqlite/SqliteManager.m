//
//  SqliteManager.m
//  Sqlite
//
//  Created by 未央生 on 2017/11/28.
//  Copyright © 2017年 未央生. All rights reserved.
//

#import "SqliteManager.h"
#import <FMDB.h>
#import <objc/runtime.h>
#import "SqliteTbale.h"

@implementation SqliteManager

+ (void)initialize{
    [self createDataBaseWithPath:DATABASEPATH];
}

/*
 * 创建数据库
 * @param path 数据库路径
 */
+ (BOOL)createDataBaseWithPath:(NSString *)path{
    BOOL isSuccess = 0x00;
    ///新建一个关于数据库的表
    FMDatabase *db = [FMDatabase databaseWithPath:path];
    if ([db open]) {
        ///创建表  预留了三个字段 col1 col2 col3
        isSuccess = [db executeStatements:@"CREATE TABLE IF NOT EXISTS DataBaseTable(num integer ,tableName text PRIMARY KEY,version integer,keys BLOB,col1 text,col2 text,col3 text)"];
        [db close];
    }
    return isSuccess;
}

/*
 * 创建表
 * @param tableClass 表名
 *
 */
+ (BOOL)createTbaleWihtTableClass:(SqliteTbale *)tableClass{
    BOOL isSuccess = 0x00;
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASEPATH];
    if ([db open]) {
         FMResultSet *set = [db executeQueryWithFormat:@"SELECT * FROM DataBaseTable WHERE tableName = %@",NSStringFromClass([tableClass class])];
        ///表已经创建过
        if ([set next]) {
            
        }else{
            NSDictionary *dic = [tableClass allFieldType];
            NSArray *keys = [dic allKeys];
            ///拼接建表语句
            NSString *execStr = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(num integer,",NSStringFromClass([tableClass class])];
            for (NSString *key in keys) {
                execStr = [NSString stringWithFormat:@"%@%@ ",execStr,key];
                NSString *value = dic[key];
                execStr = [NSString stringWithFormat:@"%@%@ ",execStr,value];
                ///主键
                if ([key isEqualToString:[tableClass primaryKey]]) {
                    execStr = [NSString stringWithFormat:@"%@PRIMARY KEY,",execStr];
                }else{
                    execStr = [NSString stringWithFormat:@"%@,",execStr];
                }
            }
            ///移除最后一个逗号
            execStr = [execStr substringToIndex:execStr.length - 1];
            execStr = [NSString stringWithFormat:@"%@)",execStr];
            isSuccess = [db executeStatements:execStr];
            
            ///先保存字段
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[dic allKeys]];
            ///将表名插入数据表里默认数据表版本为1
            isSuccess = [db executeUpdateWithFormat:@"INSERT INTO DataBaseTable(tableName,version,keys) VALUES(%@,%d,%@)",NSStringFromClass([tableClass class]),1,data];
        }
        [db close];
    }
    return isSuccess;
}

/*
 * 创建表
 * @param tableClass 表名
 *
 */
+ (BOOL)onlyCreateTbaleWihtTableClass:(SqliteTbale *)tableClass andDb:(FMDatabase *)db{
    BOOL isSuccess = 0x00;
    NSDictionary *dic = [tableClass allFieldType];
    NSArray *keys = [dic allKeys];
    ///拼接建表语句
    NSString *execStr = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(num integer,",NSStringFromClass([tableClass class])];
    for (NSString *key in keys) {
        execStr = [NSString stringWithFormat:@"%@%@ ",execStr,key];
        NSString *value = dic[key];
        execStr = [NSString stringWithFormat:@"%@%@ ",execStr,value];
        ///主键
        if ([key isEqualToString:[tableClass primaryKey]]) {
            execStr = [NSString stringWithFormat:@"%@PRIMARY KEY,",execStr];
        }else{
            execStr = [NSString stringWithFormat:@"%@,",execStr];
        }
    }
    ///移除最后一个逗号
    execStr = [execStr substringToIndex:execStr.length - 1];
    execStr = [NSString stringWithFormat:@"%@)",execStr];
    isSuccess = [db executeStatements:execStr];
    return isSuccess;
}

/*
 * 数据库插入
 * table 表名
 * table.property 插入的值
 */
+ (BOOL)insertTbale:(SqliteTbale *)table{
    NSDictionary *dic = [table allFieldType];
    NSArray *keys = [dic allKeys];
    return [self insertTbale:table andValues:keys];
}

/*
 * 插入表
 * @param table 表
 * @param values 插入那些字段[@"name",@"age"]
 * insert into table(name,age) values('name','age')
 *
 */
+ (BOOL)insertTbale:(SqliteTbale *)table andValues:(NSArray *)values{
    NSAssert([[table allFieldType] count], @"请设置字段类型");
    BOOL isSuccess = 0x00;
    [self createTbaleWihtTableClass:table];
    NSDictionary *dic = [table allFieldType];
    NSString *execStr = [NSString stringWithFormat:@"INSERT INTO %@(",NSStringFromClass([table class])];
    for (NSString *key in values) {
        execStr = [NSString stringWithFormat:@"%@%@,",execStr,key];
    }
    execStr = [execStr substringToIndex:execStr.length - 1];
    execStr = [NSString stringWithFormat:@"%@) VALUES(",execStr];
    for (NSString *key in values) {
        NSString *value = dic[key];
        if ([value isEqualToString:@"text"]) {
            execStr = [NSString stringWithFormat:@"%@'%@',",execStr,[table valueForKey:key]];
        }else if ([value isEqualToString:@"integer"]){
            execStr = [NSString stringWithFormat:@"%@'%ld',",execStr,(long)[[table valueForKey:key] integerValue]];
        }else if ([value isEqualToString:@"BLOB"]){
            execStr = [NSString stringWithFormat:@"%@'%@',",execStr,[table valueForKey:key]];
        }else if ([value isEqualToString:@"REAL"]){
            execStr = [NSString stringWithFormat:@"%@'%f',",execStr,[[table valueForKey:key] doubleValue]];
        }
    }
    execStr = [execStr substringToIndex:execStr.length - 1];
    execStr = [NSString stringWithFormat:@"%@)",execStr];
    ///执行数据库语句
    isSuccess = [self execSqlite:execStr];
    return isSuccess;
}

/*
 * 插入表
 * @param table 表
 * @param keys 更新那一条数据数组[@"name",@"age"]
 *             where name = %@ and age = %d
 */
+ (BOOL)updateTbale:(SqliteTbale *)table andKeys:(NSArray *)keys{
    NSArray *allValue = [[table allFieldType] allKeys];
    return [self updateTbale:table andKeys:keys andValues:allValue];
}

/*
 * 插入表
 * @param table 表
 * @param keys 更新那一条数据数组[@"name",@"age"]
 *             where name = %@ and age = %d
 * @param values 更新那些字段 [@"name",@"age"]
 *               只会更新name和age字段
 */
+ (BOOL)updateTbale:(SqliteTbale *)table andKeys:(NSArray *)keys andValues:(NSArray *)values{
    NSDictionary *dic = [table allFieldType];
    NSString *execStr = [NSString stringWithFormat:@"UPDATE %@ SET ",NSStringFromClass([table class])];
    for (NSString *key in values) {
        execStr = [self updateSetProperty:dic andKey:key andExecStr:execStr andTable:table];
    }
    execStr = [execStr substringToIndex:execStr.length - 1];
    execStr = [NSString stringWithFormat:@"%@ WHERE ",execStr];
    for (NSString *key in keys) {
        execStr = [self updateWhereProperty:dic andKey:key andExecStr:execStr andTable:table];
    }
    execStr = [execStr substringToIndex:execStr.length - 5];
    ///执行数据库语句
    return [self execSqlite:execStr];
}

/*
 * 插入表
 * @param tableName 表名
 * @param version   表升级后的版本，不能低于之前的版本（初始版本为1）
 *                  更新的字段直接添加在【SqliteTbale allFieldType】
 *                  方法里就行(目前只能添加字段，不能删除字段)
 *
 * 更新步骤
 * 1，将表名改为temp
 * 2，新建一张字段为升级过后的表
 * 3，将temp表的数据插入新表里
 * 4，drop temp表
 */
+ (BOOL)upgradeTableWithTable:(SqliteTbale *)table andVersion:(NSInteger)version{
    __block BOOL isSuccess = 0x00;
    //1，将表名改为temp
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASEPATH];
    if ([db open]) {
        //先查看原来的版本
        NSString *select = [NSString stringWithFormat:@"SELECT * FROM DataBaseTable WHERE tableName = '%@'",NSStringFromClass([table class])];
        FMResultSet *set = [db executeQuery:select];
        while ([set next]) {
            int V = [set intForColumn:@"version"];
            if (version <= V) {
                NSLog(@"此表之前的版本为：%d",V);
                NSAssert(version > V, @"表的版本应大于之前的版本");
            }else{//进行表升级操作
                @try{
                    NSData *data = (NSData *)[set objectForColumn:@"keys"];
                    ///之前表的字段
                    NSArray *beforeArr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                    //将原始表名table 修改为 tempT1
                    NSString *renameString = [NSString stringWithFormat:@"alter table %@ rename to tempT1",NSStringFromClass([table class])];
                    
                    isSuccess = [db executeUpdate:renameString];
                    
                    //新建升级后的表结构
                    [self onlyCreateTbaleWihtTableClass:table andDb:db];
                    
                    //导入原表数据
                    NSString *toString = [NSString stringWithFormat:@"insert into %@(",NSStringFromClass([table class])];
                    for (NSString *key in beforeArr) {
                        toString = [NSString stringWithFormat:@"%@%@,",toString,key];
                    }
                    toString = [toString substringToIndex:toString.length - 1];
                    toString = [NSString stringWithFormat:@"%@) select ",toString];
                    for (NSString *key in beforeArr) {
                        toString = [NSString stringWithFormat:@"%@%@,",toString,key];
                    }
                    toString = [toString substringToIndex:toString.length - 1];
                    toString = [NSString stringWithFormat:@"%@ FROM tempT1",toString];
                    NSLog(@"%@",toString);
                    isSuccess = [db executeUpdate:toString];
                }
                @catch (NSException *exception){
                    isSuccess = false;
                }
            }
        }
        [db close];
    }
    //删除tempT1表
    //删除tempT1临时表
    NSString *dropTableStr1 = @"drop table tempT1";
    isSuccess = [self execSqlite:dropTableStr1];
    
    //更新数据表
    NSString *update = [NSString stringWithFormat:@"UPDATE DataBaseTable SET version = '%ld' WHERE tableName = '%@'",version,NSStringFromClass([table class])];
    isSuccess = [self execSqlite:update];
    return isSuccess;
}

/*
 * 查询表里所以数据
 * @param table 表
 * select * from table
 */
+ (NSArray *)getDataWithAllTable:(SqliteTbale *)table{
    return [self getDataWithTable:table andKeys:@[]];
}

/*
 * 查询表
 * @param table 表
 * @param keys 查询那一条数据数组[@"name",@"age"]
 *             where name = %@ and age = %d
 */
+ (NSArray *)getDataWithTable:(SqliteTbale *)table andKeys:(NSArray *)keys{
    ///拼接查询语句
    NSString *execStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE ",NSStringFromClass([table class])];
    NSDictionary *dic = [table allFieldType];
    for (NSString *key in keys) {
        execStr = [self updateWhereProperty:dic andKey:key andExecStr:execStr andTable:table];
    }
    if (keys.count) {
        execStr = [execStr substringToIndex:execStr.length - 5];
    }else{
        execStr = [execStr substringToIndex:execStr.length - 6];
    }
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASEPATH];
    NSMutableArray *array = @[].mutableCopy;
    if ([db open]) {
        FMResultSet *set = [db executeQuery:execStr];
        while ([set next]) {
            //根据字符串创建一个类
            Class C = NSClassFromString(NSStringFromClass([table class]));
            id model = [[C alloc] init];
            NSArray *allKey = [dic allKeys];
            //给属性赋值，用kvc
            for (NSString *key in allKey) {
                NSString *value = dic[key];
                if ([value isEqualToString:@"text"]) {
                    id aa = [set objectForColumn:key];
                    if ([aa isEqual:[NSNull null]]) {
                        [model setValue:@"" forKey:key];
                    }else if ([aa isKindOfClass:[NSNull class]]){
                        [model setValue:@"" forKey:key];
                    }else{
                        [model setValue:[set objectForColumn:key] forKey:key];
                    }
                }else if ([value isEqualToString:@"integer"]){
                    id aa = [set objectForColumn:key];
                    if ([aa isEqual:[NSNull null]]) {
                        [model setValue:@(0) forKey:key];
                    }else if ([aa isKindOfClass:[NSNull class]]){
                        [model setValue:@(0) forKey:key];
                    }else{
                        [model setValue:[NSNumber numberWithInt:[set intForColumn:key]] forKey:key];
                    }
                }else if ([value isEqualToString:@"BLOB"]){
                    id aa = [set objectForColumn:key];
                    NSData *data = [[NSData alloc] init];
                    if ([aa isEqual:[NSNull null]]) {
                        [model setValue:data forKey:key];
                    }else if ([aa isKindOfClass:[NSNull class]]){
                        [model setValue:data forKey:key];
                    }else{
                        data = (NSData *)[set objectForColumn:key];
                        [model setValue:data forKey:key];
                    }
                }else if ([value isEqualToString:@"REAL"]){
                    id aa = [set objectForColumn:key];
                    if ([aa isEqual:[NSNull null]]) {
                        [model setValue:@(0.0) forKey:key];
                    }else if ([aa isKindOfClass:[NSNull class]]){
                        [model setValue:@(0.0) forKey:key];
                    }else{
                        [model setValue:[NSNumber numberWithDouble:[set doubleForColumn:key]] forKey:key];
                    }
                }
            }
            [array addObject:model];
        }
        [db close];
    }
    return array;
}

/*
 * 删除表里的数据
 * @param table 表
 * @param keys 删除那一条数据数组[@"name",@"age"]
 * delete from table Where name = %@ and age = %d
 */
+ (BOOL)deleteDataWithAllTable:(SqliteTbale *)table andKeys:(NSArray *)keys{
    NSString *delete = [NSString stringWithFormat:@"DELETE FROM %@ WHERE ",NSStringFromClass([table class])];
    NSDictionary *dic = [table allFieldType];
    for (NSString *key in keys) {
        delete = [self updateWhereProperty:dic andKey:key andExecStr:delete andTable:table];
    }
    if ([keys count]) {
        delete = [delete substringToIndex:delete.length - 5];
    }else{
        delete = [delete substringToIndex:delete.length - 6];
    }
    return [self execSqlite:delete];
}

/*
 * 清空一张表的数据
 * @param table 表
 * delete from table
 */
+ (BOOL)cleanTableWithTable:(SqliteTbale *)table{
    return [self deleteDataWithAllTable:table andKeys:@[]];
}

/**
 * 执行数据库语句
 */
+ (BOOL)execSqlite:(NSString *)execStr{
    BOOL isSuccess = 0x00;
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASEPATH];
    if ([db open]) {
        isSuccess = [db executeStatements:execStr];
        [db close];
    }
    return isSuccess;
}

///更新语句拼接where后面的
+ (NSString *)updateWhereProperty:(NSDictionary *)dic andKey: (NSString *)key andExecStr: (NSString *)execStr andTable:(SqliteTbale *)table{
    NSString *value = dic[key];
    if ([value isEqualToString:@"text"]) {
        return [NSString stringWithFormat:@"%@%@ = '%@' AND ",execStr,key,[table valueForKey:key]];
    }else if ([value isEqualToString:@"integer"]){
        return [NSString stringWithFormat:@"%@%@ = '%ld' AND ",execStr,key,(long)[[table valueForKey:key] integerValue]];
    }else if ([value isEqualToString:@"BLOB"]){
        return [NSString stringWithFormat:@"%@%@ = '%@' AND ",execStr,key,[table valueForKey:key]];
    }else if ([value isEqualToString:@"REAL"]){
        return [NSString stringWithFormat:@"%@%@ = '%f' AND ",execStr,key,[[table valueForKey:key] doubleValue]];
    }
    return execStr;
}
///更新语句拼接Set
+ (NSString *)updateSetProperty:(NSDictionary *)dic andKey: (NSString *)key andExecStr: (NSString *)execStr andTable:(SqliteTbale *)table{
    NSString *value = dic[key];
    if ([value isEqualToString:@"text"]) {
        return [NSString stringWithFormat:@"%@%@ = '%@',",execStr,key,[table valueForKey:key]];
    }else if ([value isEqualToString:@"integer"]){
        return [NSString stringWithFormat:@"%@%@ = '%ld',",execStr,key,(long)[[table valueForKey:key] integerValue]];
    }else if ([value isEqualToString:@"BLOB"]){
        return [NSString stringWithFormat:@"%@%@ = '%@',",execStr,key,[table valueForKey:key]];
    }else if ([value isEqualToString:@"REAL"]){
        return [NSString stringWithFormat:@"%@%@ = '%f',",execStr,key,[[table valueForKey:key] doubleValue]];
    }
    return execStr;
}

///获取类的属性
+ (NSArray *)getAllProperties:(id)obj
{
    u_int count;//属性个数
    //使用class_copyPropertyList及property_getName获取类的属性列表及每个属性的名称
    objc_property_t *properties  =class_copyPropertyList([obj class], &count);
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++)
    {
        const char* propertyName =property_getName(properties[i]);
        [propertiesArray addObject: [NSString stringWithUTF8String: propertyName]];
    }
    free(properties);
    return propertiesArray;
}
@end

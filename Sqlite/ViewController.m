//
//  ViewController.m
//  Sqlite
//
//  Created by 未央生 on 2017/11/28.
//  Copyright © 2017年 未央生. All rights reserved.
//

#import "ViewController.h"
#import "Student.h"
#import "SqliteManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    Student *dd = [[Student alloc] init];
    dd.age = 20;
    dd.name = @"lyy";
    dd.adress = @"shanghai";
    dd.height = 1.8;
//    [SqliteManager insertTbale:dd];
//    [SqliteManager upgradeTableWithTable:dd andVersion:2];
    NSArray *arr = [SqliteManager getDataWithTable:dd andKeys:@[]];
    for (Student *st in arr) {
        NSLog(@"name: %@   age: %ld   adree: %@   height: %f",st.name,(long)st.age,st.adress,st.height);
    }
//    [SqliteManager updateTbale:dd andKeys:@[@"name"] andValues:@[@"age"]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

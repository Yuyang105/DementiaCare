//
//  DBManager.h
//  DementiaCare
//
//  Created by 喻 煜阳 on 29/03/2016.
//  Copyright © 2016 Yuyang Yu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBManager : NSObject

@property (nonatomic, strong) NSMutableArray *arrColumnNames;
@property (nonatomic) int affectedRows;
@property (nonatomic) long long lastInsertedRowID;

// Specify database file name
-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename;
// Run SELECT queries and loading data
-(NSArray *)loadDataFromDB:(NSString *)query;
// Executing INSERT, UPDATE and DELETE queries
-(void)executeQuery:(NSString *)query;


@end

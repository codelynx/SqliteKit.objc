//
//  SqliteKitResult.h
//  SqliteKit
//
//  Created by Kaz Yoshikawa on 14/1/11.
//  Copyright (c) 2014 Electricwoods LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@class SqliteKitDatabase;
@class SqliteKitResult;
@class SqliteKitRow;


//
//	SqliteKitResult
//

@interface SqliteKitQuery : NSObject

@property (readonly) sqlite3_stmt *stmt;
@property (readonly) SqliteKitDatabase *database;

- (id)initWithDatabase:(SqliteKitDatabase *)database query:(NSString *)query;
- (void)bind:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
- (SqliteKitResult *)execute;

@end

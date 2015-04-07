//
//  SqliteKitResult.h
//  ZSqlite
//
//  Created by Kaz Yoshikawa on 14/1/14.
//  Copyright (c) 2014 Electricwoods LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@class SqliteKitQuery;


//
//	SqliteKitResult
//

@interface SqliteKitResult : NSEnumerator

@property (readonly) NSDictionary *nextRow;

@property (readonly) NSArray *columns;
@property (readonly) int status;
@property (readonly) int64_t last_insert_rowid;

- (id)initWithQuery:(SqliteKitQuery *)query;
- (NSDictionary *)nextRow;

@end

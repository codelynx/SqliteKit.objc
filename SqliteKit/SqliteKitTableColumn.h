//
//  SqliteKitTableColumn.h
//  ZSqlite
//
//  Created by Kaz Yoshikawa on 14/1/12.
//  Copyright (c) 2014 Electricwoods LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@class SqliteKitTable;
@class SqliteKitRow;


//
//	SqliteKitTableColumn
//

@interface SqliteKitTableColumn : NSObject

- (id)initWithTable:(SqliteKitTable *)table attributes:(NSDictionary *)info;

@property (assign) NSInteger cid;
@property (copy) NSString *name;
@property (copy) NSString *type;
@property (assign) NSInteger notnull;
@property (assign) NSInteger pk;

@end

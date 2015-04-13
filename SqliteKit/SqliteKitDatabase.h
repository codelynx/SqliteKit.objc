//
//  SqliteKitDatabase.h
//  SqliteKit
//
//  Created by Kaz Yoshikawa on 14/1/10.
//  Copyright (c) 2014 Electricwoods LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SqliteKitQuery;
@class SqliteKitResult;


extern NSString *SqliteKitDatabaseDidUpdateNotification;
extern NSString *SqliteKitDatabaseDidUpdateTypeKey;
extern NSString *SqliteKitDatabaseDidUpdateDatabaseKey;
extern NSString *SqliteKitDatabaseDidUpdateTableKey;
extern NSString *SqliteKitDatabaseDidUpdateRowidKey;


//
//	utility functions
//

extern NSString *NSStringFromSqliteResult(int code);
extern void SqliteKitReportError(int status);


//
//	SqliteKitMode
//

extern int SqliteKitOptionReadonly;
extern int SqliteKitOptionReadWrite;
extern int SqliteKitOptionCreate;
typedef int SqliteKitOptions;


//
//	SqliteKitDatabase	
//

@interface SqliteKitDatabase : NSObject

@property (readonly) NSArray *tables;
@property (readonly) BOOL fileExists;
@property (readonly) NSArray *tableNames;
@property (assign) BOOL notificationEnabled;
@property (assign) BOOL foreignKeys;

- (id)initWithPath:(NSString *)path options:(SqliteKitOptions)options;

- (SqliteKitQuery *)queryWithString:(NSString *)string;
- (SqliteKitQuery *)queryWithFormat:(NSString *)format, ...;
- (SqliteKitResult *)executeQueryWithString:(NSString *)string;
- (SqliteKitResult *)executeQueryWithFormat:(NSString *)format, ...;

@end

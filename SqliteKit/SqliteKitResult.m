//
//  SqliteKitResult.m
//  ZSqlite
//
//  Created by Kaz Yoshikawa on 14/1/14.
//  Copyright (c) 2014 Electricwoods LLC. All rights reserved.
//

#import "SqliteKitResult.h"
#import "SqliteKitDatabase.h"
#import "SqliteKitQuery.h"
#import "SqliteKitColumn.h"
#import "SqliteKitRow.h"
@class SqliteKitResult;


//
//	SqliteKitRow ()
//

@interface SqliteKitRow ()

- (id)initWithResult:(SqliteKitResult *)result dictionary:(NSDictionary *)dictionary columns:(NSArray *)columns;

@end


//
//	SqliteKitResult ()
//

@interface SqliteKitResult ()
{
	NSArray *_columns;
	SqliteKitQuery *_query;
	int _status;
}

@end


//
//	SqliteKitResult
//

@implementation SqliteKitResult

- (id)initWithQuery:(SqliteKitQuery *)query
{
	if (self = [super init]) {
		_query = query;
		_status = sqlite3_step(_query.stmt);
		SqliteKitReportError(self.status);
	}
	return self;
}

- (void)dealloc
{
}

- (sqlite3_stmt *)stmt
{
	return _query.stmt;
}

- (int)execute
{
	_status = sqlite3_step(self.stmt);
	SqliteKitReportError(self.status);
	return self.status;
}

- (int64_t)last_insert_rowid
{
	return (int64_t)sqlite3_last_insert_rowid(_query.database.sqlite);
}

- (NSArray *)columns
{
	if (!_columns) {
		NSMutableArray *columns = [NSMutableArray array];
		int numberOfColumns = sqlite3_column_count(self.stmt);
		for (int index = 0 ; index < numberOfColumns ; index++) {
			const char *name = sqlite3_column_name(self.stmt, index);
			int type = sqlite3_column_type(self.stmt, index);
			SqliteKitColumn* column = [[SqliteKitColumn alloc] initWithResult:self name:[NSString stringWithUTF8String:name] type:type];
			[columns addObject:column];
		}
		_columns = columns;
	}
	return _columns;
}

- (SqliteKitRow *)nextRow
{
	// sqlite3_step has been executed

	SqliteKitReportError(self.status);
	if (self.status == SQLITE_ROW) {

		NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
		sqlite3_stmt *stmt = self.stmt;
		int numberOfColumns = sqlite3_column_count(self.stmt);
		for (int index = 0 ; index < numberOfColumns ; index++) {
			const char *name = sqlite3_column_name(self.stmt, index);
			NSString *key = [NSString stringWithUTF8String:name];

			sqlite3_int64 intValue = 0;
			double doubleValue = 0;
			size_t bytes = 0;
			const void *data = nil;
			const char *text = nil;
			switch (sqlite3_column_type(stmt, index)) {

			case SQLITE_INTEGER:
				intValue = sqlite3_column_int64(stmt, index);
				[dictionary setValue:[NSNumber numberWithLongLong:intValue] forKey:key];
				break;

			case SQLITE_FLOAT:
				doubleValue = sqlite3_column_double(stmt, index);
				[dictionary setValue:[NSNumber numberWithDouble:doubleValue] forKey:key];
				break;

			case SQLITE_TEXT:
				text = (const char *)sqlite3_column_text(stmt, index);
				[dictionary setValue:[NSString stringWithUTF8String:text] forKey:key];
				break;

			case SQLITE_BLOB:
				bytes = sqlite3_column_bytes(stmt, index);
				data = sqlite3_column_blob(stmt, index);
				[dictionary setValue:[NSData dataWithBytes:data length:bytes] forKey:key];
				break;

			case SQLITE_NULL:
				// [KY] not sure which way to go
				//[dictionary setValue:[NSNull null] forKey:key];
				[dictionary setValue:nil forKey:key];
				break;

			default:
				NSLog(@"Unexpected column type: %d", sqlite3_column_type(stmt, index));
				break;
			}
		}

		// execute step for the next nextRow
		_status = sqlite3_step(_query.stmt);

		return [[SqliteKitRow alloc] initWithResult:self dictionary:dictionary columns:self.columns];

	}
	return nil;
}

- (id)nextObject
{
	return [self nextRow];
}

- (int)status
{
	return _status;
}

@end

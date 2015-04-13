//
//  SqliteKitResult.m
//  SqliteKit
//
//  Created by Kaz Yoshikawa on 14/1/11.
//  Copyright (c) 2014 Electricwoods LLC. All rights reserved.
//

#import <sqlite3.h>
#import "SqliteKitQuery.h"
#import "SqliteKitDatabase.h"
#import "SqliteKitResult.h"


//
//	SqliteKitDatabase (private)
//

@interface SqliteKitDatabase (private)

@property (readonly) sqlite3 *sqlite;

@end


//
//	SqliteKitResult ()
//

@interface SqliteKitQuery ()
{
	int _result;
	NSString *_query;
	sqlite3_stmt *_stmt;
	SqliteKitDatabase *_database;
}
@end


//
//	SqliteKitResult
//

@implementation SqliteKitQuery


- (id)initWithDatabase:(SqliteKitDatabase *)database query:(NSString *)query
{
	if (self = [super init]) {
		_database = database;
		_query = query;
		const char *command = [query UTF8String];
		const char *tail = NULL;
		sqlite3_stmt *stmt = NULL;
		_result = sqlite3_prepare_v2(database.sqlite, command, -1, &stmt, &tail);
		SqliteKitReportError(_result);
		_stmt = stmt;
	}
	return self;
}

- (void)dealloc
{
	if (_stmt) {
		sqlite3_finalize(_stmt), _stmt = nil;
	}
}

- (void)bind:(id)firstObject, ...
{
	//	bind: injects values into '?' for sqlite prepared statement
	//
	//	SqliteKitQuery *query = [database queryWithFormat:@"INSERT INTO product (name, title) VALUES(?, ?)"];
	//	for (...) {
	//		NSString *name = ...
	//		NSString *title = ...
	//		[query bind: name, title];
	//		[query execute];
	//	}


	va_list args;
	va_start(args, firstObject);

	sqlite3_reset(_stmt);
	sqlite3_clear_bindings(_stmt);

	int index = 1;

	id arg = firstObject;
	while (arg) {
		if ([arg isKindOfClass:[NSString class]]) {
			NSString *string = (NSString *)arg;
			const char *text = [string UTF8String];
			sqlite3_bind_text(_stmt, index, text, -1, NULL);
		}
		else if ([arg isKindOfClass:[NSNumber class]]) {
			NSParameterAssert(![arg isKindOfClass:[NSDecimalNumber class]]);
			NSNumber *number = (NSNumber *)arg;
			if (CFNumberIsFloatType((CFNumberRef)number)) {
				sqlite3_bind_double(_stmt, index, [number doubleValue]);
			}
			else {
				sqlite3_bind_int64(_stmt, index, (sqlite3_int64)[number longLongValue]);
			}
		}
		else if ([arg isKindOfClass:[NSData class]]) {
			NSData *data = (NSData *)arg;
			sqlite3_bind_blob(_stmt, index, data.bytes, (int)data.length, NULL);
		}
		index++;
		arg = va_arg(args, id);
	}

	va_end(args);
}

- (SqliteKitResult *)execute
{
	SqliteKitResult *result = [[SqliteKitResult alloc] initWithQuery:self];
	return result;
}

@end

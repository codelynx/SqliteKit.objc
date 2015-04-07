//
//  SqliteKitDatabase.m
//  ZSqlite
//
//  Created by Kaz Yoshikawa on 14/1/10.
//  Copyright (c) 2014 Electricwoods LLC. All rights reserved.
//

#import "SqliteKitDatabase.h"
#import "SqliteKitQuery.h"
#import "SqliteKitTable.h"
#import "SqliteKitResult.h"

//
//	SqliteKitDatabaseDidUpdate
//

NSString *SqliteKitDatabaseDidUpdateNotification = @"SqliteKitDatabaseDidUpdateNotification";
NSString *SqliteKitDatabaseDidUpdateTypeKey = @"type";
NSString *SqliteKitDatabaseDidUpdateDatabaseKey = @"database";
NSString *SqliteKitDatabaseDidUpdateTableKey = @"table";
NSString *SqliteKitDatabaseDidUpdateRowidKey = @"rowid";


//
//	SqliteKitOption
//

int SqliteKitOptionReadonly = SQLITE_OPEN_READONLY;
int SqliteKitOptionReadWrite = SQLITE_OPEN_READWRITE;
int SqliteKitOptionCreate = SQLITE_OPEN_CREATE;

//
//	NSStringFromSqliteResult
//

#define CASE_RETURN_AS_STRING(c) case c: return @#c

NSString *NSStringFromSqliteResult(int code)
{
	switch (code) {
	CASE_RETURN_AS_STRING(SQLITE_OK);
	CASE_RETURN_AS_STRING(SQLITE_ERROR);
	CASE_RETURN_AS_STRING(SQLITE_INTERNAL);
	CASE_RETURN_AS_STRING(SQLITE_PERM);
	CASE_RETURN_AS_STRING(SQLITE_ABORT);
	CASE_RETURN_AS_STRING(SQLITE_BUSY);
	CASE_RETURN_AS_STRING(SQLITE_LOCKED);
	CASE_RETURN_AS_STRING(SQLITE_NOMEM);
	CASE_RETURN_AS_STRING(SQLITE_READONLY);
	CASE_RETURN_AS_STRING(SQLITE_INTERRUPT);
	CASE_RETURN_AS_STRING(SQLITE_IOERR);
	CASE_RETURN_AS_STRING(SQLITE_CORRUPT);
	CASE_RETURN_AS_STRING(SQLITE_NOTFOUND);
	CASE_RETURN_AS_STRING(SQLITE_FULL);
	CASE_RETURN_AS_STRING(SQLITE_CANTOPEN);
	CASE_RETURN_AS_STRING(SQLITE_PROTOCOL);
	CASE_RETURN_AS_STRING(SQLITE_EMPTY);
	CASE_RETURN_AS_STRING(SQLITE_SCHEMA);
	CASE_RETURN_AS_STRING(SQLITE_TOOBIG);
	CASE_RETURN_AS_STRING(SQLITE_CONSTRAINT);
	CASE_RETURN_AS_STRING(SQLITE_MISMATCH);
	CASE_RETURN_AS_STRING(SQLITE_MISUSE);
	CASE_RETURN_AS_STRING(SQLITE_NOLFS);
	CASE_RETURN_AS_STRING(SQLITE_AUTH);
	CASE_RETURN_AS_STRING(SQLITE_FORMAT);
	CASE_RETURN_AS_STRING(SQLITE_RANGE);
	CASE_RETURN_AS_STRING(SQLITE_NOTADB);
	CASE_RETURN_AS_STRING(SQLITE_ROW);
	CASE_RETURN_AS_STRING(SQLITE_DONE);
	}
	return @"Sqlite unknown error";
}


//
//	Report sqlite error
//

void SqliteKitReportError(int status)
{
	switch (status) {
	case SQLITE_OK:
	case SQLITE_ROW:
	case SQLITE_DONE:
		break;
	default:
		NSLog(@"sqlite: %@", NSStringFromSqliteResult(status));
	}
}

static void update_hook_callback(void *arg, int type, const char *database, const char *table, sqlite3_int64 rowid);




//
//	SqliteKitDatabase ()
//

@interface SqliteKitDatabase ()
{
	NSString *_path;
	sqlite3 *_sqlite;
	SqliteKitOptions _options;
	NSArray *_tableNames;
	NSMapTable *_tableMap;
}
@property (readonly) NSMapTable *tableMap;

- (void)databaseDidUpdateWithType:(int)type database:(NSString *)database table:(NSString *)table rowid:(int64_t)rowid;

@end


//
//	SqliteKitDatabase
//

@implementation SqliteKitDatabase

- (void)setup
{
	sqlite3_update_hook(self.sqlite, update_hook_callback, (__bridge void *)(self));
	self.foreignKeys = YES;
}

- (id)initWithPath:(NSString *)path options:(SqliteKitOptions)options
{
	sqlite3 *sqlite = NULL;
	int status = sqlite3_open_v2([path fileSystemRepresentation], &sqlite, options, NULL);
	SqliteKitReportError(status);
	if (status == SQLITE_OK) {
		if (self = [super init]) {
			_path = path;
			_sqlite = sqlite;
			_options = options;
			[self setup];
		}
		return self;
	}
	return nil;
}

- (void)dealloc
{
	if (_sqlite) {
		sqlite3_update_hook(self.sqlite, NULL, NULL);
		int result = sqlite3_close(self.sqlite);
		SqliteKitReportError(result);
		_sqlite = nil;
	}
}

- (BOOL)fileExists
{
	return [[NSFileManager defaultManager] fileExistsAtPath:_path];
}

- (NSMapTable *)tableMap
{
	if (!_tableMap) {
		_tableMap = [NSMapTable strongToWeakObjectsMapTable];
	}
	return _tableMap;
}

- (SqliteKitQuery *)queryWithString:(NSString *)string
{
	return [[SqliteKitQuery alloc] initWithDatabase:self query:string];
}

- (SqliteKitQuery *)queryWithFormat:(NSString *)format, ...
{
	va_list args;
	va_start(args, format);

	NSString *string = [[NSString alloc] initWithFormat:format arguments:args];
	SqliteKitQuery *query = [[SqliteKitQuery alloc] initWithDatabase:self query:string];

	va_end(args);
	return query;
}

- (SqliteKitResult *)executeQueryWithString:(NSString *)string
{
	return [[self queryWithString:string] execute];
}

- (SqliteKitResult *)executeQueryWithFormat:(NSString *)format, ...
{
	va_list args;
	va_start(args, format);
	NSString *string = [NSString stringWithFormat:format, args];
	va_end(args);
	return [self executeQueryWithString:string];
}

- (NSArray *)tableNames
{
	// TODO: how to update _tableNames upon changes [KY]

	if (!_tableNames) {
		NSMutableArray *tables = [NSMutableArray array];
		SqliteKitResult *query = [[self queryWithFormat:@"SELECT name FROM sqlite_master WHERE type = \"table\";"] execute];
		NSDictionary *row = nil;
		while ((row = query.nextRow)) {
			NSString *name = [row valueForKey:@"name"];
			if (name.length > 0) {
				[tables addObject:name];
			}
		}
		_tableNames = tables;
	}
	return _tableNames;
}

- (SqliteKitTable *)tableWithName:(NSString *)name
{
	SqliteKitTable *table = [self.tableMap objectForKey:name];
	if (!table) {
		if ([self.tableNames containsObject:name]) {
			table = [[SqliteKitTable alloc] initWithName:name database:self];
			[self.tableMap setObject:table forKey:name];
		}
	}
	return table;
}

- (NSArray *)tables
{
	_tableNames = nil; // forth reload

	NSMutableArray *tables = [NSMutableArray array];
	for (NSString *name in self.tableNames) {
		SqliteKitTable *table = [self tableWithName:name];
		[tables addObject:table];
	}
	return tables;
}

#pragma mark -

- (BOOL)foreignKeys
{
	SqliteKitResult *result = [[self queryWithFormat:@"PRAGMA foreign_keys;"] execute];
	NSDictionary *row = [result nextRow];
	return [[row valueForKey:@"foreign_keys"] boolValue];
}

- (void)setForeignKeys:(BOOL)foreignKeys
{
	NSString *state = foreignKeys ? @"ON" : @"OFF";
	SqliteKitResult *result = [[self queryWithFormat:@"PRAGMA foreign_keys = %@;", state] execute];
	SqliteKitReportError(result.status);
	NSLog(@"foreignKeys: %@", state);
}

#pragma mark -

- (void)databaseDidUpdateWithType:(int)type database:(NSString *)database table:(NSString *)table rowid:(int64_t)rowid
{
	if (self.notificationEnabled) {
		NSDictionary *userInfo = @{
			SqliteKitDatabaseDidUpdateTypeKey: [NSNumber numberWithInt:type],			// SQLITE_INSERT
			SqliteKitDatabaseDidUpdateDatabaseKey: database,							// "main"
			SqliteKitDatabaseDidUpdateTableKey: table,
			SqliteKitDatabaseDidUpdateRowidKey: [NSNumber numberWithLongLong:rowid]
		};
		[[NSNotificationCenter defaultCenter] postNotificationName:SqliteKitDatabaseDidUpdateNotification object:self userInfo:userInfo];
	}
}

static void update_hook_callback(void *arg, int type, const char *database, const char *table, sqlite3_int64 rowid)
{
	SqliteKitDatabase *object = (__bridge SqliteKitDatabase *)arg;
	if ([object isKindOfClass:[SqliteKitDatabase class]]) {
		NSString *databaseName = [NSString stringWithUTF8String:database];
		NSString *tableName = [NSString stringWithUTF8String:table];
		[object databaseDidUpdateWithType:type database:databaseName table:tableName rowid:rowid];
	}
}

@end




//
//  SqliteKitTable.m
//  ZSqlite
//
//  Created by Kaz Yoshikawa on 14/1/12.
//  Copyright (c) 2014 Electricwoods LLC. All rights reserved.
//

#import "SqliteKitTable.h"
#import "SqliteKitDatabase.h"
#import "SqliteKitQuery.h"
#import "SqliteKitResult.h"
#import "SqliteKitTableColumn.h"


//
//	SqliteKitTable ()
//

@interface SqliteKitTable ()
{
	NSArray *_columns;
}
@property (strong) SqliteKitDatabase *database;
@property (strong) NSString *name;

@end


//
//	SqliteKitTable
//

@implementation SqliteKitTable

- (id)initWithName:(NSString *)name database:(SqliteKitDatabase *)database
{
	if (self = [super init]) {
		self.name = name;
		self.database = database;
	}
	return self;
}

- (NSArray *)columns
{
	if (!_columns) {
		NSMutableArray *columns = [NSMutableArray array];
		SqliteKitResult *result = [[self.database queryWithFormat:@"pragma table_info('%@');", self.name] execute];
		NSDictionary *row = nil;
		while ((row = [result nextRow])) {
			NSString *name = [row valueForKey:@"name"];
			NSParameterAssert(name.length > 0);
			SqliteKitTableColumn *column = [[SqliteKitTableColumn alloc] initWithTable:self attributes:row];
			[columns addObject:column];
		}
		_columns = columns;
	}
	return _columns;
}

//- (NSEnumerator *)rowEnumerator
//{
//	SqliteKitResult *result = [[self.database queryWithFormat:@"SELECT * from %@", self.name] execute];
//	return [result rowEnumerator];
//}

@end

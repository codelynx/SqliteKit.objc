//
//  SqliteKitRow.m
//  SqliteKit
//
//  Created by Kaz Yoshikawa on 2015/04/07.
//  Copyright (c) 2015年 Electricwoods LLC. All rights reserved.
//

#import "SqliteKitRow.h"
#import "SqliteKitColumn.h"
@class SqliteKitResult;


//
//	SqliteKitRow ()
//

@interface SqliteKitRow ()
{
	SqliteKitResult *_result;
	NSDictionary *_dictionary;
	NSArray *_columns;
}
@end



//
//	SqliteKitRow
//

@implementation SqliteKitRow

- (id)initWithResult:(SqliteKitResult *)result dictionary:(NSDictionary *)dictionary columns:(NSArray *)columns
{
	if (self = [super init]) {
		_result = result;
		_dictionary = dictionary;
		_columns = columns;
	}
	return self;
}

- (NSDictionary *)dictionary
{
	return _dictionary;
}

- (id)objectForKeyedSubscript:(id <NSCopying>)key;
{
	return _dictionary[key];
}

- (id)objectAtIndexedSubscript:(NSUInteger)index
{
	if (index < _columns.count) {
		SqliteKitColumn *column = _columns[index];
		NSParameterAssert([column isKindOfClass:[SqliteKitColumn class]]);
		return _dictionary[column.name];
	}
	return nil;
}

@end

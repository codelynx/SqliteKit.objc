//
//  SqliteKitColumn.m
//  SqliteKit
//
//  Created by Kaz Yoshikawa on 2015/04/07.
//  Copyright (c) 2015年 Electricwoods LLC. All rights reserved.
//

#import "SqliteKitColumn.h"
#import "SqliteKitResult.h"


//
//	SqliteKitColumn ()
//

@interface SqliteKitColumn ()
{
	NSString *_name;
	int _type;
}
@end


//
//	SqliteKitColumn
//

@implementation SqliteKitColumn

- (id)initWithResult:(SqliteKitResult *)result name:(NSString *)name type:(int)type;
{
	if (self = [super init]) {
		_name = name;
		_type = type;
	}
	return self;
}

- (NSString *)name
{
	return _name;
}

- (int)type
{
	return _type;
}

//SQLITE_INTEGER

@end

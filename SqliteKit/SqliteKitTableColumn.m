//
//  SqliteKitTableColumn.m
//  SqliteKit
//
//  Created by Kaz Yoshikawa on 14/1/12.
//  Copyright (c) 2014 Electricwoods LLC. All rights reserved.
//

#import "SqliteKitTableColumn.h"
#import "SqliteKitTable.h"


//
//	SqliteKitTableColumn ()
//

@interface SqliteKitTableColumn ()

@property (weak) SqliteKitTable *table;

@end


//
//	SqliteKitTableColumn
//

@implementation SqliteKitTableColumn

- (id)initWithTable:(SqliteKitTable *)table attributes:(NSDictionary *)attributes
{
	if (self = [super init]) {
		self.table = table;
		self.cid = [[attributes valueForKey:@"cid"] integerValue];
		self.name = [attributes valueForKey:@"name"];
		self.type = [attributes valueForKey:@"type"];
		self.notnull = [[attributes valueForKey:@"notnull"] integerValue];
		self.pk = [[attributes valueForKey:@"pk"] integerValue];
	}
	return self;
}

@end

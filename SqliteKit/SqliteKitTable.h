//
//  SqliteKitTable.h
//  SqliteKit
//
//  Created by Kaz Yoshikawa on 14/1/12.
//  Copyright (c) 2014 Electricwoods LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SqliteKitDatabase;


//
//	SqliteKitTable
//

@interface SqliteKitTable : NSObject

@property (readonly) NSArray *columns;
@property (readonly) NSEnumerator *rowEnumerator;

- (id)initWithName:(NSString *)name database:(SqliteKitDatabase *)database;

@end

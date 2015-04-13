//
//  SqliteKitTests.m
//  SqliteKitTests
//
//  Created by Kaz Yoshikawa on 2015/04/07.
//  Copyright (c) 2015年 Electricwoods LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import <sqlite3.h>
#import "SqliteKit.h"

@interface SqliteKitTests : XCTestCase
{
	SqliteKitDatabase *_database;
	NSString *_path;
}


@end

@implementation SqliteKitTests

- (NSString *)path {
	if (!_path) {
		NSString *filename = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:@"sqlite"];
		_path = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
	}
	return _path;
}

- (void)setUp {
    [super setUp];

	_database = [[SqliteKitDatabase alloc] initWithPath:self.path options:SqliteKitOptionReadWrite | SqliteKitOptionCreate];

}

- (void)tearDown {
	_database = nil;

    [super tearDown];
}

- (void)testBasic1 {

	[_database executeQueryWithString:@"CREATE TABLE IF NOT EXISTS product_table (id INTEGER AUTO INCREMENT, name VARCHAR(32), price DOUBLE);"];
	[_database executeQueryWithString:@"INSERT INTO product_table('name', 'price') VALUES('Apple', '100')"];
	SqliteKitResult *result1 = [_database executeQueryWithString:@"SELECT * FROM product_table"];

	int64_t rowid = result1.last_insert_rowid;

	NSInteger count = 0;
	for (SqliteKitRow *row in result1) {
		NSDictionary *dictionary = row.dictionary;
		NSString *name = dictionary[@"name"];
		NSNumber *price = dictionary[@"price"];
		XCTAssertEqualObjects(name, @"Apple");
		XCTAssertEqualObjects(price, @100.0);
		count++;
	}
	XCTAssert(count == 1);

	SqliteKitResult *result2 = [_database executeQueryWithFormat:@"SELECT * FROM product_table WHERE id='%d'", (int)rowid];
	for (SqliteKitRow *row in result2) {
		NSDictionary *dictionary = row.dictionary;
		XCTAssertEqualObjects(dictionary[@"name"], @"Apple");
		XCTAssertEqualObjects(dictionary[@"price"], @100.0);
	}
}

/*
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}
*/

@end

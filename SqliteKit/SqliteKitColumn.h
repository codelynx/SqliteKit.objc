//
//  SqliteKitColumn.h
//  SqliteKit
//
//  Created by Kaz Yoshikawa on 2015/04/07.
//  Copyright (c) 2015年 Electricwoods LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SqliteKitResult;


//
//	SqliteKitColumn
//

@interface SqliteKitColumn : NSObject

@property (readonly) NSString *name;
@property (readonly) int type;

- (id)initWithResult:(SqliteKitResult *)result name:(NSString *)name type:(int)type;

@end

//
//  SqliteKitRow.h
//  SqliteKit
//
//  Created by Kaz Yoshikawa on 2015/04/07.
//  Copyright (c) 2015年 Electricwoods LLC. All rights reserved.
//

#import <Foundation/Foundation.h>



//
//	SqliteKitRow
//

@interface SqliteKitRow : NSObject

@property (readonly) NSDictionary *dictionary;

- (id)objectForKeyedSubscript:(id <NSCopying>)key;
- (id)objectAtIndexedSubscript:(NSUInteger)index;

@end

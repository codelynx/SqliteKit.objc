# SqliteKit

SqliteKit is a piece of code for accessing Sqlite database from Cocoa.

Written by Kaz Yoshikawa.
Based on 

- Version 0.1

## Status
- Under Development

Some features are functioning but not ready too use.

## Code Usage


```Objective-C

	// CREATE A DATABASE
	NSString *path = ....
	SqliteKitDatabase *database;
	database = [[SqliteKitDatabase alloc] initWithPath:path options:SqliteKitOptionReadWrite | SqliteKitOptionCreate];
	
	// CREATE A TABLE
	[_database executeQueryWithString:@"CREATE TABLE IF NOT EXISTS product_table "
					@"(id INTEGER AUTO INCREMENT, name VARCHAR(32), price DOUBLE);"];
	
	// INSERT A ROW
	[_database executeQueryWithString:@"INSERT INTO product_table('name', 'price') VALUES('Apple', '100');"];

	// FETCH SELECTED ROWS
	SqliteKitResult *result = [database executeQueryWithString:@"SELECT * FROM product_table;"];
	for (SqliteKitRow *row in result) {
		NSDictionary *dictionary = row.dictionary;
		NSString *name = dictionary[@"name"];
		NSNumber *price = dictionary[@"price"];
	}
```

### SqliteKitDatabase

SqliteKitDatabase represents My SQL database connection.  It has to configure to connect My SQL database and invoke 'connect' method to establish a connection to the database.  

```
- (SqliteKitQuery *)queryWithString:(NSString *)string;
- (SqliteKitQuery *)queryWithFormat:(NSString *)format, ...;
```
These two mothods are to create query object from given SQL string. The created query will not get executed until its 'execute' method is explicitly called.  Created query objects can be kept and reused sometime later.

```
- (SqliteKitResult *)executeQueryWithString:(NSString *)string;
- (SqliteKitResult *)executeQueryWithString:(NSString *)string;
```
These two methods are to create and to execute query object from given string.  It returens 'SqliteKitResult' object and query objects cannot be reused.

### SqliteKitQuery

```
- (SqliteKitResult *)execute;
```
By invoking 'execute' to execute query against the database.  


### SqliteKitResult

```
- (SqliteKitRow *)nextRow;
```

SqliteKitResult represents a result of querying database.  Since it's a subclass of NSEnumerator, you may enumerate rows by following code.

```
	SqliteKitResult *result = ... // select * from table
	for (SqliteKitRow *row in result) {
		NSDictionary *dictionary = row.dictionary;
		NSLog(@"row: %@", dictionary);
	}
```

### SqliteKitRow
SqliteKitRow provides a row in the form of dictionary.

```
@property (readonly) NSDictionary *dictionary;
```

SqliteKitRow provides 'objectForKeyedSubscript:' and 'objectAtIndexedSubscript:' interface, you may access column value by following code.

```
	SqliteKitRow *row = ...
	NSString *name = row[@"name"];
```

```
	SqliteKitRow *row = ...
	NSString *name = row[0];
```

## TO DO LIST
- More Test
- Better BLOB support
- More data type support

## License
The MIT License (MIT)

Copyright (c) 2015 Electricwoods LLC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.


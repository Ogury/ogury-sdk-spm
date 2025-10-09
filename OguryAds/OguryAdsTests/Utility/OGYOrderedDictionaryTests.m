//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAOrderedDictionaryTestHelper.h"
#import <OCMock/OCMock.h>

@interface MutableOrderedDictionaryTests : XCTestCase

@end

@implementation MutableOrderedDictionaryTests

- (void)testWhenSubscriptingThenKeysAreOrderedAsExpected {
    OGAMutableOrderedDictionary *dict = [OGAMutableOrderedDictionary new];
    dict[@"1"] = @1;
    dict[@"2"] = @2;
    XCTAssertTrue([OGAOrderedDictionaryTestHelper testDictionary:dict against:@"{\"1\":1,\"2\":2}"]);
}

- (void)testWhenSettingValuesThenKeysAreOrderedAsExpected {
    OGAMutableOrderedDictionary *dict = [OGAMutableOrderedDictionary new];
    [dict setValue:@1 forKey:@"1"];
    [dict setValue:@2 forKey:@"2"];
    XCTAssertTrue([OGAOrderedDictionaryTestHelper testDictionary:dict against:@"{\"1\":1,\"2\":2}"]);
}

- (void)testWhenSettingObjectsThenKeysAreOrderedAsExpected {
    OGAMutableOrderedDictionary *dict = [OGAMutableOrderedDictionary new];
    [dict setObject:@1 forKey:@"1"];
    [dict setObject:@2 forKey:@"2"];
    XCTAssertTrue([OGAOrderedDictionaryTestHelper testDictionary:dict against:@"{\"1\":1,\"2\":2}"]);
}

- (void)testWhenInitWithObjectForKeysThenKeysAreOrderedAsExpected {
    OGAMutableOrderedDictionary *dict = [[OGAMutableOrderedDictionary alloc] initWithObjects:@[ @1, @2 ] forKeys:@[ @"2", @"1" ]];
    XCTAssertTrue([OGAOrderedDictionaryTestHelper testDictionary:dict against:@"{\"2\":1,\"1\":2}"]);
}

- (void)testWhenReversingKeysOrderThenKeysAreOrderedAsExpected {
    OGAMutableOrderedDictionary *dict = [OGAMutableOrderedDictionary new];
    dict[@"2"] = @2;
    dict[@"1"] = @1;
    XCTAssertTrue([OGAOrderedDictionaryTestHelper testDictionary:dict against:@"{\"2\":2,\"1\":1}"]);
}

- (void)testWhenDeletingEntryThenKeysAreOrderedAsExpected {
    OGAMutableOrderedDictionary *dict = [OGAMutableOrderedDictionary new];
    dict[@"1"] = @1;
    dict[@"2"] = @2;
    dict[@"3"] = @3;
    [dict removeObjectForKey:@"3"];
    XCTAssertTrue([OGAOrderedDictionaryTestHelper testDictionary:dict against:@"{\"1\":1,\"2\":2}"]);
}

- (void)testWhenDeletingAndAddingThenKeysAreOrderedAsExpected {
    OGAMutableOrderedDictionary *dict = [OGAMutableOrderedDictionary new];
    dict[@"1"] = @1;
    dict[@"2"] = @2;
    dict[@"3"] = @3;
    [dict removeObjectForKey:@"3"];
    dict[@"test"] = @"test";
    dict[@"3"] = @3;
    [dict removeObjectForKey:@"2"];
    XCTAssertTrue([OGAOrderedDictionaryTestHelper testDictionary:dict against:@"{\"1\":1,\"test\":\"test\",\"3\":3}"]);
}

- (void)testWhenDeletingAddingAndUpdatingThenKeysAreOrderedAsExpected {
    OGAMutableOrderedDictionary *dict = [OGAMutableOrderedDictionary new];
    dict[@"1"] = @1;
    dict[@"2"] = @2;
    dict[@"3"] = @3;
    [dict removeObjectForKey:@"3"];
    dict[@"test"] = @"test";
    dict[@"3"] = @3;
    dict[@"1"] = @10;
    XCTAssertTrue([OGAOrderedDictionaryTestHelper testDictionary:dict against:@"{\"1\":10,\"2\":2,\"test\":\"test\",\"3\":3}"]);
}

- (void)testWhenUsingNestedOrdererDictionaryThenKeysAreOrderedAsExpected {
    OGAMutableOrderedDictionary *dict = [OGAMutableOrderedDictionary new];
    dict[@"1"] = @1;
    dict[@"2"] = @2;
    OGAMutableOrderedDictionary *nestedDict = [OGAMutableOrderedDictionary new];
    nestedDict[@"test"] = @"test";
    nestedDict[@"newLine"] = @"newLine";
    dict[@"nested"] = nestedDict;
    dict[@"3"] = @3;
    XCTAssertTrue([OGAOrderedDictionaryTestHelper testDictionary:dict against:@"{\"1\":1,\"2\":2,\"nested\":{\"test\":\"test\",\"newLine\":\"newLine\"},\"3\":3}"]);
}

- (void)testWhenUsingGetterThenExpectedObjectsAreReturned {
    OGAMutableOrderedDictionary *dict = [OGAMutableOrderedDictionary new];
    dict[@"1"] = @1;
    dict[@"2"] = @2;
    XCTAssertEqualObjects(dict[@"1"], @1);
    XCTAssertEqualObjects(dict[@"2"], @2);
}

- (void)testWhenUsingSetValuesAndGetterThenExpectedObjectsAreReturned {
    OGAMutableOrderedDictionary *dict = [OGAMutableOrderedDictionary new];
    dict[@"1"] = @1;
    dict[@"2"] = @2;
    XCTAssertEqualObjects([dict valueForKey:@"1"], @1);
    XCTAssertEqualObjects([dict valueForKey:@"2"], @2);
}

- (void)testWhenUsingSubscriptingAndGetterThenExpectedObjectsAreReturned {
    OGAMutableOrderedDictionary *dict = [OGAMutableOrderedDictionary new];
    dict[@"1"] = @1;
    dict[@"2"] = @2;
    XCTAssertEqualObjects([dict objectForKey:@"1"], @1);
    XCTAssertEqualObjects([dict objectForKey:@"2"], @2);
}

- (void)testWhenAllEntriesAreRemovedThenDictionaryIsEmpty {
    OGAMutableOrderedDictionary *dict = [OGAMutableOrderedDictionary new];
    dict[@"1"] = @1;
    dict[@"2"] = @2;
    [dict removeAllObjects];
    XCTAssertEqual(dict.count, 0);
}

- (void)testWhenRemovingAnEntryThenDictionaryRemainsSorted {
    OGAMutableOrderedDictionary *dict = [OGAMutableOrderedDictionary new];
    dict[@"1"] = @1;
    dict[@"2"] = @2;
    dict[@"3"] = @3;
    [dict removeObjectForKey:@"3"];
    XCTAssertEqual(dict.count, 2);
    XCTAssertEqualObjects([dict objectForKey:@"1"], @1);
    XCTAssertEqualObjects([dict objectForKey:@"2"], @2);
    XCTAssertNil(dict[@"3"]);
}

- (void)testWhenRemovingSeveralEntriesThenDictionaryRemainsSorted {
    OGAMutableOrderedDictionary *dict = [OGAMutableOrderedDictionary new];
    dict[@"1"] = @1;
    dict[@"2"] = @2;
    dict[@"3"] = @3;
    [dict removeObjectsForKeys:@[ @"3", @"2" ]];
    XCTAssertEqual(dict.count, 1);
    XCTAssertEqualObjects([dict objectForKey:@"1"], @1);
    XCTAssertNil([dict objectForKey:@"2"]);
    XCTAssertNil(dict[@"3"]);
}

- (void)testWhenEncodingThenDecodedDictionaryRemainsSorted {
    OGAMutableOrderedDictionary *dict = [OGAMutableOrderedDictionary new];
    dict[@"1"] = @1;
    dict[@"2"] = @2;
    OGAMutableOrderedDictionary *nestedDict = [OGAMutableOrderedDictionary new];
    nestedDict[@"test"] = @"test";
    nestedDict[@"newLine"] = @"newLine";
    dict[@"nested"] = nestedDict;
    dict[@"3"] = @3;
    NSError *error;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict];
    XCTAssertNil(error);
    //    NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&error];
    OGAMutableOrderedDictionary *decodedDict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    XCTAssertTrue([OGAOrderedDictionaryTestHelper testDictionary:decodedDict against:@"{\"1\":1,\"2\":2,\"nested\":{\"test\":\"test\",\"newLine\":\"newLine\"},\"3\":3}"]);
}

@end

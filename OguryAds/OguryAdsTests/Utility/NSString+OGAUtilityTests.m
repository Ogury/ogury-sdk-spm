//
// Copyright (c) 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#include "NSString+OGAUtility.h"

@interface NSStringOGAUtilityTests : XCTestCase
@end

@implementation NSStringOGAUtilityTests

- (void)testStringIsEqualToString {
    XCTAssertTrue([NSString ogaString:nil isEqualToString:nil]);
    XCTAssertTrue([NSString ogaString:@"test" isEqualToString:@"test"]);

    XCTAssertFalse([NSString ogaString:@"test" isEqualToString:nil]);
    XCTAssertFalse([NSString ogaString:nil isEqualToString:@"test"]);
    XCTAssertFalse([NSString ogaString:@"test" isEqualToString:@"anotherTest"]);
}

- (void)testIsEmpty {
    XCTAssertTrue([NSString ogaIsNilOrEmpty:nil]);
    XCTAssertTrue([NSString ogaIsNilOrEmpty:@""]);

    XCTAssertFalse([NSString ogaIsNilOrEmpty:@"test"]);
    XCTAssertFalse([NSString ogaIsNilOrEmpty:@" "]);
}

@end

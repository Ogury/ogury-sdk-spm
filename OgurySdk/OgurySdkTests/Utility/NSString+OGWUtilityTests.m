//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSString+OGWUtility.h"

@interface NSStringOGWUtilityTests : XCTestCase

@end

@implementation NSStringOGWUtilityTests

- (void)testIsEmpty {
    XCTAssertTrue([NSString ogwIsNilOrEmpty:nil]);
    XCTAssertTrue([NSString ogwIsNilOrEmpty:@""]);

    XCTAssertFalse([NSString ogwIsNilOrEmpty:@"test"]);
    XCTAssertFalse([NSString ogwIsNilOrEmpty:@" "]);
}

@end

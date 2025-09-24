//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+OGCHash.h"

@interface NSStringOGCHashTests : XCTestCase

@end

@implementation NSStringOGCHashTests


- (void)testoguryCoreSha256HashWithSalt {
    NSString *randomString1 = [NSString oguryCoreRandomSaltOfSize:10];
    XCTAssertEqual(randomString1.length, 10);
    NSString *randomString2 = [NSString oguryCoreRandomSaltOfSize:10];
    XCTAssertEqual(randomString2.length, 10);
    XCTAssertNotEqualObjects([@"18" oguryCoreSha256HashWithSalt:randomString1], [@"18" oguryCoreSha256HashWithSalt:randomString2]);
    XCTAssertEqualObjects([@"18" oguryCoreSha256HashWithSalt:randomString1], [@"18" oguryCoreSha256HashWithSalt:randomString1]);
    XCTAssertNotEqualObjects([@"18" oguryCoreSha256HashWithSalt:randomString1], [@"0" oguryCoreSha256HashWithSalt:randomString1]);
}

- (void)testoguryCoreRandomSaltOfSize {
    NSString *randomString1 = [NSString oguryCoreRandomSaltOfSize:10];
    XCTAssertEqual(randomString1.length, 10);
    NSString *randomString2 = [NSString oguryCoreRandomSaltOfSize:10];
    XCTAssertEqual(randomString2.length, 10);
    XCTAssertNotEqualObjects(randomString2, randomString1);
}

@end

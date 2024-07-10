//
//  Copyright © 2019 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGANextAd.h"

@interface OGANextAdTests : XCTestCase

@end

@implementation OGANextAdTests

- (void)testInitWithString {
    OGAJSONModelError *error;
    OGANextAd *nextAd = [[OGANextAd alloc] initWithString:@"{\"showNextAd\":true,\"nextAdId\":123}"
                                                    error:&error];

    XCTAssertNotNil(nextAd);
    XCTAssertNil(error);
    XCTAssertTrue(nextAd.showNextAd.boolValue);
    XCTAssertEqualObjects(nextAd.nextAdId, @"123");
}

- (void)testShouldShowNextAd {
    XCTAssertTrue([OGANextAd shouldShowNextAd:nil]);
    XCTAssertTrue([OGANextAd shouldShowNextAd:[OGANextAd nextAdTrue]]);

    XCTAssertFalse([OGANextAd shouldShowNextAd:[[OGANextAd alloc] init]]);
    XCTAssertFalse([OGANextAd shouldShowNextAd:[OGANextAd nextAdFalse]]);
}

- (void)testNextAdId_nextAdIsNil {
    XCTAssertEqualObjects([OGANextAd nextAdId:nil], nil);
}

- (void)testNextAdId_nextAdIdIsNil {
    OGANextAd *nextAd = [OGANextAd nextAdTrue];
    XCTAssertEqualObjects([OGANextAd nextAdId:nextAd], nil);
}

- (void)testNextAdId_nextAdIdIsEmpty {
    OGANextAd *nextAd = [OGANextAd nextAdTrue];
    nextAd.nextAdId = @"";
    XCTAssertEqualObjects([OGANextAd nextAdId:nextAd], nil);
}

- (void)testNextAdId_nextAdIdIsEqualsToNullChain {
    OGANextAd *nextAd = [OGANextAd nextAdTrue];
    nextAd.nextAdId = @"null";
    XCTAssertEqualObjects([OGANextAd nextAdId:nextAd], nil);
}

- (void)testNextAdId {
    OGANextAd *nextAd = [OGANextAd nextAdTrue];
    nextAd.nextAdId = @"next-ad-id";
    XCTAssertEqualObjects([OGANextAd nextAdId:nextAd], @"next-ad-id");
}

- (void)testNextAdTrue {
    OGANextAd *nextAd = [OGANextAd nextAdTrue];

    XCTAssertNotNil(nextAd.showNextAd);
    XCTAssertTrue(nextAd.showNextAd.boolValue);
    XCTAssertNil(nextAd.nextAdId);
}

- (void)testNextAdFalse {
    OGANextAd *nextAd = [OGANextAd nextAdFalse];

    XCTAssertNotNil(nextAd.showNextAd);
    XCTAssertFalse(nextAd.showNextAd.boolValue);
    XCTAssertNil(nextAd.nextAdId);
}

@end

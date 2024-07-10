//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAAdDsp.h"

@interface OGAAdDspTests : XCTestCase

@end

@implementation OGAAdDspTests

- (void)testCopyWithZone {
    OGAAdDsp *adDsp = [[OGAAdDsp alloc] initWithCreativeId:@"creative_id" region:@"region"];
    OGAAdDsp *adDspCopy = [adDsp copy];
    XCTAssertNotEqual(adDsp, adDspCopy);
    XCTAssertEqualObjects(adDsp.creativeId, adDspCopy.creativeId);
    XCTAssertEqualObjects(adDsp.region, adDspCopy.region);
}

- (void)testInitWithCreativeIdRegion {
    OGAAdDsp *adDsp = [[OGAAdDsp alloc] initWithCreativeId:@"creative_id" region:@"region"];
    XCTAssertEqualObjects(adDsp.creativeId, @"creative_id");
    XCTAssertEqualObjects(adDsp.region, @"region");
}

@end

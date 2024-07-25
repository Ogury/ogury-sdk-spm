//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGABannerAdResponse.h"

@interface OGABannerAdResponseTests : XCTestCase

@end

@implementation OGABannerAdResponseTests

- (void)testShouldInstantiate {
    OGABannerAdResponse *element = [[OGABannerAdResponse alloc] init];

    XCTAssertEqual(element.autoRefresh, @(NO));
    XCTAssertFalse(element.autoRefreshRate);
    XCTAssertFalse(element.fullWidth);
    XCTAssertFalse(element.isFullScreen);
}

@end

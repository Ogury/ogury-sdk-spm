//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAAdDisplayerUpdatePlacementInformation.h"

@interface OGAAdDisplayerUpdatePlacementInformationTests : XCTestCase

@end

@implementation OGAAdDisplayerUpdatePlacementInformationTests

#pragma mark - Methods

- (void)testShouldInstantiate {
    OGAAdDisplayerUpdatePlacementInformation *information = [[OGAAdDisplayerUpdatePlacementInformation alloc] initWithPlacement:OGAAdDisplayerPlacementInline];

    XCTAssertEqual(information.placement, OGAAdDisplayerPlacementInline);
}

- (void)testShouldReturnJavascriptCommandForInline {
    OGAAdDisplayerUpdatePlacementInformation *information = [[OGAAdDisplayerUpdatePlacementInformation alloc] initWithPlacement:OGAAdDisplayerPlacementInline];

    NSString *command = [information toJavascriptCommand];

    XCTAssertTrue([command containsString:@"ogySdkMraidGateway.updatePlacementType"]);
    XCTAssertTrue([command containsString:@"(\"inline\")"]);
}

- (void)testShouldReturnJavascriptCommandForInterstitial {
    OGAAdDisplayerUpdatePlacementInformation *information = [[OGAAdDisplayerUpdatePlacementInformation alloc] initWithPlacement:OGAAdDisplayerPlacementInterstitial];

    NSString *command = [information toJavascriptCommand];

    XCTAssertTrue([command containsString:@"ogySdkMraidGateway.updatePlacementType"]);
    XCTAssertTrue([command containsString:@"(\"interstitial\")"]);
}

@end

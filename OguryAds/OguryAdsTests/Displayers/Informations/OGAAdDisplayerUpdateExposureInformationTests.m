//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAAdDisplayerUpdateExposureInformation.h"
#import "OGAAdExposure.h"

@interface OGAAdDisplayerUpdateExposureInformationTests : XCTestCase

@end

@implementation OGAAdDisplayerUpdateExposureInformationTests

#pragma mark - Methods

- (void)testShouldInstantiate {
    OGAAdExposure *exposure = [[OGAAdExposure alloc] init];

    OGAAdDisplayerUpdateExposureInformation *information = [[OGAAdDisplayerUpdateExposureInformation alloc] initWithExposure:exposure];

    XCTAssertNotNil(information.adExposure);
}

- (void)testShouldReturnJavascriptCommand {
    OGAAdExposure *exposure = [[OGAAdExposure alloc] init];
    exposure.exposurePercentage = 50.0;

    OGAAdDisplayerUpdateExposureInformation *information = [[OGAAdDisplayerUpdateExposureInformation alloc] initWithExposure:exposure];

    NSString *command = [information toJavascriptCommand];

    XCTAssertTrue([command containsString:@"ogySdkMraidGateway.updateExposure"]);
    XCTAssertTrue([command containsString:@"exposedPercentage:50.0"]);
}

@end

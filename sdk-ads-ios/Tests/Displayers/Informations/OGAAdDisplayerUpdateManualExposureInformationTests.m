//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAAdDisplayerUpdateManualExposureInformation.h"
#import "OGAAdExposure.h"

@interface OGAAdDisplayerUpdateManualExposureInformationTests : XCTestCase

@end

@implementation OGAAdDisplayerUpdateManualExposureInformationTests

#pragma mark - Methods

- (void)testShouldInstantiate {
    OGAAdDisplayerUpdateManualExposureInformation *information = [[OGAAdDisplayerUpdateManualExposureInformation alloc] initWithSize:CGSizeMake(256, 256)];

    XCTAssertEqual(information.size.width, 256);
    XCTAssertEqual(information.size.height, 256);
}

- (void)testShouldReturnJavascriptCommand {
    OGAAdDisplayerUpdateManualExposureInformation *information = [[OGAAdDisplayerUpdateManualExposureInformation alloc] initWithSize:CGSizeMake(256, 256)];

    NSString *command = [information toJavascriptCommand];

    XCTAssertTrue([command containsString:@"ogySdkMraidGateway.updateExposure"]);
    XCTAssertTrue([command containsString:@"exposedPercentage: 100.0"]);
    XCTAssertTrue([command containsString:@"visibleRectangle: {x: 0, y: 0, width: 256, height: 256}"]);
}

@end

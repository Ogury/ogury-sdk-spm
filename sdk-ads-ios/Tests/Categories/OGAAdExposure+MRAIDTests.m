//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAAdExposure.h"
#import "OGAAdExposure+MRAID.h"

@interface OGAAdExposure_MRAIDTests : XCTestCase

@end

@implementation OGAAdExposure_MRAIDTests

- (void)testShouldReturnMRAIDCommandWithExposurePercentage {
    OGAAdExposure *exposure = [[OGAAdExposure alloc] init];
    exposure.exposurePercentage = 50.0;

    NSString *command = [exposure toMRAIDCommand];

    XCTAssertTrue([command containsString:@"ogySdkMraidGateway.updateExposure"]);
    XCTAssertTrue([command containsString:@"exposedPercentage:50.0,"]);
}

- (void)testShouldReturnMRAIDCommandWithOcclusionRectangleString {
    OGAAdExposure *exposure = [[OGAAdExposure alloc] init];
    exposure.exposurePercentage = 50.0;
    exposure.occlusionRectangles = @[ [NSValue valueWithCGRect:CGRectMake(0, 0, 256, 256)] ];

    NSString *command = [exposure toMRAIDCommand];

    XCTAssertTrue([command containsString:@"ogySdkMraidGateway.updateExposure"]);
    XCTAssertTrue([command containsString:@"exposedPercentage:50.0"]);
    XCTAssertTrue([command containsString:@"occlusionRectangles: [{x: 0, y: 0, width: 256, height: 256}]"]);
}

- (void)testShouldReturnMRAIDCommandWithMultipleOcclusionRectangleString {
    OGAAdExposure *exposure = [[OGAAdExposure alloc] init];
    exposure.exposurePercentage = 50.0;

    exposure.occlusionRectangles = @[ [NSValue valueWithCGRect:CGRectMake(0, 0, 256, 256)], [NSValue valueWithCGRect:CGRectMake(0, 0, 256, 256)] ];

    NSString *command = [exposure toMRAIDCommand];

    XCTAssertTrue([command containsString:@"ogySdkMraidGateway.updateExposure"]);
    XCTAssertTrue([command containsString:@"exposedPercentage:50.0"]);
    XCTAssertTrue([command containsString:@"occlusionRectangles: [{x: 0, y: 0, width: 256, height: 256},{x: 0, y: 0, width: 256, height: 256}]"]);
}

- (void)testShouldReturnMRAIDCommandWithNoVisibleRectangleString {
    OGAAdExposure *exposure = [[OGAAdExposure alloc] init];
    exposure.exposurePercentage = 50.0;

    NSString *command = [exposure toMRAIDCommand];

    XCTAssertTrue([command containsString:@"ogySdkMraidGateway.updateExposure"]);
    XCTAssertTrue([command containsString:@"exposedPercentage:50.0"]);
    XCTAssertTrue([command containsString:@"visibleRectangle: null"]);
}

- (void)testShouldReturnMRAIDCommandWithVisibleRectangleString {
    OGAAdExposure *exposure = [[OGAAdExposure alloc] init];
    exposure.exposurePercentage = 50.0;
    exposure.visibleRectangle = CGRectMake(0, 0, 256, 256);

    NSString *command = [exposure toMRAIDCommand];

    XCTAssertTrue([command containsString:@"ogySdkMraidGateway.updateExposure"]);
    XCTAssertTrue([command containsString:@"exposedPercentage:50.0"]);
    XCTAssertTrue([command containsString:@"visibleRectangle:{x: 0, y: 0, width: 256, height: 256}"]);
}

@end

//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAAdDisplayerUpdateViewabilityInformation.h"

@interface OGAAdDisplayerUpdateViewabilityInformationTests : XCTestCase

@end

@implementation OGAAdDisplayerUpdateViewabilityInformationTests

#pragma mark - Methods

- (void)testShouldInstantiate {
    OGAAdDisplayerUpdateViewabilityInformation *information = [[OGAAdDisplayerUpdateViewabilityInformation alloc] initWithViewability:YES];

    XCTAssertTrue(information.isViewable);
}

- (void)testShouldReturnJavascriptCommandWhenViewable {
    OGAAdDisplayerUpdateViewabilityInformation *information = [[OGAAdDisplayerUpdateViewabilityInformation alloc] initWithViewability:YES];

    NSString *command = [information toJavascriptCommand];

    XCTAssertTrue([command containsString:@"ogySdkMraidGateway.updateViewability"]);
    XCTAssertTrue([command containsString:@"(true)"]);
}

- (void)testShouldReturnJavascriptCommandWhenNotViewable {
    OGAAdDisplayerUpdateViewabilityInformation *information = [[OGAAdDisplayerUpdateViewabilityInformation alloc] initWithViewability:NO];

    NSString *command = [information toJavascriptCommand];

    XCTAssertTrue([command containsString:@"ogySdkMraidGateway.updateViewability"]);
    XCTAssertTrue([command containsString:@"(false)"]);
}

@end

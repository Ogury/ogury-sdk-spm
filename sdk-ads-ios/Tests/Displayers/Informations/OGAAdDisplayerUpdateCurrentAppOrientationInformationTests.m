//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAAdDisplayerUpdateCurrentAppOrientationInformation.h"

@interface OGAAdDisplayerUpdateCurrentAppOrientationInformationTests : XCTestCase

@end

@implementation OGAAdDisplayerUpdateCurrentAppOrientationInformationTests

- (void)testShouldInstantiate {
    OGAAdDisplayerUpdateCurrentAppOrientationInformation *information = [[OGAAdDisplayerUpdateCurrentAppOrientationInformation alloc] initWithOrientation:@"portrait" locked:NO];
    XCTAssertNotNil(information);
    XCTAssertEqual(information.orientation, @"portrait");
    XCTAssertEqual(information.locked, NO);
}

- (void)testShouldReturnJavascriptCommandNotLocked {
    OGAAdDisplayerUpdateCurrentAppOrientationInformation *information = [[OGAAdDisplayerUpdateCurrentAppOrientationInformation alloc] initWithOrientation:@"portrait" locked:NO];
    NSString *command = [information toJavascriptCommand];
    XCTAssertEqualObjects(@"ogySdkMraidGateway.updateCurrentAppOrientation({orientation: \"portrait\", locked: false})", command);
}

- (void)testShouldReturnJavascriptCommandLocked {
    OGAAdDisplayerUpdateCurrentAppOrientationInformation *information = [[OGAAdDisplayerUpdateCurrentAppOrientationInformation alloc] initWithOrientation:@"portrait" locked:YES];
    NSString *command = [information toJavascriptCommand];
    XCTAssertEqualObjects(@"ogySdkMraidGateway.updateCurrentAppOrientation({orientation: \"portrait\", locked: true})", command);
}

@end

//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAAdDisplayerUpdateStateInformation.h"
#import "OGAMRAIDState.h"

@interface OGAAdDisplayerUpdateStateInformationTests : XCTestCase

@end

@implementation OGAAdDisplayerUpdateStateInformationTests

- (void)testShouldInstantiate {
    OGAAdDisplayerUpdateStateInformation *information = [[OGAAdDisplayerUpdateStateInformation alloc] initWithMraidState:OGAMRAIDStateDefault];
    XCTAssertNotNil(information);
    XCTAssertTrue([information.mraidState isEqualToString:@"default"]);
}

- (void)testShouldReturnJavascriptCommand {
    OGAAdDisplayerUpdateStateInformation *information = [[OGAAdDisplayerUpdateStateInformation alloc] initWithMraidState:OGAMRAIDStateDefault];
    NSString *command = [information toJavascriptCommand];
    XCTAssertEqualObjects(@"ogySdkMraidGateway.updateState(\"default\")", command);
}

@end

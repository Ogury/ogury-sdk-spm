//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAAdDisplayerUserCloseSKOverlayInformation.h"
#import "OguryError+utility.h"

@interface OGAAdDisplayerUserCloseSKOverlayInformationTests : XCTestCase

@end

@implementation OGAAdDisplayerUserCloseSKOverlayInformationTests

- (void)testShouldInstantiate {
    OGAAdDisplayerUserCloseSKOverlayInformation *information = [[OGAAdDisplayerUserCloseSKOverlayInformation alloc] init];

    XCTAssertNotNil(information);
    XCTAssertNil(information.errorCode);
}

- (void)testShouldInstantiateError {
    OGAAdDisplayerUserCloseSKOverlayInformation *information = [[OGAAdDisplayerUserCloseSKOverlayInformation alloc] initWithErrorCode:@(5)];

    XCTAssertNotNil(information);
    XCTAssertEqual(information.errorCode, @(5));
}

- (void)testShouldReturnJavascriptCommand {
    OGAAdDisplayerUserCloseSKOverlayInformation *information = [[OGAAdDisplayerUserCloseSKOverlayInformation alloc] init];

    NSString *command = [information toJavascriptCommand];

    XCTAssertTrue([command isEqualToString:@"ogySdkMraidGateway.ogyUserCloseSKOverlay()"]);
}

- (void)testShouldReturnJavascriptCommandError {
    OGAAdDisplayerUserCloseSKOverlayInformation *information = [[OGAAdDisplayerUserCloseSKOverlayInformation alloc] initWithErrorCode:@(5)];

    NSString *command = [information toJavascriptCommand];

    XCTAssertTrue([command isEqualToString:@"ogySdkMraidGateway.ogyUserCloseSKOverlay({error_code:5})"]);
}

@end

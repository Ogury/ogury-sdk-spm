//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAAdDisplayerSystemCloseInformation.h"

@interface OGAAdDisplayerSystemCloseInformationTests : XCTestCase

@end

@implementation OGAAdDisplayerSystemCloseInformationTests

- (void)testShouldInstantiate {
    OGAAdDisplayerSystemCloseInformation *information = [[OGAAdDisplayerSystemCloseInformation alloc] init];
    XCTAssertNotNil(information);
}

- (void)testShouldReturnJavascriptCommand {
    OGAAdDisplayerSystemCloseInformation *information = [[OGAAdDisplayerSystemCloseInformation alloc] init];
    NSString *command = [information toJavascriptCommand];
    XCTAssertEqualObjects(@"ogySdkMraidGateway.callEventListeners(\"ogyOnCloseSystem\", {})", command);
}

@end

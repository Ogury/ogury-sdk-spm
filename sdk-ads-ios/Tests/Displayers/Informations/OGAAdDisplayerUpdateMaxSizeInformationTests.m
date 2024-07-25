//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAAdDisplayerUpdateMaxSizeInformation.h"

@interface OGAAdDisplayerUpdateMaxSizeInformationTests : XCTestCase

@end

@implementation OGAAdDisplayerUpdateMaxSizeInformationTests

- (void)testShouldInstantiate {
    OGAAdDisplayerUpdateMaxSizeInformation *information = [[OGAAdDisplayerUpdateMaxSizeInformation alloc] initWithSize:CGSizeMake(24, 15)];
    XCTAssertNotNil(information);
    XCTAssertEqual(information.size.width, 24);
    XCTAssertEqual(information.size.height, 15);
}

- (void)testShouldReturnJavascriptCommand {
    OGAAdDisplayerUpdateMaxSizeInformation *information = [[OGAAdDisplayerUpdateMaxSizeInformation alloc] initWithSize:CGSizeMake(24, 15)];
    NSString *command = [information toJavascriptCommand];
    XCTAssertEqualObjects(@"ogySdkMraidGateway.updateMaxSize({width: 24, height: 15})", command);
}

@end

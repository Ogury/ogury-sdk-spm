//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAAdDisplayerUpdateScreenSizeInformation.h"

@interface OGAAdDisplayerUpdateScreenSizeInformationTests : XCTestCase

@end

@implementation OGAAdDisplayerUpdateScreenSizeInformationTests

#pragma mark - Methods

- (void)testShouldInstantiate {
    OGAAdDisplayerUpdateScreenSizeInformation *information = [[OGAAdDisplayerUpdateScreenSizeInformation alloc] initWithSize:CGSizeMake(256, 256)];

    XCTAssertEqual(information.size.width, 256);
    XCTAssertEqual(information.size.height, 256);
}

- (void)testShouldReturnJavascriptCommand {
    OGAAdDisplayerUpdateScreenSizeInformation *information = [[OGAAdDisplayerUpdateScreenSizeInformation alloc] initWithSize:CGSizeMake(256, 256)];

    NSString *command = [information toJavascriptCommand];

    XCTAssertTrue([command containsString:@"ogySdkMraidGateway.updateScreenSize"]);
    XCTAssertTrue([command containsString:@"({width: 256, height: 256})"]);
}

@end

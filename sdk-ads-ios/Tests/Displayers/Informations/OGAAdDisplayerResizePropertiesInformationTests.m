//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAAdDisplayerResizePropertiesInformation.h"

@interface OGAAdDisplayerResizePropertiesInformationTests : XCTestCase

@end

@implementation OGAAdDisplayerResizePropertiesInformationTests

#pragma mark - Methods

- (void)testShouldInstantiate {
    OGAAdDisplayerResizePropertiesInformation *information = [[OGAAdDisplayerResizePropertiesInformation alloc] initWithWidth:1 height:2 xOffset:3 yOffset:4];

    XCTAssertEqual(information.width, 1);
    XCTAssertEqual(information.height, 2);
    XCTAssertEqual(information.xOffset, 3);
    XCTAssertEqual(information.yOffset, 4);
}

- (void)testShouldReturnJavascriptCommandForInline {
    OGAAdDisplayerResizePropertiesInformation *information = [[OGAAdDisplayerResizePropertiesInformation alloc] initWithWidth:1 height:2 xOffset:3 yOffset:4];

    NSString *command = [information toJavascriptCommand];

    XCTAssertTrue([command containsString:@"ogySdkMraidGateway.updateResizeProperties"]);
    XCTAssertTrue([command containsString:@"({width: 1, height: 2, offsetX: 3, offsetY: 4, customClosePosition: \"right\", allowOffscreen: false})"]);
}

@end

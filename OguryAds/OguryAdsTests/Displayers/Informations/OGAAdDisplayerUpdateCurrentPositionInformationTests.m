//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAAdDisplayerUpdateCurrentPositionInformation.h"

@interface OGAAdDisplayerUpdateCurrentPositionInformation ()

@property(nonatomic, assign) CGSize size;
@property(nonatomic, assign) CGPoint position;

@end

@interface OGAAdDisplayerUpdateCurrentPositionInformationTests : XCTestCase

@end

@implementation OGAAdDisplayerUpdateCurrentPositionInformationTests

- (void)testShouldInstantiate {
    OGAAdDisplayerUpdateCurrentPositionInformation *information = [[OGAAdDisplayerUpdateCurrentPositionInformation alloc] initWithPosition:CGPointMake(20, 10) size:CGSizeMake(24, 15)];
    XCTAssertNotNil(information);
    XCTAssertEqual(information.size.width, 24);
    XCTAssertEqual(information.size.height, 15);
    XCTAssertEqual(information.position.x, 20);
    XCTAssertEqual(information.position.y, 10);
}

- (void)testShouldReturnJavascriptCommand {
    OGAAdDisplayerUpdateCurrentPositionInformation *information = [[OGAAdDisplayerUpdateCurrentPositionInformation alloc] initWithPosition:CGPointMake(20, 10) size:CGSizeMake(24, 15)];
    NSString *command = [information toJavascriptCommand];
    XCTAssertEqualObjects(@"ogySdkMraidGateway.updateCurrentPosition({x: 20, y: 10, width: 24, height: 15})", command);
}

@end

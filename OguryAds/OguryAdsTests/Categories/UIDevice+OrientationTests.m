//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UIDevice+Orientation.h"
#import <OCMock/OCMock.h>

@interface UIDevice (Tests)

+ (NSString *_Nullable)orientationStringForDevice:(UIDevice *)device;

@end

@interface UIDevice_OrientationTests : XCTestCase

@end

@implementation UIDevice_OrientationTests

- (void)testShouldReturnNilFromDeviceIfOrientationIsNotValid {
    id deviceMock = OCMClassMock(UIDevice.self);

    [(UIDevice *)[[deviceMock stub] andReturnValue:@(UIDeviceOrientationFaceDown)] orientation];

    NSString *orientationString = [UIDevice orientationStringForDevice:deviceMock];

    XCTAssertNil(orientationString);

    [deviceMock stopMocking];
}

- (void)testShouldReturnPortraitOrientationStringFromDevice {
    id deviceMock = OCMClassMock(UIDevice.self);

    [(UIDevice *)[[deviceMock stub] andReturnValue:@(UIDeviceOrientationPortrait)] orientation];

    NSString *orientationString = [UIDevice orientationStringForDevice:deviceMock];

    XCTAssertTrue([orientationString isEqualToString:@"portrait"], "Should be portait");

    [deviceMock stopMocking];
}

- (void)testShouldReturnLandscapeOrientationStringFromDevice {
    id deviceMock = OCMClassMock(UIDevice.self);

    [(UIDevice *)[[deviceMock stub] andReturnValue:@(UIDeviceOrientationLandscapeLeft)] orientation];

    NSString *orientationString = [UIDevice orientationStringForDevice:deviceMock];

    XCTAssertTrue([orientationString isEqualToString:@"landscape"], "Should be landscape");

    [deviceMock stopMocking];
}

@end

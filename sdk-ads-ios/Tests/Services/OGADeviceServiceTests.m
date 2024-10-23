//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "OGADeviceOrientationConstants.h"
#import "OGADeviceService.h"
#import "UIDevice+Orientation.h"

@interface OGADeviceService (Testing)

- (instancetype)initWithDevice:(UIDevice *)device;

@end

@interface OGADeviceServiceTests : XCTestCase

@end

@implementation OGADeviceServiceTests

- (void)testShouldReturnUnknownInterfaceOrientationIfApplicationAndDeviceAreNotAvailable {
    id mockedDevice = OCMClassMock(UIDevice.self);

    OGADeviceService *service = [[OGADeviceService alloc] initWithDevice:mockedDevice];

    NSString *interfaceOrientationString = [service interfaceOrientation];

    XCTAssertEqual(interfaceOrientationString, OGAOrientationStringPortrait);
}

- (void)testShouldReturnDeviceInterfaceOrientationIfApplicationIsNotAvailable {
    id mockedDevice = OCMClassMock(UIDevice.self);

    [[[mockedDevice stub] andReturn:OGAOrientationStringLandscape] ogaOrientationString];

    OGADeviceService *service = [[OGADeviceService alloc] initWithDevice:mockedDevice];

    NSString *interfaceOrientationString = [service interfaceOrientation];

    XCTAssertEqual(interfaceOrientationString, OGAOrientationStringLandscape);
}

@end

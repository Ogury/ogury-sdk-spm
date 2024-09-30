//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "OGADeviceOrientationConstants.h"
#import "OGADeviceService.h"
#import "UIApplication+Orientation.h"
#import "UIDevice+Orientation.h"

@interface OGADeviceService (Testing)

- (instancetype)initWithApplication:(UIApplication *)application device:(UIDevice *)device;

@end

@interface OGADeviceServiceTests : XCTestCase

@end

@implementation OGADeviceServiceTests

- (void)testShouldReturnUnknownInterfaceOrientationIfApplicationAndDeviceAreNotAvailable {
    id mockedApplication = OCMClassMock(UIApplication.self);
    id mockedDevice = OCMClassMock(UIDevice.self);

    [[[mockedApplication stub] andReturn:nil] OGAOrientationString];

    OGADeviceService *service = [[OGADeviceService alloc] initWithApplication:mockedApplication device:mockedDevice];

    NSString *interfaceOrientationString = [service interfaceOrientation];

    XCTAssertEqual(interfaceOrientationString, OGAOrientationStringPortrait);
}

- (void)testShouldReturnDeviceInterfaceOrientationIfApplicationIsNotAvailable {
    id mockedApplication = OCMClassMock(UIApplication.self);
    id mockedDevice = OCMClassMock(UIDevice.self);

    [[[mockedApplication stub] andReturn:nil] OGAOrientationString];
    [[[mockedDevice stub] andReturn:OGAOrientationStringLandscape] ogaOrientationString];

    OGADeviceService *service = [[OGADeviceService alloc] initWithApplication:mockedApplication device:mockedDevice];

    NSString *interfaceOrientationString = [service interfaceOrientation];

    XCTAssertEqual(interfaceOrientationString, OGAOrientationStringLandscape);
}

@end

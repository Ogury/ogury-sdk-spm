//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UIApplication+Orientation.h"
#import <OCMock/OCMock.h>
#import "OGADeviceOrientationConstants.h"

@interface UIApplication (Tests)

+ (NSString *_Nullable)orientationStringForApplication:(UIApplication *)application;

@end

@interface UIApplication_OrientationTests : XCTestCase

@end

@implementation UIApplication_OrientationTests

- (void)testShouldReturnInterfaceOrientationFromWindowScene API_AVAILABLE(ios(13.0)) {
    UIWindowScene *windowSceneMock = OCMClassMock(UIWindowScene.self);
    OCMStub(windowSceneMock.activationState).andReturn(UISceneActivationStateForegroundActive);
    OCMStub(windowSceneMock.interfaceOrientation).andReturn(UIDeviceOrientationLandscapeLeft);

    UIApplication *applicationMock = OCMClassMock(UIApplication.self);
    OCMStub(applicationMock.connectedScenes).andReturn(@[ windowSceneMock ]);

    NSString *orientationString = [UIApplication orientationStringForApplication:applicationMock];

    XCTAssertTrue([orientationString isEqualToString:OGAOrientationStringLandscape], "Should be landscape");
}

- (void)testShouldReturnNilFromStatusBar {
    id applicationMock = OCMClassMock(UIApplication.self);

    [[[applicationMock stub] andReturnValue:@(UIDeviceOrientationFaceDown)] statusBarOrientation];

    NSString *orientationString = [UIApplication orientationStringForApplication:applicationMock];

    XCTAssertNil(orientationString);
}

- (void)testShouldReturnPortraitOrientationStringFromStatusBar {
    id applicationMock = OCMClassMock(UIApplication.self);

    [[[applicationMock stub] andReturnValue:@(UIDeviceOrientationPortrait)] statusBarOrientation];

    NSString *orientationString = [UIApplication orientationStringForApplication:applicationMock];

    XCTAssertTrue([orientationString isEqualToString:OGAOrientationStringPortrait], "Should be portait");
}

- (void)testShouldReturnLandscapeOrientationStringFromStatusBar {
    id applicationMock = OCMClassMock(UIApplication.self);

    [[[applicationMock stub] andReturnValue:@(UIDeviceOrientationLandscapeLeft)] statusBarOrientation];

    NSString *orientationString = [UIApplication orientationStringForApplication:applicationMock];

    XCTAssertTrue([orientationString isEqualToString:OGAOrientationStringLandscape], "Should be landscape");
}

@end

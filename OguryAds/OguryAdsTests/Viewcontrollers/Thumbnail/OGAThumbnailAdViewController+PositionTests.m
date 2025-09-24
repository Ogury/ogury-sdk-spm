//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAThumbnailAdViewController+Testing.h"
#import "OGAThumbnailAdViewController+Position.h"
#import "OGAAdDisplayerUpdateExposureInformation.h"
#import "OGAMRAIDAdDisplayer.h"
#import "OGALog.h"
#import <OCMock/OCMock.h>
#import "OGAAdDisplayerUpdateScreenSizeInformation.h"
#import "OGAAdDisplayerUpdateCurrentAppOrientationInformation.h"
#import "OGAAdDisplayerUpdateCurrentPositionInformation.h"
#import "OGAAdConfiguration.h"

@interface OGAThumbnailAdViewController ()

@property(nonatomic) CGSize thumbnailSize;
@property(nonatomic) CGPoint thumbnailPosition;
@property(nonatomic) BOOL keyboardOnScreen;
@property(nonatomic) CGRect keyboardRect;
@property(nonatomic, assign) OguryOffset offsetRatio;
@property(nonatomic, assign) OguryRectCorner rectCorner;
@property(nonatomic, strong) OGADeviceService *deviceService;

- (CGFloat)getDeviceWidth;

- (CGFloat)getDeviceHeight;

- (CGFloat)getVisibleHeight;

- (void)checkThumbnailOutOfBounds;

- (void)checkThumbnailPartialOutofBounds;

- (void)initThumbnailPosition;

@end

@interface OGAAdDisplayerUpdateCurrentPositionInformation ()

@property(nonatomic) CGSize size;
@property(nonatomic) CGPoint position;

@end

@interface OGAThumbnailAdViewController_PositionTests : XCTestCase

@property(nonatomic, strong) id<OGAAdDisplayer> displayer;
@property(nonatomic, strong) OGAAdExposureController *exposerController;
@property(nonatomic, strong) OGAThumbnailAdViewController *thumbnailController;
@property(nonatomic, strong) OGAThumbnailAdWindow *window;
@property(nonatomic, strong) OGAThumbnailAdRestrictionsManager *restrictionManager;
@property(nonatomic, strong) NSNotificationCenter *center;
@property(nonatomic, strong) OGAAd *ad;
@property(nonatomic, strong) OGAThumbnailAdResponse *thumbnailAdResponse;
@property(nonatomic, strong) OGAAdConfiguration *config;
@property(nonatomic, strong) OGASizeSafeAreaController *safeAreaController;
@property(nonatomic, strong) OGAAdImpressionManager *impressionManager;
@property(nonatomic, strong) NSUserDefaults *userDefaults;
@property(nonatomic, strong) OGADeviceService *deviceService;
@property(nonatomic, strong) OGALog *log;

@end

@implementation OGAThumbnailAdViewController_PositionTests

- (void)setUp {
    self.displayer = OCMClassMock([OGAMRAIDAdDisplayer class]);
    self.exposerController = OCMClassMock([OGAAdExposureController class]);
    self.window = OCMClassMock([OGAThumbnailAdWindow class]);
    self.restrictionManager = OCMClassMock([OGAThumbnailAdRestrictionsManager class]);
    self.center = OCMClassMock([NSNotificationCenter class]);
    self.ad = OCMClassMock([OGAAd class]);
    self.thumbnailAdResponse = OCMClassMock([OGAThumbnailAdResponse class]);
    self.config = OCMClassMock([OGAAdConfiguration class]);
    self.safeAreaController = OCMClassMock([OGASizeSafeAreaController class]);
    self.impressionManager = OCMClassMock([OGAAdImpressionManager class]);
    self.userDefaults = OCMClassMock([NSUserDefaults class]);
    self.deviceService = OCMClassMock([OGADeviceService class]);
    self.log = OCMClassMock([OGALog class]);

    OCMStub([self.safeAreaController getUsableFullscreenFrameWithWindow:[OCMArg any]]).andReturn(CGRectMake(0, 0, 100, 100));
    OCMStub([self.config corner]).andReturn(OguryRectCornerTopLeft);
    OCMStub([self.config offset]).andReturn(OguryOffsetMake(10, 10));
    OCMStub([self.ad thumbnailAdResponse]).andReturn(self.thumbnailAdResponse);
    OCMStub([self.displayer ad]).andReturn(self.ad);
    OCMStub([self.ad adConfiguration]).andReturn(self.config);

    OGAThumbnailAdViewController *thumbnailController = [[OGAThumbnailAdViewController alloc] initWithWindow:self.window
                                                                                          restrictionManager:self.restrictionManager
                                                                                          notificationCenter:self.center
                                                                                          safeAreaController:self.safeAreaController
                                                                                           impressionManager:self.impressionManager
                                                                                               deviceService:self.deviceService
                                                                                                userDefaults:self.userDefaults
                                                                                                         log:self.log];
    self.thumbnailController = OCMPartialMock(thumbnailController);

    [self.thumbnailController setupExposureController:self.exposerController];
    self.thumbnailController.displayer = self.displayer;
    self.thumbnailController.thumbnailSize = CGSizeMake(24, 24);
    self.thumbnailController.offsetRatio = OguryOffsetMake(0, 0);
    self.thumbnailController.rectCorner = OguryRectCornerTopLeft;
}

- (void)testUpdateOffsetRatioZero {
    OCMStub([self.thumbnailController getDeviceWidth]).andReturn(0);
    OCMStub([self.thumbnailController getVisibleHeight]).andReturn(0);
    [self.thumbnailController updateOffsetRatio];
    XCTAssertEqual(self.thumbnailController.offsetRatio.x, 0);
    XCTAssertEqual(self.thumbnailController.offsetRatio.y, 0);
}

- (void)testUpdateOffsetXNegativeYNegative {
    OCMStub([self.thumbnailController getDeviceWidth]).andReturn(100);
    OCMStub([self.thumbnailController getVisibleHeight]).andReturn(100);
    self.thumbnailController.thumbnailPosition = CGPointMake(-10, -10);
    [self.thumbnailController updateOffsetRatio];
    XCTAssertEqual(self.thumbnailController.offsetRatio.x, -0.1);
    XCTAssertEqual(self.thumbnailController.offsetRatio.y, -0.1);
    XCTAssertEqual(self.thumbnailController.rectCorner, OguryRectCornerTopLeft);
}

- (void)testUpdateOffsetTopLeft {
    OCMStub([self.thumbnailController getDeviceWidth]).andReturn(100);
    OCMStub([self.thumbnailController getVisibleHeight]).andReturn(100);
    self.thumbnailController.thumbnailPosition = CGPointMake(10, 10);
    [self.thumbnailController updateOffsetRatio];
    XCTAssertEqual(self.thumbnailController.offsetRatio.x, 0.1);
    XCTAssertEqual(self.thumbnailController.offsetRatio.y, 0.1);
    XCTAssertEqual(self.thumbnailController.rectCorner, OguryRectCornerTopLeft);
}

- (void)testUpdateOffsetTopRight {
    OCMStub([self.thumbnailController getDeviceWidth]).andReturn(100);
    OCMStub([self.thumbnailController getVisibleHeight]).andReturn(100);
    self.thumbnailController.thumbnailPosition = CGPointMake(66, 10);
    [self.thumbnailController updateOffsetRatio];
    XCTAssertEqual(self.thumbnailController.offsetRatio.x, 0.1);
    XCTAssertEqual(self.thumbnailController.offsetRatio.y, 0.1);
    XCTAssertEqual(self.thumbnailController.rectCorner, OguryRectCornerTopRight);
}

- (void)testUpdateOffsetBottomLeft {
    OCMStub([self.thumbnailController getDeviceWidth]).andReturn(100);
    OCMStub([self.thumbnailController getVisibleHeight]).andReturn(100);
    self.thumbnailController.thumbnailPosition = CGPointMake(10, 66);
    [self.thumbnailController updateOffsetRatio];
    XCTAssertEqual(self.thumbnailController.offsetRatio.x, 0.1);
    XCTAssertEqual(self.thumbnailController.offsetRatio.y, 0.1);
    XCTAssertEqual(self.thumbnailController.rectCorner, OguryRectCornerBottomLeft);
}

- (void)testUpdateOffsetBottomRight {
    OCMStub([self.thumbnailController getDeviceWidth]).andReturn(100);
    OCMStub([self.thumbnailController getVisibleHeight]).andReturn(100);
    self.thumbnailController.thumbnailPosition = CGPointMake(66, 66);
    [self.thumbnailController updateOffsetRatio];
    XCTAssertEqual(self.thumbnailController.offsetRatio.x, 0.1);
    XCTAssertEqual(self.thumbnailController.offsetRatio.y, 0.1);
    XCTAssertEqual(self.thumbnailController.rectCorner, OguryRectCornerBottomRight);
}

- (void)testApplyOffsetToPositionTopLeft {
    OCMStub([self.thumbnailController getDeviceWidth]).andReturn(100);
    OCMStub([self.thumbnailController getVisibleHeight]).andReturn(100);
    self.thumbnailController.offsetRatio = OguryOffsetMake(0.1, 0.1);
    [self.thumbnailController applyOffsetToPosition];
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.x, 10);
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.y, 10);
}

- (void)testApplyOffsetToPositionTopRight {
    OCMStub([self.thumbnailController getDeviceWidth]).andReturn(100);
    OCMStub([self.thumbnailController getVisibleHeight]).andReturn(100);
    self.thumbnailController.offsetRatio = OguryOffsetMake(0.1, 0.1);
    self.thumbnailController.rectCorner = OguryRectCornerTopRight;
    [self.thumbnailController applyOffsetToPosition];
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.x, 66);
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.y, 10);
}

- (void)testApplyOffsetToPositionBottomLeft {
    OCMStub([self.thumbnailController getDeviceWidth]).andReturn(100);
    OCMStub([self.thumbnailController getVisibleHeight]).andReturn(100);
    self.thumbnailController.offsetRatio = OguryOffsetMake(0.1, 0.1);
    self.thumbnailController.rectCorner = OguryRectCornerBottomLeft;
    [self.thumbnailController applyOffsetToPosition];
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.x, 10);
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.y, 66);
}

- (void)testApplyOffsetToPositionBottomRight {
    OCMStub([self.thumbnailController getDeviceWidth]).andReturn(100);
    OCMStub([self.thumbnailController getVisibleHeight]).andReturn(100);
    self.thumbnailController.offsetRatio = OguryOffsetMake(0.1, 0.1);
    self.thumbnailController.rectCorner = OguryRectCornerBottomRight;
    [self.thumbnailController applyOffsetToPosition];
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.x, 66);
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.y, 66);
}

- (void)testInitThumbnailPositionZeroDeviceWidth {
    OCMStub([self.thumbnailController getDeviceWidth]).andReturn(0);
    OCMStub([self.thumbnailController getVisibleHeight]).andReturn(100);
    [self.thumbnailController initThumbnailPosition];
    XCTAssertEqual(self.thumbnailController.rectCorner, OguryRectCornerTopLeft);
    XCTAssertEqual(self.thumbnailController.thumbnailSize.width, 24);
    XCTAssertEqual(self.thumbnailController.thumbnailSize.height, 24);
    XCTAssertEqual(self.thumbnailController.offsetRatio.x, 0);
    XCTAssertEqual(self.thumbnailController.offsetRatio.y, 0);
}

- (void)testInitThumbnailPosition {
    OCMStub([self.thumbnailController getDeviceWidth]).andReturn(100);
    OCMStub([self.thumbnailController getVisibleHeight]).andReturn(100);
    [self.thumbnailController initThumbnailPosition];
    XCTAssertEqual(self.thumbnailController.rectCorner, OguryRectCornerTopLeft);
    XCTAssertEqual(self.thumbnailController.offsetRatio.x, 0.1);
    XCTAssertEqual(self.thumbnailController.offsetRatio.y, 0.1);
}

- (void)testSetupThumbnailPosition {
    OCMStub([self.thumbnailController applyOffsetToPosition]);
    OCMStub([self.thumbnailController initThumbnailPosition]);
    OCMStub([self.thumbnailController checkThumbnailCorrectPosition]);
    OCMStub([self.thumbnailController updateOffsetRatio]);
    [self.thumbnailController setupThumbnailPosition];
    OCMVerify([self.thumbnailController applyOffsetToPosition]);
    OCMVerify([self.thumbnailController initThumbnailPosition]);
    OCMVerify([self.thumbnailController checkThumbnailCorrectPosition]);
    OCMVerify([self.thumbnailController updateOffsetRatio]);
}

- (void)testInitThumbnailSize {
    OCMStub([self.thumbnailAdResponse width]).andReturn(@"180");
    OCMStub([self.thumbnailAdResponse height]).andReturn(@"101");
    [self.thumbnailController initThumbnailSize];
    XCTAssertEqual(self.thumbnailController.thumbnailSize.height, 101);
    XCTAssertEqual(self.thumbnailController.thumbnailSize.width, 180);
}

- (void)testCheckThumbnailPartialOutofBoundsTopLeft {
    OCMStub([self.thumbnailController getScreenSize]).andReturn(CGSizeMake(100, 100));
    self.thumbnailController.thumbnailPosition = CGPointMake(-10, -10);
    [self.thumbnailController checkThumbnailPartialOutofBounds];
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.x, 0);
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.y, 0);
}

- (void)testCheckThumbnailPartialOutofBoundsBottomRight {
    OCMStub([self.thumbnailController getScreenSize]).andReturn(CGSizeMake(100, 100));
    self.thumbnailController.thumbnailPosition = CGPointMake(100, 100);
    [self.thumbnailController checkThumbnailPartialOutofBounds];
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.x, 76);
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.y, 76);
}

- (void)testGetDeviceWidthNoScene {
    OCMStub([self.thumbnailController getScreenSize]).andReturn(CGSizeMake(100, 100));
    if (@available(iOS 13.0, *)) {
        self.thumbnailController.window.windowScene = nil;
    }
    XCTAssertEqual([self.thumbnailController getDeviceWidth], 100);
}

- (void)testGetDeviceHeightWithoutStatusBarWithKeyboard {
    self.thumbnailController.keyboardOnScreen = YES;
    self.thumbnailController.keyboardRect = CGRectMake(0, 0, 100, 20);
    OCMStub([self.thumbnailController getScreenSize]).andReturn(CGSizeMake(100, 100));
    XCTAssertEqual([self.thumbnailController getVisibleHeight], 80);
}

- (void)testGetDeviceHeightWithoutStatusBarNoKeyboard {
    self.thumbnailController.keyboardOnScreen = NO;
    OCMStub([self.thumbnailController getScreenSize]).andReturn(CGSizeMake(100, 100));
    XCTAssertEqual([self.thumbnailController getVisibleHeight], 100);
}

- (void)testCheckThumbnailCorrectPosition {
    OCMStub([self.thumbnailController checkThumbnailOutOfBounds]);
    OCMStub([self.thumbnailController checkThumbnailPartialOutofBounds]);
    [self.thumbnailController checkThumbnailCorrectPosition];
    OCMVerify([self.thumbnailController checkThumbnailOutOfBounds]);
    OCMVerify([self.thumbnailController checkThumbnailPartialOutofBounds]);
}

- (void)testCheckThumbnailOutOfBoundsInvalidPositionTop {
    self.thumbnailController.thumbnailPosition = CGPointMake(10, -30);
    OCMStub([self.thumbnailController canMoveToPoint:CGPointMake(10, -30)]).andReturn(OGAInvalidPositionTop);
    [self.thumbnailController checkThumbnailOutOfBounds];
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.x, 10);
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.y, 0);
}

- (void)testCheckThumbnailOutOfBoundsInvalidPositionBot {
    OCMStub([self.thumbnailController getVisibleHeight]).andReturn(100);
    self.thumbnailController.thumbnailPosition = CGPointMake(10, 83);
    OCMStub([self.thumbnailController canMoveToPoint:CGPointMake(10, 83)]).andReturn(OGAInvalidPositionBottom);
    [self.thumbnailController checkThumbnailOutOfBounds];
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.x, 10);
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.y, 76);
}

- (void)testCheckThumbnailOutOfBoundsInvalidPositionLeft {
    self.thumbnailController.thumbnailPosition = CGPointMake(-30, 50);
    OCMStub([self.thumbnailController canMoveToPoint:CGPointMake(-30, 50)]).andReturn(OGAInvalidPositionLeft);
    [self.thumbnailController checkThumbnailOutOfBounds];
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.x, 0);
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.y, 50);
}

- (void)testCheckThumbnailOutOfBoundsInvalidPositionRight {
    OCMStub([self.thumbnailController getDeviceWidth]).andReturn(100);
    self.thumbnailController.thumbnailPosition = CGPointMake(83, 50);
    OCMStub([self.thumbnailController canMoveToPoint:CGPointMake(83, 50)]).andReturn(OGAInvalidPositionRight);
    [self.thumbnailController checkThumbnailOutOfBounds];
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.x, 76);
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.y, 50);
}

- (void)testCheckThumbnailOutOfBoundsInvalidPositionNoneTopRight {
    OCMStub([self.thumbnailController getDeviceWidth]).andReturn(100);
    OCMStub([self.thumbnailController getVisibleHeight]).andReturn(100);
    self.thumbnailController.thumbnailPosition = CGPointMake(83, -30);
    [self.thumbnailController checkThumbnailOutOfBounds];
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.x, 76);
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.y, 0);
}

- (void)testCheckThumbnailOutOfBoundsInvalidPositionNoneBottomLeft {
    OCMStub([self.thumbnailController getDeviceWidth]).andReturn(100);
    OCMStub([self.thumbnailController getVisibleHeight]).andReturn(100);
    self.thumbnailController.thumbnailPosition = CGPointMake(-30, 83);
    [self.thumbnailController checkThumbnailOutOfBounds];
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.x, 0);
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.y, 76);
}

- (void)testCheckThumbnailOutOfBoundsInvalidPositionNone {
    OCMStub([self.thumbnailController getDeviceWidth]).andReturn(100);
    OCMStub([self.thumbnailController getVisibleHeight]).andReturn(100);
    self.thumbnailController.thumbnailPosition = CGPointMake(83, -30);
    OCMStub([self.thumbnailController canMoveToPoint:CGPointMake(83, -30)]).andReturn(OGAInvalidPositionRight);
    [self.thumbnailController checkThumbnailOutOfBounds];
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.x, 76);
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.y, 0);
}

- (void)testGetPositionStatusForOffScreenInvalidPositionLeft {
    OGAInvalidThumbnailAdPositions invalidPosition = [self.thumbnailController canMoveToPoint:CGPointMake(-30, 50)];
    XCTAssertEqual(invalidPosition, OGAInvalidPositionLeft);
    invalidPosition = [self.thumbnailController canMoveToPoint:CGPointMake(-24, 50)];
    XCTAssertEqual(invalidPosition, OGAInvalidPositionLeft);
    invalidPosition = [self.thumbnailController canMoveToPoint:CGPointMake(-6, 50)];
    XCTAssertNotEqual(invalidPosition, OGAInvalidPositionLeft);
    invalidPosition = [self.thumbnailController canMoveToPoint:CGPointMake(10, 50)];
    XCTAssertNotEqual(invalidPosition, OGAInvalidPositionLeft);
}

- (void)testGetPositionStatusForOffScreenInvalidPositionRight {
    OCMStub([self.thumbnailController getDeviceWidth]).andReturn(100);
    OGAInvalidThumbnailAdPositions invalidPosition = [self.thumbnailController canMoveToPoint:CGPointMake(83, 50)];
    XCTAssertEqual(invalidPosition, OGAInvalidPositionRight);
    invalidPosition = [self.thumbnailController canMoveToPoint:CGPointMake(82, 50)];
    XCTAssertNotEqual(invalidPosition, OGAInvalidPositionRight);
    invalidPosition = [self.thumbnailController canMoveToPoint:CGPointMake(10, 50)];
    XCTAssertNotEqual(invalidPosition, OGAInvalidPositionRight);
}

- (void)testGetPositionStatusForOffScreenInvalidPositionTop {
    OGAInvalidThumbnailAdPositions invalidPosition = [self.thumbnailController canMoveToPoint:CGPointMake(10, -30)];
    XCTAssertEqual(invalidPosition, OGAInvalidPositionTop);
    invalidPosition = [self.thumbnailController canMoveToPoint:CGPointMake(25, -24)];
    XCTAssertEqual(invalidPosition, OGAInvalidPositionTop);
    invalidPosition = [self.thumbnailController canMoveToPoint:CGPointMake(10, -6)];
    XCTAssertNotEqual(invalidPosition, OGAInvalidPositionTop);
    invalidPosition = [self.thumbnailController canMoveToPoint:CGPointMake(10, 10)];
    XCTAssertNotEqual(invalidPosition, OGAInvalidPositionTop);
}

- (void)testGetPositionStatusForOffScreenInvalidInvalidPositionBot {
    OCMStub([self.thumbnailController getVisibleHeight]).andReturn(100);
    OGAInvalidThumbnailAdPositions invalidPosition = [self.thumbnailController canMoveToPoint:CGPointMake(10, 83)];
    XCTAssertEqual(invalidPosition, OGAInvalidPositionBottom);
    invalidPosition = [self.thumbnailController canMoveToPoint:CGPointMake(25, 82)];
    XCTAssertNotEqual(invalidPosition, OGAInvalidPositionBottom);
    invalidPosition = [self.thumbnailController canMoveToPoint:CGPointMake(10, 10)];
    XCTAssertNotEqual(invalidPosition, OGAInvalidPositionBottom);
    invalidPosition = [self.thumbnailController canMoveToPoint:CGPointMake(10, -4)];
    XCTAssertNotEqual(invalidPosition, OGAInvalidPositionBottom);
}

- (void)testGetPositionStatusForOffScreenInvalidInvalidPositionNone {
    OCMStub([self.thumbnailController getVisibleHeight]).andReturn(100);
    OCMStub([self.thumbnailController getDeviceWidth]).andReturn(100);
    OGAInvalidThumbnailAdPositions invalidPosition = [self.thumbnailController canMoveToPoint:CGPointMake(-6, -7)];
    XCTAssertNotEqual(invalidPosition, OGAInvalidPositionNone);
    invalidPosition = [self.thumbnailController canMoveToPoint:CGPointMake(-7, -6)];
    XCTAssertNotEqual(invalidPosition, OGAInvalidPositionNone);
    invalidPosition = [self.thumbnailController canMoveToPoint:CGPointMake(82, 83)];
    XCTAssertNotEqual(invalidPosition, OGAInvalidPositionNone);
    invalidPosition = [self.thumbnailController canMoveToPoint:CGPointMake(83, 82)];
    XCTAssertNotEqual(invalidPosition, OGAInvalidPositionNone);
    invalidPosition = [self.thumbnailController canMoveToPoint:CGPointMake(-6, -6)];
    XCTAssertEqual(invalidPosition, OGAInvalidPositionNone);
    invalidPosition = [self.thumbnailController canMoveToPoint:CGPointMake(82, 82)];
    XCTAssertEqual(invalidPosition, OGAInvalidPositionNone);
}

- (void)testIsMinimumVisibleScreenFalse {
    OCMStub([self.thumbnailController getDeviceHeight]).andReturn(500);
    OCMStub([self.thumbnailController getVisibleHeight]).andReturn(400);
    XCTAssertTrue([self.thumbnailController isMinimumVisibleScreen]);
}

- (void)testIsMinimumVisibleScreenTrue {
    OCMStub([self.thumbnailController getDeviceHeight]).andReturn(500);
    OCMStub([self.thumbnailController getVisibleHeight]).andReturn(100);
    XCTAssertFalse([self.thumbnailController isMinimumVisibleScreen]);
}

- (void)testSendScreenOrientationChange {
    self.thumbnailController.thumbnailPosition = CGPointMake(10, 50);
    [self.thumbnailController sendScreenOrientationChange:CGSizeMake(180, 101)];

    OCMVerify([self.displayer dispatchInformation:[OCMArg checkWithBlock:^BOOL(OGAAdDisplayerUpdateCurrentAppOrientationInformation *value) {
                                  if ([value isKindOfClass:[OGAAdDisplayerUpdateCurrentAppOrientationInformation class]]) {
                                      XCTAssertEqual(value.locked, false);
                                  }
                                  return [value isKindOfClass:[OGAAdDisplayerUpdateCurrentAppOrientationInformation class]];
                              }]]);

    OCMVerify([self.displayer dispatchInformation:[OCMArg checkWithBlock:^BOOL(OGAAdDisplayerUpdateCurrentPositionInformation *value) {
                                  if ([value isKindOfClass:[OGAAdDisplayerUpdateCurrentPositionInformation class]]) {
                                      XCTAssertEqual(value.size.height, 101);
                                      XCTAssertEqual(value.size.width, 180);
                                      XCTAssertEqual(value.position.x, 10);
                                      XCTAssertEqual(value.position.y, 50);
                                  }
                                  return [value isKindOfClass:[OGAAdDisplayerUpdateCurrentPositionInformation class]];
                              }]]);

    OCMReject([self.displayer dispatchInformation:[OCMArg checkWithBlock:^BOOL(OGAAdDisplayerUpdateScreenSizeInformation *value) {
                                  XCTFail("OGAAdDisplayerUpdateScreenSizeInformation should not be called");
                                  return NO;
                              }]]);
}

- (void)testSendScreenOrientationChangeWhileExpanded {
    self.thumbnailController.thumbnailPosition = CGPointMake(10, 50);
    self.window.isExpanded = true;
    OCMStub([self.window isExpanded]).andReturn(YES);
    [self.thumbnailController sendScreenOrientationChange:CGSizeMake(180, 101)];
    OCMVerify([self.displayer dispatchInformation:[OCMArg checkWithBlock:^BOOL(OGAAdDisplayerUpdateScreenSizeInformation *value) {
                                  if ([value isKindOfClass:[OGAAdDisplayerUpdateScreenSizeInformation class]]) {
                                      XCTAssertEqual(value.size.height, 101);
                                      XCTAssertEqual(value.size.width, 180);
                                  }
                                  return [value isKindOfClass:[OGAAdDisplayerUpdateScreenSizeInformation class]];
                              }]]);
    OCMVerify([self.displayer dispatchInformation:[OCMArg checkWithBlock:^BOOL(OGAAdDisplayerUpdateCurrentAppOrientationInformation *value) {
                                  if ([value isKindOfClass:[OGAAdDisplayerUpdateCurrentAppOrientationInformation class]]) {
                                      XCTAssertEqual(value.locked, false);
                                  }
                                  return [value isKindOfClass:[OGAAdDisplayerUpdateCurrentAppOrientationInformation class]];
                              }]]);
    OCMVerify([self.displayer dispatchInformation:[OCMArg checkWithBlock:^BOOL(OGAAdDisplayerUpdateCurrentPositionInformation *value) {
                                  if ([value isKindOfClass:[OGAAdDisplayerUpdateCurrentPositionInformation class]]) {
                                      XCTAssertEqual(value.size.height, 101);
                                      XCTAssertEqual(value.size.width, 180);
                                      XCTAssertEqual(value.position.x, 10);
                                      XCTAssertEqual(value.position.y, 50);
                                  }
                                  return [value isKindOfClass:[OGAAdDisplayerUpdateCurrentPositionInformation class]];
                              }]]);
}

@end

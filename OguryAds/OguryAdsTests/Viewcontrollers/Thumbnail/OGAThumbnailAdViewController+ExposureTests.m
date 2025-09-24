//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGAThumbnailAdViewController+Testing.h"
#import "OGAThumbnailAdViewController+Exposure.h"
#import "OGAAdDisplayerUpdateExposureInformation.h"
#import "OGAAdDisplayerUpdateViewabilityInformation.h"
#import "OGALog.h"

@interface OGAThumbnailAdViewController_ExposureTests : XCTestCase

@property(strong, nonatomic) OGAAd *ad;
@property(strong, nonatomic) id<OGAAdDisplayer> displayer;
@property(strong, nonatomic) OGAAdExposureController *exposerController;
@property(strong, nonatomic) OGAThumbnailAdViewController *thumbnailController;
@property(strong, nonatomic) OGAThumbnailAdWindow *window;
@property(strong, nonatomic) OGAThumbnailAdRestrictionsManager *restrictionManager;
@property(strong, nonatomic) NSNotificationCenter *center;
@property(strong, nonatomic) OGASizeSafeAreaController *safeAreaController;
@property(strong, nonatomic) OGAAdImpressionManager *impressionManager;
@property(strong, nonatomic) NSUserDefaults *userDefaults;
@property(nonatomic, strong) OGADeviceService *deviceService;
@property(nonatomic, strong) OGALog *log;

@end

@implementation OGAThumbnailAdViewController_ExposureTests

- (void)setUp {
    self.ad = OCMClassMock([OGAAd class]);
    self.displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));
    self.exposerController = OCMClassMock([OGAAdExposureController class]);
    self.window = OCMClassMock([OGAThumbnailAdWindow class]);
    self.restrictionManager = OCMClassMock([OGAThumbnailAdRestrictionsManager class]);
    self.center = OCMClassMock([NSNotificationCenter class]);
    self.safeAreaController = OCMClassMock([OGASizeSafeAreaController class]);
    self.impressionManager = OCMClassMock([OGAAdImpressionManager class]);
    self.userDefaults = OCMClassMock([NSUserDefaults class]);
    self.deviceService = OCMClassMock([OGADeviceService class]);
    self.log = OCMClassMock([OGALog class]);

    OCMStub(self.displayer.ad).andReturn(self.ad);

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
}

#pragma mark - Methods

- (void)testSendExposureWithoutAdDisplayEnded {
    OCMStub(self.displayer.mraidDisplayerState).andReturn(OGAAdMraidDisplayerStateLoaded);
    [self.thumbnailController sendAdExposure];
    OCMVerify([self.exposerController computeExposure]);
}

- (void)testSendExposureWithAdDisplayEnded {
    OCMStub(self.displayer.mraidDisplayerState).andReturn(OGAAdMraidDisplayerStateBrowserOpened);
    OCMStub([self.thumbnailController sendAdExposureZero]);
    [self.thumbnailController sendAdExposure];
    OCMVerify([self.thumbnailController sendAdExposureZero]);
}

- (void)testSendAdExposureZero {
    [self.thumbnailController sendAdExposureZero];
    OCMVerify([self.displayer dispatchInformation:[OCMArg checkWithBlock:^BOOL(id value) {
                                  return [value isKindOfClass:[OGAAdDisplayerUpdateExposureInformation class]];
                              }]]);
}

- (void)testPauseAd {
    OCMStub([self.thumbnailController sendAdExposureZero]);
    [self.thumbnailController pauseAd];
    OCMVerify([self.displayer dispatchInformation:[OCMArg checkWithBlock:^BOOL(OGAAdDisplayerUpdateViewabilityInformation *value) {
                                  XCTAssertFalse(value.isViewable);
                                  return [value isKindOfClass:[OGAAdDisplayerUpdateViewabilityInformation class]];
                              }]]);
    OCMVerify([self.thumbnailController sendAdExposureZero]);
    OCMVerify([self.window setHidden:YES]);
}

- (void)testResumeAd {
    OCMStub([self.thumbnailController sendAdExposure]);
    [self.thumbnailController resumeAd];
    OCMVerify([self.displayer dispatchInformation:[OCMArg checkWithBlock:^BOOL(OGAAdDisplayerUpdateViewabilityInformation *value) {
                                  XCTAssertTrue(value.isViewable);
                                  return [value isKindOfClass:[OGAAdDisplayerUpdateViewabilityInformation class]];
                              }]]);
    OCMVerify([self.thumbnailController sendAdExposure]);
    OCMVerify([self.window setHidden:NO]);
}

#pragma mark - OGAAdExposureDelegate

- (void)testExposureDidChange {
    OGAAdExposure *exposure = [[OGAAdExposure alloc] init];

    [self.thumbnailController exposureDidChange:exposure];

    __block OGAAdDisplayerUpdateExposureInformation *info;
    OCMVerify([self.impressionManager sendIfNecessaryAfterExposureChanged:exposure ad:self.ad delegateDispatcher:OCMOCK_ANY displayer:OCMOCK_ANY]);
    OCMVerify([self.displayer dispatchInformation:[OCMArg checkWithBlock:^BOOL(id obj) {
                                  if ([obj isKindOfClass:[OGAAdDisplayerUpdateExposureInformation class]]) {
                                      info = obj;
                                      return YES;
                                  }
                                  return NO;
                              }]]);
    XCTAssertEqual(info.adExposure, exposure);
}

@end

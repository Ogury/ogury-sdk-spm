//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGAAd.h"
#import "OGAFullscreenViewController+Testing.h"
#import "OGAAdDisplayerUpdateMaxSizeInformation.h"
#import "OGAAdDisplayerUpdateScreenSizeInformation.h"
#import "OGAAdDisplayerUpdateCurrentAppOrientationInformation.h"
#import "OGAAdDisplayerUpdateCurrentPositionInformation.h"
#import "OGAAdDisplayerOrientationDelegate.h"
#import "OGAMRAIDAdDisplayer.h"
#import "OGAViewControllerOrientationHelper.h"

@interface OGAAdDisplayerUpdateCurrentPositionInformation ()

@property(nonatomic) CGSize size;
@property(nonatomic) CGPoint position;

@end

@interface OGAViewControllerOrientationHelper ()
- (instancetype)initWithBundle:(NSBundle *)bundle;
@end

@interface OGAFullscreenViewControllerTests : XCTestCase

@property(nonatomic, retain) OGAAd *ad;
@property(nonatomic, retain) UIView *view;
@property(nonatomic, retain) id<OGAAdDisplayer> displayer;
@property(nonatomic, retain) OGAAdExposureController *exposureController;
@property(nonatomic, retain) OGAFullscreenViewController *fullscreenViewController;
@property(nonatomic, strong) OGADeviceService *deviceService;
@property(nonatomic, strong) NSNotificationCenter *notificationCenter;

@end

@interface OGAFullscreenViewController ()
- (void)forceOrientation:(UIInterfaceOrientationMask)orientation orientationHelper:(OGAViewControllerOrientationHelper *)helper;
@end

@implementation OGAFullscreenViewControllerTests

- (void)setUp {
    self.ad = [[OGAAd alloc] init];
    self.view = [[UIView alloc] init];
    self.displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));
    self.exposureController = OCMClassMock([OGAAdExposureController class]);
    self.deviceService = OCMClassMock([OGADeviceService class]);
    self.notificationCenter = OCMClassMock([NSNotificationCenter class]);

    OCMStub(self.displayer.ad).andReturn(self.ad);
    OCMStub(self.displayer.view).andReturn(self.view);

    self.fullscreenViewController = [[OGAFullscreenViewController alloc] initWithExposureController:self.exposureController deviceService:self.deviceService notificationCenter:self.notificationCenter];
    self.fullscreenViewController.displayer = self.displayer;
}

- (void)testInit {
    XCTAssertNotNil([[OGAFullscreenViewController alloc] initWithExposureController:self.exposureController]);
}

- (void)testinitWithExposureControllerAndDeviceService {
    OGAFullscreenViewController *fullscreenViewController = [[OGAFullscreenViewController alloc] initWithExposureController:self.exposureController deviceService:self.deviceService notificationCenter:self.notificationCenter];
    XCTAssertNotNil(fullscreenViewController);
}

- (void)testSupportedInterfaceOrientations {
    self.fullscreenViewController.displayer = self.displayer;
    id classMock = OCMClassMock([OGAAd class]);
    OCMStub(ClassMethod([classMock supportedOrientationForAd:self.ad])).andReturn(UIInterfaceOrientationMaskPortrait);

    XCTAssertEqual(self.fullscreenViewController.supportedInterfaceOrientations, UIInterfaceOrientationMaskPortrait);

    OCMVerify(ClassMethod([classMock supportedOrientationForAd:self.ad]));
}

- (void)testMRAIDDrivenSupportedInterfaceOrientations {
    __weak NSBundle *bundle = OCMClassMock(NSBundle.self);
    NSArray<NSString *> *supportedOrientations = @[ @"UIInterfaceOrientationPortrait", @"UIInterfaceOrientationLandscapeLeft" ];
    OCMStub([bundle objectForInfoDictionaryKey:@"UISupportedInterfaceOrientations"]).andReturn(supportedOrientations);
    OGAViewControllerOrientationHelper *helper = [[OGAViewControllerOrientationHelper alloc] initWithBundle:bundle];

    [self.fullscreenViewController forceOrientation:UIInterfaceOrientationMaskPortrait orientationHelper:helper];
    XCTAssertEqual(self.fullscreenViewController.supportedInterfaceOrientations, UIInterfaceOrientationMaskPortrait);

    [self.fullscreenViewController forceOrientation:UIInterfaceOrientationMaskLandscape orientationHelper:helper];
    XCTAssertEqual(self.fullscreenViewController.supportedInterfaceOrientations, UIInterfaceOrientationMaskLandscape);
}

- (void)testDisplay {
    OguryError *error = nil;
    [self.fullscreenViewController display:self.displayer error:&error];

    XCTAssertNil(error);
    XCTAssertEqual(self.fullscreenViewController.displayer, self.displayer);
    XCTAssertFalse(self.displayer.view.translatesAutoresizingMaskIntoConstraints);
    XCTAssertEqualObjects(self.view.superview, self.fullscreenViewController.view);
    OCMVerify([self.displayer registerForVolumeChange]);
}

- (void)testViewWillTransitionToSize {
    [self.fullscreenViewController sendScreenOrientationChange:CGSizeMake(300, 150)];

    OCMVerify([self.displayer dispatchInformation:[OCMArg checkWithBlock:^BOOL(OGAAdDisplayerUpdateScreenSizeInformation *value) {
                                  if ([value isKindOfClass:[OGAAdDisplayerUpdateScreenSizeInformation class]]) {
                                      XCTAssertEqual(value.size.height, 150);
                                      XCTAssertEqual(value.size.width, 300);
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
                                      XCTAssertEqual(value.size.height, 150);
                                      XCTAssertEqual(value.size.width, 300);
                                      XCTAssertEqual(value.position.x, 0);
                                      XCTAssertEqual(value.position.y, 0);
                                  }
                                  return [value isKindOfClass:[OGAAdDisplayerUpdateCurrentPositionInformation class]];
                              }]]);
    OCMVerify([self.displayer dispatchInformation:[OCMArg checkWithBlock:^BOOL(OGAAdDisplayerUpdateMaxSizeInformation *value) {
                                  if ([value isKindOfClass:[OGAAdDisplayerUpdateCurrentPositionInformation class]]) {
                                      XCTAssertEqual(value.size.height, 150);
                                      XCTAssertEqual(value.size.width, 300);
                                  }
                                  return [value isKindOfClass:[OGAAdDisplayerUpdateCurrentPositionInformation class]];
                              }]]);
}

@end

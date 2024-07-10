//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAThumbnailAdViewController+Testing.h"
#import "OGAThumbnailAdViewController+Position.h"
#import "OGAThumbnailAdViewController+Exposure.h"
#import "OGAMRAIDAdDisplayer.h"
#import <OCMock/OCMock.h>
#import "OGAAdConfiguration.h"
#import "OGAAdContainerConstants.h"
#import "OGALog.h"

@interface OGAThumbnailAdViewController ()

@property(strong, nonatomic) NSNotificationCenter *notificationCenter;
@property(strong, nonatomic) UIPanGestureRecognizer *moveThumbnailAdPanGesture;
@property(nonatomic) CGSize thumbnailSize;
@property(nonatomic) CGPoint thumbnailPosition;
@property(nonatomic) BOOL keyboardOnScreen;
@property(nonatomic) CGRect keyboardRect;
@property(nonatomic, strong) OGADeviceService *deviceService;
@property(nonatomic, strong) OGALog *log;

- (void)moveObject:(UIPanGestureRecognizer *)recognizer;

- (void)addMoveNotification;

- (void)viewControllerListUpdated;

- (void)setupTransparentBackground;

- (void)addAdVisibilityObserver;

- (void)keyboardOffScreen:(NSNotification *)notification;

- (void)keyboardOnScreen:(NSNotification *)notification;

- (void)updateThumbnailAdFrameBasedOnKeyboard;

- (void)setupExposureController:(OGAAdExposureController *)exposureController;

@end

@interface OGAThumbnailAdViewControllerTests : XCTestCase

@property(strong, nonatomic) id<OGAAdDisplayer> displayer;
@property(strong, nonatomic) OGAAdExposureController *exposerController;
@property(strong, nonatomic) OGAThumbnailAdViewController *thumbnailController;
@property(strong, nonatomic) OGAThumbnailAdWindow *window;
@property(strong, nonatomic) OGAThumbnailAdRestrictionsManager *restrictionManager;
@property(strong, nonatomic) NSNotificationCenter *center;
@property(strong, nonatomic) OGAAd *ad;
@property(strong, nonatomic) OGAThumbnailAdResponse *thumbnailAdResponse;
@property(strong, nonatomic) OGAAdConfiguration *config;
@property(strong, nonatomic) OGAProfigDao *profigDao;
@property(strong, nonatomic) OGASizeSafeAreaController *safeAreaController;
@property(nonatomic, strong) OGAAdImpressionManager *impressionManager;
@property(strong, nonatomic) NSUserDefaults *userDefaults;
@property(nonatomic, strong) OGADeviceService *deviceService;
@property(nonatomic, strong) OGALog *log;

@end

@implementation OGAThumbnailAdViewControllerTests

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

    OCMStub([self.thumbnailAdResponse width]).andReturn(@"24");
    OCMStub([self.thumbnailAdResponse height]).andReturn(@"24");
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
    self.thumbnailController.displayer = self.displayer;
    [self.thumbnailController setExposureController:self.exposerController];
    self.thumbnailController.thumbnailSize = CGSizeMake(24, 24);
}

- (void)testInitWithWindow {
    OGAThumbnailAdViewController *tempThumbnailController = [self.thumbnailController initWithWindow:self.window];
    XCTAssertNotNil(tempThumbnailController);
    OCMVerify([self.thumbnailController initWithWindow:[OCMArg any] restrictionManager:[OCMArg any] notificationCenter:[OCMArg any] safeAreaController:[OCMArg any] impressionManager:[OCMArg any] deviceService:[OCMArg any] userDefaults:[OCMArg any] log:[OCMArg any]]);
}

- (void)testMoveObjectNO {
    OCMStub([self.thumbnailAdResponse draggable]).andReturn(@"false");
    UIPanGestureRecognizer *recognizer = OCMClassMock([UIPanGestureRecognizer class]);
    [self.thumbnailController moveObject:recognizer];
}

- (void)testMoveObjectYES {
    OCMStub([self.thumbnailAdResponse draggable]).andReturn(@"true");
    OCMStub(self.window.isDraggable).andReturn(YES);
    UIPanGestureRecognizer *recognizer = OCMClassMock([UIPanGestureRecognizer class]);
    OCMStub([recognizer state]).andReturn(UIGestureRecognizerStateEnded);
    OCMStub([recognizer translationInView:self.window]).andReturn(CGPointMake(10, 0));
    UIView *view = OCMClassMock([UIView class]);
    OCMStub([recognizer view]).andReturn(view);
    OCMStub([self.thumbnailController sendAdExposure]);
    OCMStub([view frame]).andReturn(CGRectMake(20, 10, 24, 24));
    OCMStub([self.thumbnailController canMoveToPoint:CGPointMake(30, 10)]).andReturn(OGAInvalidPositionNone);
    [self.thumbnailController moveObject:recognizer];
    OCMVerify([view setFrame:CGRectMake(30, 10, 24, 24)]);
    OCMVerify([recognizer setTranslation:CGPointZero inView:self.window]);
    OCMVerify([self.thumbnailController sendAdExposure]);
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.x, 30);
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.y, 10);
}

- (void)testViewControllerListUpdatedExpanded {
    OCMStub([self.window isExpanded]).andReturn(YES);
    OCMReject([self.thumbnailController resumeAd]);
    OCMReject([self.thumbnailController pauseAd]);
    [self.thumbnailController viewControllerListUpdated];
}

- (void)testViewControllerListUpdatedNotExpandedRestrict {
    OCMStub([self.window isExpanded]).andReturn(NO);
    OCMReject([self.thumbnailController resumeAd]);
    OCMStub([self.restrictionManager shouldRestrict:[OCMArg any] whiteListBundles:[OCMArg any]]).andReturn(YES);
    [self.thumbnailController viewControllerListUpdated];
    OCMVerify([self.thumbnailController pauseAd]);
}

- (void)testViewControllerListUpdatedNotExpandedNoRestriction {
    OCMStub([self.window isExpanded]).andReturn(NO);
    OCMReject([self.thumbnailController pauseAd]);
    OCMStub([self.restrictionManager shouldRestrict:[OCMArg any] whiteListBundles:[OCMArg any]]).andReturn(NO);
    [self.thumbnailController viewControllerListUpdated];
    OCMVerify([self.thumbnailController resumeAd]);
}

- (void)testSetupTransparentBackground {
    OCMStub([self.thumbnailController.view setBackgroundColor:UIColor.clearColor]);
    [self.thumbnailController setupTransparentBackground];
    OCMVerify([self.thumbnailController.view setBackgroundColor:UIColor.clearColor]);
}

- (void)testCleanUp {
    [self.thumbnailController cleanUp];
    OCMVerify([self.center removeObserver:[OCMArg any]]);
}

- (void)testAddAdVisibilityObserver {
    [self.thumbnailController addAdVisibilityObserver];
    OCMVerify([self.center addObserver:[OCMArg any] selector:[OCMArg anySelector] name:UIKeyboardDidShowNotification object:[OCMArg any]]);
    OCMVerify([self.center addObserver:[OCMArg any] selector:[OCMArg anySelector] name:UIKeyboardWillHideNotification object:[OCMArg any]]);
    OCMVerify([self.center addObserver:[OCMArg any] selector:[OCMArg anySelector] name:OGAViewControllersUpdated object:[OCMArg any]]);
}

- (void)testKeyboardOffScreen {
    [self.thumbnailController keyboardOffScreen:nil];
    XCTAssertFalse(self.thumbnailController.keyboardOnScreen);
    XCTAssertEqual(self.thumbnailController.keyboardRect.origin.x, CGRectZero.origin.x);
    XCTAssertEqual(self.thumbnailController.keyboardRect.origin.y, CGRectZero.origin.y);
    XCTAssertEqual(self.thumbnailController.keyboardRect.size.height, CGRectZero.size.height);
    XCTAssertEqual(self.thumbnailController.keyboardRect.size.width, CGRectZero.size.width);
}

- (void)testKeyboardOnScreen {
    OCMStub([self.thumbnailController updateThumbnailAdFrameBasedOnKeyboard]);
    NSNotification *notification = [NSNotification notificationWithName:@"random" object:nil userInfo:@{UIKeyboardFrameEndUserInfoKey : [NSValue valueWithCGRect:CGRectMake(10, 11, 12, 13)]}];
    [self.thumbnailController keyboardOnScreen:notification];
    XCTAssertTrue(self.thumbnailController.keyboardOnScreen);
    XCTAssertEqual(self.thumbnailController.keyboardRect.origin.x, 10);
    XCTAssertEqual(self.thumbnailController.keyboardRect.origin.y, 11);
    XCTAssertEqual(self.thumbnailController.keyboardRect.size.width, 12);
    XCTAssertEqual(self.thumbnailController.keyboardRect.size.height, 13);
    OCMVerify([self.thumbnailController updateThumbnailAdFrameBasedOnKeyboard]);
}

- (void)testUpdateThumbnailAdFrameBasedOnKeyboardFalse {
    OCMReject([self.thumbnailController checkThumbnailCorrectPosition]);
    OCMReject([self.thumbnailController updateThumbnailAdWithAnimation:NO]);
    OCMStub([self.thumbnailController isMinimumVisibleScreen]).andReturn(false);
    OCMStub([self.thumbnailController checkThumbnailCorrectPosition]);
    OCMStub([self.thumbnailController updateThumbnailAdWithAnimation:NO]);
    [self.thumbnailController updateThumbnailAdFrameBasedOnKeyboard];
}

- (void)testUpdateThumbnailAdFrameBasedOnKeyboardTrue {
    OCMStub([self.thumbnailController isMinimumVisibleScreen]).andReturn(true);
    OCMStub([self.thumbnailController checkThumbnailCorrectPosition]);
    OCMStub([self.thumbnailController updateThumbnailAdWithAnimation:NO]);
    [self.thumbnailController updateThumbnailAdFrameBasedOnKeyboard];
    OCMVerify([self.thumbnailController checkThumbnailCorrectPosition]);
    OCMVerify([self.thumbnailController updateThumbnailAdWithAnimation:NO]);
}

- (void)testViewControllerListUpdatedTrue {
    OCMStub([self.restrictionManager shouldRestrict:[OCMArg any] whiteListBundles:[OCMArg any]]).andReturn(true);
    [self.thumbnailController viewControllerListUpdated];
    OCMVerify([self.restrictionManager shouldRestrict:[OCMArg any] whiteListBundles:[OCMArg any]]);
    OCMVerify([self.thumbnailController pauseAd]);
}

- (void)testViewControllerListUpdatedFalse {
    OCMStub([self.restrictionManager shouldRestrict:[OCMArg any] whiteListBundles:[OCMArg any]]).andReturn(false);
    [self.thumbnailController viewControllerListUpdated];
    OCMVerify([self.restrictionManager shouldRestrict:[OCMArg any] whiteListBundles:[OCMArg any]]);
    OCMVerify([self.thumbnailController resumeAd]);
}

- (void)testSetupExposureControllerNil {
    [self.thumbnailController setupExposureController:nil];
    XCTAssertNil(self.thumbnailController.exposureController);
}

- (void)testSetupExposureControllerNotNil {
    [self.thumbnailController setupExposureController:nil];
    [self.thumbnailController setupExposureController:self.exposerController];
    XCTAssertEqual(self.thumbnailController.exposureController, self.exposerController);
    OCMVerify([self.exposerController setDelegate:[OCMArg any]]);
}

- (void)testAddMoveNotification {
    [self.thumbnailController addMoveNotification];
    XCTAssertNotNil(self.thumbnailController.moveThumbnailAdPanGesture);
}

@end

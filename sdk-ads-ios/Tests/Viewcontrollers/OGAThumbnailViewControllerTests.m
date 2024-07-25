//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAThumbnailAdViewController+Position.h"
#import "OGAThumbnailAdViewController.h"
#import "OGAAdExposureController.h"
#import "OGAAdExposure.h"
#import "OGAAdDisplayerUpdateExposureInformation.h"
#import "OGAAdDisplayerUpdateViewabilityInformation.h"
#import "OGAThumbnailAdWindow.h"
#import "OGAMRAIDAdDisplayer.h"
#import "OCMock.h"
#import "OGAThumbnailAdRestrictionsManager.h"
#import "OGAAudioController.h"
#import "OGAAdDisplayerUpdateScreenSizeInformation.h"
#import "OGAAdDisplayerUpdateCurrentAppOrientationInformation.h"
#import "OGAAdDisplayerUpdateCurrentPositionInformation.h"
#import "OGAAdExposure.h"
#import "OGAAd.h"
#import "OGAThumbnailAdResponse.h"
#import "OGAAdConfiguration.h"
#import "OGAProfigDao.h"

@interface OGAThumbnailAdViewController ()

@property(weak, nonatomic) id<OGAAdDisplayer> _Nullable displayer;
@property(weak, nonatomic) OGAThumbnailAdWindow *_Nullable window;
@property(strong, nonatomic) NSNotificationCenter *notificationCenter;
@property(strong, nonatomic) UIPanGestureRecognizer *moveThumbnailAdPanGesture;
@property(nonatomic) CGSize thumbnailSize;
@property(nonatomic) CGPoint thumbnailPosition;
@property(nonatomic) BOOL keyboardOnScreen;
@property(nonatomic) CGRect keyboardRect;
@property(strong, nonatomic) OGAAdExposureController *exposerController;
@property(strong, nonatomic) OGAAudioController *audioController;
@property(strong, nonatomic) OGAThumbnailAdRestrictionsManager *restrictionManager;

- (instancetype)initWithWindow:(OGAThumbnailAdWindow *)window restrictionManager:(OGAThumbnailAdRestrictionsManager *)restrictionManager notificationCenter:(NSNotificationCenter *)notificationCenter audioController:(OGAAudioController *)audioController profigDao:(OGAProfigDao *)profigDao;

- (void)setupExposureController:(OGAAdExposureController *)exposureController;

- (void)moveObject:(UIPanGestureRecognizer *)recognizer;

- (void)sendExposure;

- (void)addMoveNotification;

@end

@interface OGAThumbnailAdViewControllerTests : XCTestCase

@property(strong, nonatomic) id<OGAAdDisplayer> _Nullable displayer;
@property(strong, nonatomic) OGAAdExposureController *exposerController;
@property(strong, nonatomic) OGAThumbnailAdViewController *thumbnailController;
@property(strong, nonatomic) OGAThumbnailAdWindow *_Nullable window;
@property(strong, nonatomic) OGAThumbnailAdRestrictionsManager *restrictionManager;
@property(strong, nonatomic) NSNotificationCenter *center;
@property(strong, nonatomic) OGAAudioController *audioController;
@property(strong, nonatomic) OGAAd *ad;
@property(strong, nonatomic) OGAThumbnailAdResponse *thumbnailAdResponse;
@property(strong, nonatomic) OGAAdConfiguration *config;
@property(strong, nonatomic) UIPanGestureRecognizer *moveThumbnailAdPanGesture;
@property(strong, nonatomic) OGAProfigDao *profigDao;

@end

@implementation OGAThumbnailAdViewControllerTests

- (void)setUp {
    self.moveThumbnailAdPanGesture = OCMClassMock([OGAMRAIDAdDisplayer class]);
    self.displayer = OCMClassMock([OGAMRAIDAdDisplayer class]);
    self.exposerController = OCMClassMock([OGAAdExposureController class]);
    self.window = OCMClassMock([OGAThumbnailAdWindow class]);
    self.restrictionManager = OCMClassMock([OGAThumbnailAdRestrictionsManager class]);
    self.center = OCMClassMock([NSNotificationCenter class]);
    self.audioController = OCMClassMock([OGAAudioController class]);
    self.ad = OCMClassMock([OGAAd class]);
    self.thumbnailAdResponse = OCMClassMock([OGAThumbnailAdResponse class]);
    self.config = OCMClassMock([OGAAdConfiguration class]);
    self.profigDao = OCMClassMock([OGAProfigDao class]);
    OCMStub([self.thumbnailAdResponse width]).andReturn(@"24");
    OCMStub([self.thumbnailAdResponse height]).andReturn(@"24");
    OCMStub([self.ad thumbnailAdResponse]).andReturn(self.thumbnailAdResponse);
    OCMStub([self.displayer ad]).andReturn(self.ad);
    OCMStub([self.ad adConfiguration]).andReturn(self.config);
    self.thumbnailController = OCMPartialMock([[OGAThumbnailAdViewController alloc] initWithWindow:self.window restrictionManager:self.restrictionManager notificationCenter:self.center audioController:self.audioController profigDao:self.profigDao]);
    self.thumbnailController.displayer = self.displayer;
    [self.audioController setupWithDisplayer:self.displayer];
    [self.thumbnailController setExposerController:self.exposerController];
    self.thumbnailController.thumbnailSize = CGSizeMake(24, 24);
}

- (void)testMoveObjectNO {
    OCMStub([self.thumbnailAdResponse draggable]).andReturn(@"false");
    UIPanGestureRecognizer *recognizer = OCMClassMock([UIPanGestureRecognizer class]);
    [self.thumbnailController moveObject:recognizer];
}

- (void)testMoveObjectYES {
    OCMStub([self.thumbnailAdResponse draggable]).andReturn(@"true");
    UIPanGestureRecognizer *recognizer = OCMClassMock([UIPanGestureRecognizer class]);
    OCMStub([recognizer state]).andReturn(UIGestureRecognizerStateEnded);
    OCMStub([recognizer translationInView:self.window]).andReturn(CGPointMake(10, 0));
    UIView *view = OCMClassMock([UIView class]);
    OCMStub([recognizer view]).andReturn(view);
    OCMStub([self.thumbnailController sendExposure]);
    OCMStub([view frame]).andReturn(CGRectMake(20, 10, 24, 24));
    OCMStub([self.thumbnailController canMoveToPoint:CGPointMake(30, 10)]).andReturn(OGAInvalidPositionNone);
    [self.thumbnailController moveObject:recognizer];
    OCMVerify([view setFrame:CGRectMake(30, 10, 24, 24)]);
    OCMVerify([recognizer setTranslation:CGPointZero inView:self.window]);
    OCMVerify([self.thumbnailController sendExposure]);
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.x, 30);
    XCTAssertEqual(self.thumbnailController.thumbnailPosition.y, 10);
}

@end

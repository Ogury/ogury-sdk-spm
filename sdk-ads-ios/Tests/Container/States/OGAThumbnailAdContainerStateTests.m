//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAThumbnailAdContainerState.h"
#import "OguryAdsError.h"
#import "OGAThumbnailAdWindow.h"
#import "OGAThumbnailAdWindowFactory.h"
#import <OCMock/OCMock.h>
#import "OGAMRAIDAdDisplayer.h"

@interface OGAThumbnailAdContainerStateTests : XCTestCase

@property(nonatomic, strong) OGAThumbnailAdWindow *thumbnailAdWindow;
@property(nonatomic, strong) id<OGAAdDisplayer> _Nullable displayer;
@property(nonatomic, strong) OGAThumbnailAdContainerState *tumbnailAdContainerState;
@property(nonatomic, strong) OGAThumbnailAdWindowFactory *thumbnailWindowFactory;
@property(nonatomic, strong) NSNotificationCenter *notificationCenter;

@end

@interface OGAThumbnailAdContainerState (Testing)

@property(nonatomic, weak, nullable) OGAThumbnailAdWindow *thumbnailAdWindow;

- (OGAThumbnailAdWindow *)createThumbnailAdWindowWithDisplayer:(nonnull id<OGAAdDisplayer>)displayer;

@end

@implementation OGAThumbnailAdContainerStateTests

- (void)setUp {
    self.displayer = OCMClassMock([OGAMRAIDAdDisplayer class]);
    self.thumbnailAdWindow = OCMClassMock([OGAThumbnailAdWindow class]);
    self.thumbnailWindowFactory = OCMPartialMock([[OGAThumbnailAdWindowFactory alloc] init]);
    self.notificationCenter = NSNotificationCenter.defaultCenter;

    self.tumbnailAdContainerState = OCMPartialMock([[OGAThumbnailAdContainerState alloc] initWithThumbnailAdWindowFactory:self.thumbnailWindowFactory]);
}

#pragma mark - Initialization

- (void)testInit {
    OGAThumbnailAdContainerState *state = [[OGAThumbnailAdContainerState alloc] init];
    XCTAssertNotNil(state);
}

#pragma mark - Properties

- (void)testName {
    OGAThumbnailAdContainerState *state = [[OGAThumbnailAdContainerState alloc] init];

    XCTAssertEqualObjects(state.name, @"ThumbnailAd");
}

- (void)testType {
    OGAThumbnailAdContainerState *state = [[OGAThumbnailAdContainerState alloc] init];

    XCTAssertEqual(state.type, OGAAdContainerStateTypeOverlay);
}

- (void)test_ShouldReturnIsExpandedAsFalse {
    OGAThumbnailAdContainerState *state = [[OGAThumbnailAdContainerState alloc] init];

    XCTAssertFalse(state.isExpanded);
}

- (void)testExposureController {
    OGAThumbnailAdViewController *viewController = OCMClassMock([OGAThumbnailAdViewController class]);
    OGAAdExposureController *exposureController = OCMClassMock([OGAAdExposureController class]);
    OCMStub(self.thumbnailAdWindow.thumbnailAdViewController).andReturn(viewController);
    OCMStub(viewController.exposureController).andReturn(exposureController);
    OCMStub(self.tumbnailAdContainerState.thumbnailAdWindow).andReturn(self.thumbnailAdWindow);

    XCTAssertEqual(self.tumbnailAdContainerState.exposureController, exposureController);
}

- (void)testExposureController_returnsNilIfNoWindow {
    OCMStub(self.tumbnailAdContainerState.thumbnailAdWindow).andReturn(nil);

    XCTAssertNil(self.tumbnailAdContainerState.exposureController);
}

#pragma mark - Methods

- (void)testDisplayTrue {
    OCMStub([self.thumbnailWindowFactory createThumbnailAdWindowWithDisplayer:self.displayer]).andReturn(self.thumbnailAdWindow);
    OCMStub([self.thumbnailAdWindow display:self.displayer error:[OCMArg anyObjectRef]]).andReturn(YES);
    OguryError *error;
    XCTAssertTrue([self.tumbnailAdContainerState display:self.displayer error:&error]);
    OCMVerify([self.thumbnailWindowFactory createThumbnailAdWindowWithDisplayer:self.displayer]);
    OCMVerify([self.thumbnailAdWindow display:self.displayer error:[OCMArg anyObjectRef]]);
}

- (void)testDisplayFalse {
    OCMStub([self.thumbnailWindowFactory createThumbnailAdWindowWithDisplayer:self.displayer]).andReturn(self.thumbnailAdWindow);
    OCMStub([self.thumbnailAdWindow display:self.displayer error:[OCMArg anyObjectRef]]).andReturn(NO);
    OguryError *error;
    XCTAssertFalse([self.tumbnailAdContainerState display:self.displayer error:&error]);
    OCMVerify([self.thumbnailWindowFactory createThumbnailAdWindowWithDisplayer:self.displayer]);
    OCMVerify([self.thumbnailAdWindow display:self.displayer error:[OCMArg anyObjectRef]]);
}

- (void)testDisplayNil {
    OCMStub([self.thumbnailWindowFactory createThumbnailAdWindowWithDisplayer:self.displayer]).andReturn(nil);
    OguryError *error;
    XCTAssertFalse([self.tumbnailAdContainerState display:self.displayer error:&error]);
    OCMVerify([self.thumbnailWindowFactory createThumbnailAdWindowWithDisplayer:self.displayer]);
}

- (void)testState {
    XCTAssertEqualObjects([self.tumbnailAdContainerState name], @"ThumbnailAd");
}

- (void)testCleanUp {
    self.tumbnailAdContainerState.thumbnailAdWindow = self.thumbnailAdWindow;
    [self.tumbnailAdContainerState cleanUp];
    OCMVerify([self.thumbnailAdWindow cleanUp]);
    XCTAssertNil(self.tumbnailAdContainerState.thumbnailAdWindow);
}

- (void)testShouldReceiveWindowDidBecomeVisibleNotification {
    [self.tumbnailAdContainerState registerForApplicationLifecycleNotifications];

    [self.notificationCenter postNotificationName:UIWindowDidBecomeVisibleNotification object:nil];

    OCMVerify([self.tumbnailAdContainerState windowDidBecomeVisible:OCMOCK_ANY]);
}

- (void)testShouldReceiveWindowDidBecomeHiddenNotification {
    [self.tumbnailAdContainerState registerForApplicationLifecycleNotifications];

    [self.notificationCenter postNotificationName:UIWindowDidBecomeHiddenNotification object:nil];

    OCMVerify([self.tumbnailAdContainerState windowDidBecomeHidden:OCMOCK_ANY]);
}

- (void)testShouldReceiveWindowDidBecomeKeyNotification {
    [self.tumbnailAdContainerState registerForApplicationLifecycleNotifications];

    [self.notificationCenter postNotificationName:UIWindowDidBecomeKeyNotification object:nil];

    OCMVerify([self.tumbnailAdContainerState windowDidBecomeKey:OCMOCK_ANY]);
}

- (void)testShouldReceiveWindowDidResignKeyNotification {
    [self.tumbnailAdContainerState registerForApplicationLifecycleNotifications];

    [self.notificationCenter postNotificationName:UIWindowDidResignKeyNotification object:nil];

    OCMVerify([self.tumbnailAdContainerState windowDidResignKey:OCMOCK_ANY]);
}

- (void)testShouldReceiveApplicationDidBecomeActiveNotification {
    [self.tumbnailAdContainerState registerForApplicationLifecycleNotifications];

    [self.notificationCenter postNotificationName:UIApplicationDidBecomeActiveNotification object:nil];

    OCMVerify([self.tumbnailAdContainerState applicationDidBecomeActive]);
}

- (void)testShouldReceiveApplicationWillResignActiveNotification {
    [self.tumbnailAdContainerState registerForApplicationLifecycleNotifications];

    [self.notificationCenter postNotificationName:UIApplicationWillResignActiveNotification object:nil];

    OCMVerify([self.tumbnailAdContainerState applicationWillResignActive]);
}

- (void)testShouldReceiveApplicationDidEnterBackgroundNotification {
    [self.tumbnailAdContainerState registerForApplicationLifecycleNotifications];

    [self.notificationCenter postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil];

    OCMVerify([self.tumbnailAdContainerState applicationDidEnterBackground]);
}

- (void)testShouldPerformKeepAliveOnEnteringBackground {
    [self.tumbnailAdContainerState applicationDidEnterBackground];

    OCMVerify([self.tumbnailAdContainerState performKeepAlive]);
}

@end

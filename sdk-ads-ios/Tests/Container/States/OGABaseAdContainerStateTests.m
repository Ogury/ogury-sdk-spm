//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGABaseAdContainerState+Testing.h"
#import <OCMock/OCMock.h>
#import "OGAAdDisplayerSystemCloseInformation.h"
#import "OGAAdDisplayerUpdateExposureInformation.h"
#import "OGALog.h"

@interface OGABaseAdContainerStateTests : XCTestCase

@property(nonatomic, strong) OGABaseAdContainerState *state;
@property(nonatomic, strong) OGAAd *ad;
@property(nonatomic, strong) id<OGAAdDisplayer> displayer;
@property(nonatomic, strong) OGAAdImpressionManager *impressionManager;
@property(nonatomic, strong) OGAAdExposureController *exposureController;
@property(nonatomic, strong) NSNotificationCenter *notificationCenter;
@property(nonatomic, strong) OGALog *log;

@end

@implementation OGABaseAdContainerStateTests

#pragma mark - Methods

- (void)setUp {
    self.log = OCMClassMock([OGALog class]);
    self.ad = [[OGAAd alloc] init];
    self.displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));
    self.impressionManager = OCMClassMock([OGAAdImpressionManager class]);
    self.exposureController = OCMClassMock([OGAAdExposureController class]);

    OCMStub(self.displayer.ad).andReturn(self.ad);

    self.notificationCenter = NSNotificationCenter.defaultCenter;
    OGAProfigDao *profigDao = OCMClassMock([OGAProfigDao class]);
    OGABaseAdContainerState *state = [[OGABaseAdContainerState alloc]
        initWithViewProvider:^UIView *_Nonnull {
            return nil;
        }
        viewControllerProvider:^UIViewController *_Nonnull {
            return nil;
        }
        impressionController:self.impressionManager
        profigDao:profigDao
        notificationCenter:self.notificationCenter
        log:self.log];
    self.state = OCMPartialMock(state);

    OCMStub(self.state.exposureController).andReturn(self.exposureController);
}

#pragma mark - Tests

- (void)test_ShouldReturnIsExpandedAsFalse {
    XCTAssertFalse(self.state.isExpanded);
}

- (void)testShouldRegisterForApplicationLifecyleNotifications {
    id mockNotificationCenter = OCMClassMock([NSNotificationCenter class]);

    OCMStub(self.state.notificationCenter).andReturn(mockNotificationCenter);

    [self.state registerForApplicationLifecycleNotifications];

    OCMVerify([mockNotificationCenter addObserver:OCMOCK_ANY selector:[OCMArg anySelector] name:UIWindowDidBecomeVisibleNotification object:nil]);
    OCMVerify([mockNotificationCenter addObserver:OCMOCK_ANY selector:[OCMArg anySelector] name:UIWindowDidBecomeHiddenNotification object:nil]);
    OCMVerify([mockNotificationCenter addObserver:OCMOCK_ANY selector:[OCMArg anySelector] name:UIWindowDidBecomeKeyNotification object:nil]);
    OCMVerify([mockNotificationCenter addObserver:OCMOCK_ANY selector:[OCMArg anySelector] name:UIWindowDidResignKeyNotification object:nil]);
    OCMVerify([mockNotificationCenter addObserver:OCMOCK_ANY selector:[OCMArg anySelector] name:UIApplicationDidBecomeActiveNotification object:nil]);
    OCMVerify([mockNotificationCenter addObserver:OCMOCK_ANY selector:[OCMArg anySelector] name:UIApplicationWillResignActiveNotification object:nil]);
    OCMVerify([mockNotificationCenter addObserver:OCMOCK_ANY selector:[OCMArg anySelector] name:UIApplicationDidEnterBackgroundNotification object:nil]);
}

- (void)testShouldReceiveWindowDidBecomeVisibleNotification {
    [self.state registerForApplicationLifecycleNotifications];

    [self.notificationCenter postNotificationName:UIWindowDidBecomeVisibleNotification object:nil];

    OCMVerify([self.state windowDidBecomeVisible:OCMOCK_ANY]);
}

- (void)testShouldReceiveWindowDidBecomeHiddenNotification {
    [self.state registerForApplicationLifecycleNotifications];

    [self.notificationCenter postNotificationName:UIWindowDidBecomeHiddenNotification object:nil];

    OCMVerify([self.state windowDidBecomeHidden:OCMOCK_ANY]);
}

- (void)testShouldReceiveWindowDidBecomeKeyNotification {
    [self.state registerForApplicationLifecycleNotifications];

    [self.notificationCenter postNotificationName:UIWindowDidBecomeKeyNotification object:nil];

    OCMVerify([self.state windowDidBecomeKey:OCMOCK_ANY]);
}

- (void)testShouldReceiveWindowDidResignKeyNotification {
    [self.state registerForApplicationLifecycleNotifications];

    [self.notificationCenter postNotificationName:UIWindowDidResignKeyNotification object:nil];

    OCMVerify([self.state windowDidResignKey:OCMOCK_ANY]);
}

- (void)testShouldReceiveApplicationDidBecomeActiveNotification {
    OCMStub(self.state.exposureController).andReturn(nil);

    [self.state registerForApplicationLifecycleNotifications];

    [self.notificationCenter postNotificationName:UIApplicationDidBecomeActiveNotification object:nil];

    OCMVerify([self.state applicationDidBecomeActive]);
    OCMVerify([self.exposureController computeExposure]);
}

- (void)testShouldReceiveApplicationWillResignActiveNotification {
    [self.state registerForApplicationLifecycleNotifications];

    [self.notificationCenter postNotificationName:UIApplicationWillResignActiveNotification object:nil];

    OCMVerify([self.state applicationWillResignActive]);
}

- (void)testShouldReceiveApplicationDidEnterBackgroundNotification {
    [self.state registerForApplicationLifecycleNotifications];

    [self.notificationCenter postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil];

    OCMVerify([self.state applicationDidEnterBackground]);
#warning FIXME Test zero exposure is properly sent
}

- (void)testShouldNotPerformKeepAliveIfNotEnabledAndShouldKeepAdWhenLeavingApp {
    id<OGAAdDisplayer> displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));
    OCMStub([displayer hasKeepAlive]).andReturn(YES);

    id<OGAAdDisplayerDelegate> displayerDelegate = OCMProtocolMock(@protocol(OGAAdDisplayerDelegate));
    displayer.delegate = displayerDelegate;
    [self.state overrideDisplayer:displayer];

    OGAProfigDao *profigDao = OCMClassMock([OGAProfigDao class]);
    OGAProfigFullResponse *profigFullResponse = OCMClassMock([OGAProfigFullResponse class]);
    OCMStub(profigFullResponse.closeAdWhenLeavingApp).andReturn(@(NO));
    OCMStub(profigDao.profigFullResponse).andReturn(profigFullResponse);
    OCMStub(self.state.profigDao).andReturn(profigDao);

    [self.state performKeepAlive];

    OCMReject([displayer dispatchInformation:[OCMArg isKindOfClass:OGAAdDisplayerSystemCloseInformation.self]]);
    OCMReject([displayerDelegate performAction:OCMOCK_ANY error:[OCMArg anyObjectRef]]);
}

- (void)testShouldNotPerformKeepAliveIfNotEnabledAndShouldNotKeepAdWhenLeavingApp {
    id<OGAAdDisplayer> displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));
    OCMStub([displayer hasKeepAlive]).andReturn(NO);

    id<OGAAdDisplayerDelegate> displayerDelegate = OCMProtocolMock(@protocol(OGAAdDisplayerDelegate));
    displayer.delegate = displayerDelegate;
    [self.state overrideDisplayer:displayer];

    OGAProfigDao *profigDao = OCMClassMock([OGAProfigDao class]);
    OGAProfigFullResponse *profigFullResponse = OCMClassMock([OGAProfigFullResponse class]);
    OCMStub([profigFullResponse closeAdWhenLeavingApp]).andReturn(NO);
    OCMStub([profigDao profigFullResponse]).andReturn(profigFullResponse);
    OCMStub(self.state.profigDao).andReturn(profigDao);

    [self.state performKeepAlive];

    OCMReject([displayer dispatchInformation:[OCMArg isKindOfClass:OGAAdDisplayerSystemCloseInformation.self]]);
    OCMReject([displayerDelegate performAction:OCMOCK_ANY error:[OCMArg anyObjectRef]]);
}

- (void)testShouldPerformKeepAliveIfNotEnabledAndShouldNotKeepAdWhenLeavingApp {
    id<OGAAdDisplayer> displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));
    OCMStub(displayer.hasKeepAlive).andReturn(NO);

    id<OGAAdDisplayerDelegate> displayerDelegate = OCMProtocolMock(@protocol(OGAAdDisplayerDelegate));
    displayer.delegate = displayerDelegate;
    [self.state overrideDisplayer:displayer];

    OGAProfigDao *profigDao = OCMClassMock([OGAProfigDao class]);
    OGAProfigFullResponse *profigFullResponse = OCMClassMock([OGAProfigFullResponse class]);
    OCMStub(profigFullResponse.closeAdWhenLeavingApp).andReturn(YES);
    OCMStub(profigDao.profigFullResponse).andReturn(profigFullResponse);
    OCMStub(self.state.profigDao).andReturn(profigDao);

    [self.state performKeepAlive];

    OCMVerify([displayer dispatchInformation:[OCMArg isKindOfClass:OGAAdDisplayerSystemCloseInformation.self]]);
}

- (void)testUpdateViewablityIfNecessaryFullExposure {
    self.state.currentViewabilityStatus = NO;
    [self.state updateViewablityIfNecessary:[OGAAdExposure fullExposure]];
    XCTAssertTrue(self.state.currentViewabilityStatus);
}

- (void)testUpdateViewablityIfNecessaryZeroExposure {
    self.state.currentViewabilityStatus = YES;
    [self.state updateViewablityIfNecessary:[OGAAdExposure zeroExposure]];
    XCTAssertFalse(self.state.currentViewabilityStatus);
}

- (void)testUpdateViewablityIfNecessaryFullExposureAlready {
    self.state.currentViewabilityStatus = YES;
    [self.state updateViewablityIfNecessary:[OGAAdExposure fullExposure]];
    XCTAssertTrue(self.state.currentViewabilityStatus);
}

- (void)testUpdateViewablityIfNecessaryZeroExposureAlready {
    self.state.currentViewabilityStatus = NO;
    [self.state updateViewablityIfNecessary:[OGAAdExposure zeroExposure]];
    XCTAssertFalse(self.state.currentViewabilityStatus);
}

#pragma mark - OGAAdExposureDelegate

- (void)testExposureDidChange {
    [self.state overrideDisplayer:self.displayer];

    OGAAdExposure *exposure = [[OGAAdExposure alloc] init];

    [self.state exposureDidChange:exposure];

    __block OGAAdDisplayerUpdateExposureInformation *information;

    OCMVerify([self.displayer dispatchInformation:[OCMArg checkWithBlock:^BOOL(id obj) {
                                  if ([obj isKindOfClass:[OGAAdDisplayerUpdateExposureInformation class]]) {
                                      information = obj;
                                      return YES;
                                  }
                                  return NO;
                              }]]);

    XCTAssertEqual(information.adExposure, exposure);

    OCMVerify([self.impressionManager sendIfNecessaryAfterExposureChanged:OCMOCK_ANY ad:OCMOCK_ANY delegateDispatcher:OCMOCK_ANY]);
}

- (void)testExposureDidChange_doNothingIfNoDisplayer {
    OGAAdExposure *exposure = [[OGAAdExposure alloc] init];

    OCMReject([self.impressionManager sendIfNecessaryAfterExposureChanged:OCMOCK_ANY ad:OCMOCK_ANY delegateDispatcher:OCMOCK_ANY]);

    [self.state exposureDidChange:exposure];
}

@end

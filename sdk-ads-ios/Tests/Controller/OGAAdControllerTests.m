//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGAAdController+Testing.h"
#import "OGAAdConfiguration.h"
#import "OGAInitialAdContainerState.h"
#import "OGAShowAdAction.h"
#import "OGACloseAdAction.h"
#import "OGAForceCloseAdAction.h"
#import "OGATrackEvent.h"
#import "OGALog.h"

NSString *const OGAAdControllerTestsAdvertId = @"advert-id";
double const OGAAdControllerTestsDefaultExpirationTime = 14400;

@interface OGAAdControllerTests : XCTestCase

@property(nonatomic, strong) OGAAd *ad;

@property(nonatomic, strong) OGAAdConfiguration *configuration;
@property(nonatomic, strong) id<OGAAdDisplayer> displayer;
@property(nonatomic, strong) OGAAdContainer *container;
@property(nonatomic, strong) OGAAdManager *adManager;
@property(nonatomic, strong) OGAMetricsService *metricsService;
@property(nonatomic, strong) OGAAdExpirationManager *adExpirationManager;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;

@property(nonatomic, strong) OGAAdController *controller;

@end

@implementation OGAAdControllerTests

- (void)setUp {
    self.ad = OCMClassMock([OGAAd class]);
    self.configuration = OCMClassMock([OGAAdConfiguration class]);
    self.displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));
    self.container = OCMClassMock([OGAAdContainer class]);
    self.metricsService = OCMClassMock([OGAMetricsService class]);
    self.adExpirationManager = OCMClassMock([OGAAdExpirationManager class]);
    self.log = OCMClassMock([OGALog class]);
    self.monitoringDispatcher = OCMClassMock([OGAMonitoringDispatcher class]);

    OGAAdController *controller = [[OGAAdController alloc] initWithAd:self.ad
                                                        configuration:self.configuration
                                                            displayer:self.displayer
                                                            container:self.container
                                                       metricsService:self.metricsService
                                                  adExpirationManager:self.adExpirationManager
                                                 monitoringDispatcher:self.monitoringDispatcher
                                                                  log:self.log];
    self.controller = OCMPartialMock(controller);
}

#pragma mark - Properties

- (void)testIsLoaded {
    OCMStub([self.displayer isLoaded]).andReturn(YES);
    XCTAssertTrue([self.controller isLoaded]);
    OCMVerify([self.displayer isLoaded]);
}

- (void)testShouldReturnFalseIfNotExpired {
    self.controller.expirationContext.expirationTime = @(OGAAdControllerTestsDefaultExpirationTime);

    NSDate *createdAt = [NSCalendar.currentCalendar dateByAddingUnit:NSCalendarUnitHour value:-3 toDate:[NSDate date] options:NSCalendarMatchStrictly];

    OCMStub(self.controller.createdAt).andReturn(createdAt);

    XCTAssertFalse(self.controller.isExpired);
    OCMReject([self.adExpirationManager sendExpirationTrackerEventForAd:self.ad]);
}

- (void)testShouldReturnTrueIfExpiredAndSendExpiredTrackerEvent {
    self.controller.expirationContext.expirationTime = @(OGAAdControllerTestsDefaultExpirationTime);

    NSDate *createdAt = [NSCalendar.currentCalendar dateByAddingUnit:NSCalendarUnitHour value:-4 toDate:[NSDate date] options:NSCalendarMatchStrictly];

    OCMStub(self.controller.createdAt).andReturn(createdAt);

    XCTAssertTrue(self.controller.isExpired);
    OCMVerify([self.adExpirationManager sendExpirationTrackerEventForAd:self.ad]);
}

- (void)testIsLoaded_displayerNotLoaded {
    OCMStub([self.displayer isLoaded]).andReturn(NO);
    XCTAssertFalse([self.controller isLoaded]);
}

- (void)testIsClosed_notInClosedState {
    OCMStub(self.container.stateType).andReturn(OGAAdContainerStateTypeInitial);
    XCTAssertFalse(self.controller.isClosed);
}

- (void)testIsDisplayed {
    OCMStub(self.container.stateType).andReturn(OGAAdContainerStateTypeInline);
    XCTAssertTrue(self.controller.isDisplayed);
}

- (void)testIsDisplayed_inClosedState {
    OCMStub(self.container.stateType).andReturn(OGAAdContainerStateTypeClosed);
    XCTAssertFalse(self.controller.isDisplayed);
}

- (void)testIsDisplayed_inInitialState {
    OCMStub(self.container.stateType).andReturn(OGAAdContainerStateTypeInitial);
    XCTAssertFalse(self.controller.isDisplayed);
}

- (void)testIsOverlay {
    OCMStub(self.container.stateType).andReturn(OGAAdContainerStateTypeOverlay);
    XCTAssertTrue(self.controller.isOverlay);
}

- (void)testIsOverlay_notInOverlayState {
    OCMStub(self.container.stateType).andReturn(OGAAdContainerStateTypeInline);
    XCTAssertFalse(self.controller.isOverlay);
}

- (void)testIsClosed {
    OCMStub(self.container.stateType).andReturn(OGAAdContainerStateTypeClosed);
    XCTAssertTrue(self.controller.isClosed);
}

#pragma mark - Methods

- (void)testShow {
    OCMStub([self.controller performAction:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(YES);

    OguryError *error = nil;
    XCTAssertTrue([self.controller show:&error]);
    OCMVerify([self.controller performAction:[OCMArg checkWithBlock:^BOOL(id obj) {
                                   return [obj isKindOfClass:[OGAShowAdAction class]];
                               }]
                                       error:[OCMArg anyObjectRef]]);
}

- (void)testShow_performActionFails {
    OguryError *performActionError = OCMClassMock([OguryError class]);
    OCMStub([self.controller performAction:[OCMArg any] error:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
                                                                                         OguryError *__autoreleasing *errorPointer = nil;
                                                                                         [invocation getArgument:&errorPointer atIndex:3];
                                                                                         *errorPointer = performActionError;
                                                                                     })
        .andReturn(NO);

    OguryError *error = nil;
    XCTAssertFalse([self.controller show:&error]);
    XCTAssertEqual(error, performActionError);
}

- (void)testSendLoadedTracker {
    OCMStub(self.ad.identifier).andReturn(OGAAdControllerTestsAdvertId);

    [self.controller sendLoadedTracker];

    __block OGATrackEvent *trackEvent;
    OCMVerify([self.metricsService sendEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                       if ([obj isKindOfClass:[OGATrackEvent class]]) {
                                           trackEvent = obj;
                                           return YES;
                                       }
                                       return NO;
                                   }]]);
    XCTAssertEqualObjects(trackEvent.advertId, OGAAdControllerTestsAdvertId);
}

- (void)testForceClose {
    OCMStub([self.controller performAction:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(YES);

    [self.controller forceClose];

    OCMVerify([self.controller performAction:[OCMArg checkWithBlock:^BOOL(id obj) {
                                   return [obj isKindOfClass:[OGAForceCloseAdAction class]];
                               }]
                                       error:[OCMArg anyObjectRef]]);
}

#pragma mark - OGAAdDisplayerDelegate

- (void)testDidLoad {
    self.controller.delegate = OCMProtocolMock(@protocol(OGAAdControllerDelegate));
    OCMStub([self.controller sendLoadedTracker]);

    [self.controller didLoad];

    OCMVerify([self.controller sendLoadedTracker]);
    OCMVerify([self.controller.delegate controller:self.controller didLoadAd:self.ad]);
}

- (void)testDidUnLoad {
    self.controller.delegate = OCMProtocolMock(@protocol(OGAAdControllerDelegate));

    [self.controller didUnLoadFrom:UnloadOriginFormat];

    OCMVerify([self.controller.delegate controller:self.controller didUnLoadAd:self.ad origin:UnloadOriginFormat]);
}

- (void)testPerformAction {
    id<OGAAdAction> action = OCMProtocolMock(@protocol(OGAAdAction));
    OCMStub([action performAction:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(YES);

    OguryError *error = nil;
    XCTAssertTrue([self.controller performAction:action error:&error]);
    OCMVerify([action performAction:self.container error:[OCMArg anyObjectRef]]);
}

- (void)testPerformAction_failedToPerformAction {
    id<OGAAdAction> action = OCMProtocolMock(@protocol(OGAAdAction));
    OguryError *actionError = OCMClassMock([OguryError class]);
    OCMStub([action performAction:[OCMArg any] error:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
                                                                                OguryError *__autoreleasing *errorPointer = nil;
                                                                                [invocation getArgument:&errorPointer atIndex:3];
                                                                                *errorPointer = actionError;
                                                                            })
        .andReturn(NO);

    OguryError *error = nil;
    XCTAssertFalse([self.controller performAction:action error:&error]);
    XCTAssertEqual(error, actionError);
    OCMVerify([action performAction:self.container error:[OCMArg anyObjectRef]]);
}

- (void)testPerformAction_keepNextAdForCloseAction {
    self.controller.delegate = OCMProtocolMock(@protocol(OGAAdControllerDelegate));
    OGANextAd *nextAd = OCMClassMock([OGANextAd class]);
    OGACloseAdAction *action = OCMPartialMock([[OGACloseAdAction alloc] initWithNextAd:nextAd]);
    OCMStub([action performAction:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(YES);

    [self.controller performAction:action error:nil];

    XCTAssertEqual(self.controller.nextAd, nextAd);
}

- (void)testPerformAction_nextAdFalseForForceCloseAction {
    self.controller.delegate = OCMProtocolMock(@protocol(OGAAdControllerDelegate));
    self.controller.nextAd = OCMClassMock([OGANextAd class]);
    OGAForceCloseAdAction *action = OCMPartialMock([[OGAForceCloseAdAction alloc] init]);
    OCMStub([action performAction:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(YES);

    [self.controller performAction:action error:nil];

    XCTAssertNotNil(self.controller.nextAd.showNextAd);
    XCTAssertFalse(self.controller.nextAd.showNextAd.boolValue);
}

#pragma mark - OGAAdContainerDelegate

- (void)testDidTransitionToFrom_dispatchDidClose {
    OGANextAd *nextAd = OCMClassMock([OGANextAd class]);
    id<OGAAdControllerDelegate> delegate = OCMProtocolMock(@protocol(OGAAdControllerDelegate));
    self.controller.nextAd = nextAd;
    self.controller.delegate = delegate;
    id<OGAAdContainerState> fromState = OCMProtocolMock(@protocol(OGAAdContainerState));
    id<OGAAdContainerState> toState = OCMProtocolMock(@protocol(OGAAdContainerState));
    OCMStub(toState.type).andReturn(OGAAdContainerStateTypeClosed);

    [self.controller didTransitionTo:toState from:fromState action:@"test"];

    OCMVerify([delegate controller:[OCMArg any] didCloseWithNextAd:nextAd]);
}

- (void)testDidTransitionToFrom_fromInitialToOverlay_dispatchDidOpenOverlay {
    OGANextAd *nextAd = OCMClassMock([OGANextAd class]);
    id<OGAAdControllerDelegate> delegate = OCMProtocolMock(@protocol(OGAAdControllerDelegate));
    self.controller.nextAd = nextAd;
    self.controller.delegate = delegate;
    id<OGAAdContainerState> fromState = OCMProtocolMock(@protocol(OGAAdContainerState));
    OCMStub(fromState.type).andReturn(OGAAdContainerStateTypeInitial);
    id<OGAAdContainerState> toState = OCMProtocolMock(@protocol(OGAAdContainerState));
    OCMStub(toState.type).andReturn(OGAAdContainerStateTypeOverlay);

    [self.controller didTransitionTo:toState from:fromState action:@"test"];

    OCMVerify([delegate controller:[OCMArg any] didOpenOverlayForAd:self.ad]);
}

- (void)testDidTransitionToFrom_fromInlineToOverlay_dispatchDidOpenOverlay {
    OGANextAd *nextAd = OCMClassMock([OGANextAd class]);
    id<OGAAdControllerDelegate> delegate = OCMProtocolMock(@protocol(OGAAdControllerDelegate));
    self.controller.nextAd = nextAd;
    self.controller.delegate = delegate;
    id<OGAAdContainerState> fromState = OCMProtocolMock(@protocol(OGAAdContainerState));
    OCMStub(fromState.type).andReturn(OGAAdContainerStateTypeInline);
    id<OGAAdContainerState> toState = OCMProtocolMock(@protocol(OGAAdContainerState));
    OCMStub(toState.type).andReturn(OGAAdContainerStateTypeOverlay);

    [self.controller didTransitionTo:toState from:fromState action:@"test"];

    OCMVerify([delegate controller:[OCMArg any] didOpenOverlayForAd:[OCMArg any]]);
}

- (void)testDidTransitionToFrom_fromOverlayToClosed_didCloseDispatchedBeforeDidCloseOverlay {
    id delegate = OCMProtocolMock(@protocol(OGAAdControllerDelegate));
    OGANextAd *nextAd = OCMClassMock([OGANextAd class]);
    self.controller.nextAd = nextAd;
    self.controller.delegate = delegate;
    id<OGAAdContainerState> fromState = OCMProtocolMock(@protocol(OGAAdContainerState));
    OCMStub(fromState.type).andReturn(OGAAdContainerStateTypeOverlay);
    id<OGAAdContainerState> toState = OCMProtocolMock(@protocol(OGAAdContainerState));
    OCMStub(toState.type).andReturn(OGAAdContainerStateTypeClosed);

    [delegate setExpectationOrderMatters:YES];
    OCMExpect([delegate controller:[OCMArg any] didCloseWithNextAd:nextAd]);
    OCMExpect([delegate controller:[OCMArg any] didCloseOverlayForAd:self.ad]);

    [self.controller didTransitionTo:toState from:fromState action:@"test"];

    OCMVerifyAll(delegate);
}

- (void)testDidTransitionToFrom_fromOverlayToOverlay_doNotDispatch {
    OGANextAd *nextAd = OCMClassMock([OGANextAd class]);
    id<OGAAdControllerDelegate> delegate = OCMProtocolMock(@protocol(OGAAdControllerDelegate));
    self.controller.nextAd = nextAd;
    self.controller.delegate = delegate;
    id<OGAAdContainerState> fromState = OCMProtocolMock(@protocol(OGAAdContainerState));
    OCMStub(fromState.type).andReturn(OGAAdContainerStateTypeOverlay);
    id<OGAAdContainerState> toState = OCMProtocolMock(@protocol(OGAAdContainerState));
    OCMStub(toState.type).andReturn(OGAAdContainerStateTypeOverlay);

    OCMReject([delegate controller:[OCMArg any] didOpenOverlayForAd:[OCMArg any]]);
    OCMReject([delegate controller:[OCMArg any] didCloseOverlayForAd:[OCMArg any]]);

    [self.controller didTransitionTo:toState from:fromState action:@"test"];
}

- (void)testDidTransitionToFrom_fromNonOverlayToNonOverlay_doNotDispatch {
    OGANextAd *nextAd = OCMClassMock([OGANextAd class]);
    id<OGAAdControllerDelegate> delegate = OCMProtocolMock(@protocol(OGAAdControllerDelegate));
    self.controller.nextAd = nextAd;
    self.controller.delegate = delegate;
    id<OGAAdContainerState> fromState = OCMProtocolMock(@protocol(OGAAdContainerState));
    OCMStub(fromState.type).andReturn(OGAAdContainerStateTypeInline);
    id<OGAAdContainerState> toState = OCMProtocolMock(@protocol(OGAAdContainerState));
    OCMStub(toState.type).andReturn(OGAAdContainerStateTypeClosed);

    OCMReject([delegate controller:[OCMArg any] didOpenOverlayForAd:[OCMArg any]]);
    OCMReject([delegate controller:[OCMArg any] didCloseOverlayForAd:[OCMArg any]]);

    [self.controller didTransitionTo:toState from:fromState action:@"test"];
}

- (void)testDidTransitionToFrom_fromNonExpandedStateToExpandedState {
    OGANextAd *nextAd = OCMClassMock([OGANextAd class]);
    id<OGAAdControllerDelegate> delegate = OCMProtocolMock(@protocol(OGAAdControllerDelegate));
    self.controller.nextAd = nextAd;
    self.controller.delegate = delegate;
    id<OGAAdContainerState> fromState = OCMProtocolMock(@protocol(OGAAdContainerState));
    OCMStub(fromState.type).andReturn(OGAAdContainerStateTypeInline);
    id<OGAAdContainerState> toState = OCMProtocolMock(@protocol(OGAAdContainerState));
    OCMStub(toState.isExpanded).andReturn(YES);
    OCMStub(toState.type).andReturn(OGAAdContainerStateTypeOverlay);

    [self.controller didTransitionTo:toState from:fromState action:@"test"];

    XCTAssertTrue(self.controller.isExpanded);

    OCMVerify([delegate controller:[OCMArg any] didOpenOverlayForAd:[OCMArg any]]);
}

- (void)testDidTransitionToFrom_fromExpandedStateToNonExpandedState {
    OGANextAd *nextAd = OCMClassMock([OGANextAd class]);
    id<OGAAdControllerDelegate> delegate = OCMProtocolMock(@protocol(OGAAdControllerDelegate));
    self.controller.nextAd = nextAd;
    self.controller.delegate = delegate;
    id<OGAAdContainerState> fromState = OCMProtocolMock(@protocol(OGAAdContainerState));
    OCMStub(fromState.type).andReturn(OGAAdContainerStateTypeInline);
    id<OGAAdContainerState> toState = OCMProtocolMock(@protocol(OGAAdContainerState));
    OCMStub(toState.isExpanded).andReturn(NO);
    OCMStub(toState.type).andReturn(OGAAdContainerStateTypeOverlay);

    [self.controller didTransitionTo:toState from:fromState action:@"test"];

    XCTAssertFalse(self.controller.isExpanded);

    OCMVerify([delegate controller:[OCMArg any] didOpenOverlayForAd:[OCMArg any]]);
}

@end

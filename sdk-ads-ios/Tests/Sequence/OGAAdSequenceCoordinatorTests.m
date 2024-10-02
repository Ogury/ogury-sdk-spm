//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "OGAAdController.h"
#import "OGAAdSequenceCoordinator+Testing.h"
#import "OGAAdSequenceRetainController.h"
#import "OGAMonitoringDispatcher.h"
#import "OGAAdController+Testing.h"
#import "OguryAdError+Internal.h"

NSString *const OGAAdSequenceCoordinatorTestsAdIdOne = @"one";
NSString *const OGAAdSequenceCoordinatorTestsAdIdTwo = @"two";
NSString *const OGAAdSequenceCoordinatorTestsAdIdThree = @"three";

@interface OGAAdSequenceCoordinatorTests : XCTestCase

@property(nonatomic, strong) OGAAdSequence *sequence;
@property(nonatomic, strong) OGAAdConfiguration *configuration;
@property(nonatomic, strong) OGADelegateDispatcher *delegateDispatcher;
@property(nonatomic, strong) OGAAdSequenceRetainController *sequenceRetainController;
@property(nonatomic, strong) id<OGAAdSequenceCoordinatorDelegate> delegate;

@property(nonatomic, strong) OGAAdController *controllerOne;
@property(nonatomic, strong) OGAAdController *controllerTwo;
@property(nonatomic, strong) OGAAdController *controllerThree;
@property(nonatomic, strong) OGAAd *adOne;
@property(nonatomic, strong) OGAAd *adTwo;
@property(nonatomic, strong) OGAAd *adThree;
@property(nonatomic, strong) OGAAdSequenceCoordinator *sequenceCoordinator;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) OGAMetricsService *metricService;

@end

NSString *const OGAAdSequenceCoordinatorTestsNextAdId = @"next-ad-id";

@implementation OGAAdSequenceCoordinatorTests

#pragma mark - Methods

- (void)setUp {
    self.delegateDispatcher = OCMClassMock([OGADelegateDispatcher class]);
    self.metricService = OCMClassMock([OGAMetricsService class]);
    self.configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub(self.configuration.delegateDispatcher).andReturn(self.delegateDispatcher);
    self.sequence = OCMPartialMock([[OGAAdSequence alloc] initWithAdConfiguration:self.configuration]);
    self.sequenceRetainController = OCMClassMock([OGAAdSequenceRetainController class]);
    self.delegate = OCMProtocolMock(@protocol(OGAAdSequenceCoordinatorDelegate));

    self.adOne = [[OGAAd alloc] init];
    self.adOne.identifier = OGAAdSequenceCoordinatorTestsAdIdOne;
    self.adTwo = [[OGAAd alloc] init];
    self.adTwo.identifier = OGAAdSequenceCoordinatorTestsAdIdTwo;
    self.adThree = [[OGAAd alloc] init];
    self.adThree.identifier = OGAAdSequenceCoordinatorTestsAdIdThree;

    self.controllerOne = OCMClassMock([OGAAdController class]);
    self.controllerTwo = OCMClassMock([OGAAdController class]);
    self.controllerThree = OCMClassMock([OGAAdController class]);
    self.monitoringDispatcher = OCMClassMock([OGAMonitoringDispatcher class]);
    OCMStub(self.controllerOne.ad).andReturn(self.adOne);
    OCMStub(self.controllerTwo.ad).andReturn(self.adTwo);
    OCMStub(self.controllerThree.ad).andReturn(self.adThree);

    OGAAdSequenceCoordinator *sequenceCoordinator = [[OGAAdSequenceCoordinator alloc] initWithSequence:self.sequence
                                                                                         adControllers:@[ self.controllerOne,
                                                                                                          self.controllerTwo,
                                                                                                          self.controllerThree ]
                                                                              sequenceRetainController:self.sequenceRetainController
                                                                                  monitoringDispatcher:self.monitoringDispatcher
                                                                                         metricService:self.metricService];
    sequenceCoordinator.delegate = self.delegate;
    self.sequenceCoordinator = OCMPartialMock(sequenceCoordinator);
}

#pragma mark - Properties

- (void)testIsLoaded {
    OCMStub(self.controllerOne.isLoaded).andReturn(YES);
    OCMStub(self.controllerTwo.isLoaded).andReturn(YES);
    OCMStub(self.controllerThree.isLoaded).andReturn(YES);

    XCTAssertTrue(self.sequenceCoordinator.isLoaded);
}

- (void)testIsLoadedOneIsClosed {
    OCMStub(self.controllerOne.isLoaded).andReturn(YES);
    OCMStub(self.controllerTwo.isLoaded).andReturn(YES);
    OCMStub(self.controllerThree.isClosed).andReturn(YES);

    XCTAssertTrue(self.sequenceCoordinator.isLoaded);
}

- (void)testIsLoadedOneAllClosed {
    OCMStub(self.controllerOne.isClosed).andReturn(YES);
    OCMStub(self.controllerTwo.isClosed).andReturn(YES);
    OCMStub(self.controllerThree.isClosed).andReturn(YES);

    XCTAssertFalse(self.sequenceCoordinator.isLoaded);
}

- (void)testIsLoaded_atLeastOneControllerNotLoaded {
    OCMStub(self.controllerOne.isLoaded).andReturn(YES);
    OCMStub(self.controllerTwo.isLoaded).andReturn(NO);
    OCMStub(self.controllerThree.isLoaded).andReturn(YES);

    XCTAssertFalse(self.sequenceCoordinator.isLoaded);
}

- (void)testIsDisplayed {
    OCMStub(self.controllerOne.isDisplayed).andReturn(NO);
    OCMStub(self.controllerTwo.isDisplayed).andReturn(YES);
    OCMStub(self.controllerThree.isDisplayed).andReturn(NO);

    XCTAssertTrue(self.sequenceCoordinator.isDisplayed);
}

- (void)testIsDisplayed_allControllersNotDisplayed {
    OCMStub(self.controllerOne.isDisplayed).andReturn(NO);
    OCMStub(self.controllerTwo.isDisplayed).andReturn(NO);
    OCMStub(self.controllerThree.isDisplayed).andReturn(NO);

    XCTAssertFalse(self.sequenceCoordinator.isDisplayed);
}

- (void)testIsOverlay {
    OCMStub(self.controllerOne.isOverlay).andReturn(NO);
    OCMStub(self.controllerTwo.isOverlay).andReturn(YES);
    OCMStub(self.controllerThree.isOverlay).andReturn(NO);

    XCTAssertTrue(self.sequenceCoordinator.isOverlay);
}

- (void)testIsOverlay_noControllerInOverlay {
    OCMStub(self.controllerOne.isOverlay).andReturn(NO);
    OCMStub(self.controllerTwo.isOverlay).andReturn(NO);
    OCMStub(self.controllerThree.isOverlay).andReturn(NO);

    XCTAssertFalse(self.sequenceCoordinator.isOverlay);
}

- (void)testIsClosed {
    OCMStub(self.controllerOne.isClosed).andReturn(YES);
    OCMStub(self.controllerTwo.isClosed).andReturn(YES);
    OCMStub(self.controllerThree.isClosed).andReturn(YES);

    XCTAssertTrue(self.sequenceCoordinator.isClosed);
}

- (void)testIsClosed_anyControllerNotClosed {
    OCMStub(self.controllerOne.isClosed).andReturn(YES);
    OCMStub(self.controllerTwo.isClosed).andReturn(NO);
    OCMStub(self.controllerThree.isClosed).andReturn(YES);

    XCTAssertFalse(self.sequenceCoordinator.isClosed);
}

#pragma mark - Methods

- (void)testShow {
    OCMStub(self.controllerOne.isLoaded).andReturn(YES);
    OCMStub(self.controllerTwo.isLoaded).andReturn(YES);
    OCMStub(self.controllerThree.isLoaded).andReturn(YES);
    OCMStub([self.controllerOne show:[OCMArg anyObjectRef]]).andReturn(YES);

    OguryError *error = nil;
    XCTAssertTrue([self.sequenceCoordinator show:&error]);
    XCTAssertNil(error);
    OCMVerify([self.controllerOne show:[OCMArg anyObjectRef]]);
}

- (void)testShow_notLoaded {
    OCMStub(self.controllerOne.isLoaded).andReturn(YES);
    OCMStub(self.controllerTwo.isLoaded).andReturn(NO);
    OCMStub(self.controllerThree.isLoaded).andReturn(YES);

    OguryError *error = nil;
    XCTAssertFalse([self.sequenceCoordinator show:&error]);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, OguryShowErrorCodeNoAdLoaded);
}

- (void)testShow_alreadyDisplayed {
    OCMStub(self.controllerOne.isLoaded).andReturn(YES);
    OCMStub(self.controllerTwo.isLoaded).andReturn(YES);
    OCMStub(self.controllerThree.isLoaded).andReturn(YES);
    OCMStub(self.controllerOne.isDisplayed).andReturn(YES);

    OguryError *error = nil;
    XCTAssertFalse([self.sequenceCoordinator show:&error]);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, OguryShowErrorCodeAnotherAdAlreadyDisplayed);
}

- (void)testShow_alreadyClosed {
    OCMStub(self.controllerOne.isLoaded).andReturn(YES);
    OCMStub(self.controllerTwo.isLoaded).andReturn(YES);
    OCMStub(self.controllerThree.isLoaded).andReturn(YES);
    OCMStub(self.controllerOne.isClosed).andReturn(YES);
    OCMStub(self.controllerTwo.isClosed).andReturn(YES);
    OCMStub(self.controllerThree.isClosed).andReturn(YES);

    OguryError *error = nil;
    XCTAssertFalse([self.sequenceCoordinator show:&error]);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, OguryShowErrorCodeNoAdLoaded);
}

- (void)testShow_controllerShowFailed {
    OCMStub(self.controllerOne.isLoaded).andReturn(YES);
    OCMStub(self.controllerTwo.isLoaded).andReturn(YES);
    OCMStub(self.controllerThree.isLoaded).andReturn(YES);
    OguryError *controllerError = OCMClassMock([OguryAdError class]);
    OCMStub([self.controllerOne show:[OCMArg anyObjectRef]])
        .andDo(^(NSInvocation *invocation) {
            OguryError *__autoreleasing *errorPointer = nil;
            [invocation getArgument:&errorPointer atIndex:2];
            *errorPointer = controllerError;
        })
        .andReturn(NO);

    OguryError *error = nil;
    XCTAssertFalse([self.sequenceCoordinator show:&error]);
    XCTAssertEqual(error, controllerError);
}

- (void)testClose {
    OCMStub(self.controllerTwo.isClosed).andReturn(YES);
    OCMReject([self.controllerTwo forceClose]);
    self.sequenceCoordinator.delegate = OCMProtocolMock(@protocol(OGAAdSequenceCoordinatorDelegate));

    [self.sequenceCoordinator close];

    OCMVerify([self.controllerOne forceClose]);
    OCMVerify([self.controllerThree forceClose]);
    XCTAssertEqual(self.sequenceCoordinator.sequence.status, OGAAdSequenceStatusClosed);
    OCMVerify([self.sequenceCoordinator.delegate didCloseSequence:self.sequenceCoordinator.sequence]);
}

- (void)testDispatchClosedIfNecessary_doNothingIfAnyControllerIsNotClosed {
    OCMStub(self.sequenceCoordinator.isClosed).andReturn(NO);
    OCMReject([self.delegateDispatcher closed]);
    OCMReject([self.delegate didCloseSequence:[OCMArg any]]);

    [self.sequenceCoordinator dispatchClosedIfNecessary];
}

- (void)testDispatchClosedIfNecessary_dispatchIfAllControllersAreClosed {
    OCMStub(self.sequenceCoordinator.isClosed).andReturn(YES);

    [self.sequenceCoordinator dispatchClosedIfNecessary];

    XCTAssertTrue(self.sequenceCoordinator.closedDispatched);
    OCMVerify([self.delegateDispatcher closed]);
    OCMVerify([self.delegate didCloseSequence:self.sequence]);
}

- (void)testDispatchClosedIfNecessary_onlyDispatchOnce {
    self.sequenceCoordinator.closedDispatched = YES;
    OCMReject([self.delegateDispatcher closed]);

    [self.sequenceCoordinator dispatchClosedIfNecessary];
}

- (void)testControllerForNextAd_noNextAdId {
    OGANextAd *nextAd = [OGANextAd nextAdTrue];
    OCMStub([self.sequenceCoordinator nextAvailableControllerFromClosingController:[OCMArg any]]).andReturn(self.controllerThree);
    OCMReject([self.sequenceCoordinator findAvailableControllerWithAdId:[OCMArg any]]);

    OGAAdController *nextController = [self.sequenceCoordinator controllerForNextAd:nextAd closingController:self.controllerTwo];

    XCTAssertEqual(nextController, self.controllerThree);
    OCMVerify([self.sequenceCoordinator nextAvailableControllerFromClosingController:self.controllerTwo]);
}

- (void)testControllerForNextAd_withNextAdId {
    OGANextAd *nextAd = [OGANextAd nextAdTrue];
    nextAd.nextAdId = OGAAdSequenceCoordinatorTestsNextAdId;
    OCMStub([self.sequenceCoordinator findAvailableControllerWithAdId:[OCMArg any]]).andReturn(self.controllerThree);
    OCMReject([self.sequenceCoordinator nextAvailableControllerFromClosingController:[OCMArg any]]);

    OGAAdController *nextController = [self.sequenceCoordinator controllerForNextAd:nextAd closingController:self.controllerTwo];

    XCTAssertEqual(nextController, self.controllerThree);
    OCMVerify([self.sequenceCoordinator findAvailableControllerWithAdId:OGAAdSequenceCoordinatorTestsNextAdId]);
}

- (void)testNextNonClosedController {
    XCTAssertEqual([self.sequenceCoordinator nextAvailableControllerFromClosingController:self.controllerOne], self.controllerTwo);
    XCTAssertEqual([self.sequenceCoordinator nextAvailableControllerFromClosingController:self.controllerTwo], self.controllerThree);
    XCTAssertNil([self.sequenceCoordinator nextAvailableControllerFromClosingController:self.controllerThree]);
}

- (void)testNextNonClosedController_skipClosedController {
    OCMStub(self.controllerTwo.isClosed).andReturn(YES);
    XCTAssertEqual([self.sequenceCoordinator nextAvailableControllerFromClosingController:self.controllerOne], self.controllerThree);
}

- (void)testNextNonClosedController_returnNilIfAllNextControllersAreClosed {
    OCMStub(self.controllerTwo.isClosed).andReturn(YES);
    OCMStub(self.controllerThree.isClosed).andReturn(YES);
    XCTAssertNil([self.sequenceCoordinator nextAvailableControllerFromClosingController:self.controllerOne]);
}

- (void)testNextNonClosedController_returnNilForUnknownController {
    OGAAdController *unknownController = OCMClassMock([OGAAdController class]);
    XCTAssertNil([self.sequenceCoordinator nextAvailableControllerFromClosingController:unknownController]);
}

- (void)testFindFirstNonClosedControllerWithAdId_findFirstIfTwoWithSameId {
    self.adThree.identifier = OGAAdSequenceCoordinatorTestsAdIdTwo;
    XCTAssertEqualObjects([self.sequenceCoordinator findAvailableControllerWithAdId:OGAAdSequenceCoordinatorTestsAdIdTwo], self.controllerTwo);
}

- (void)testFindFirstNonClosedControllerWithAdId_skipControllerIfClosed {
    OCMStub(self.controllerTwo.isClosed).andReturn(YES);
    self.adThree.identifier = OGAAdSequenceCoordinatorTestsAdIdTwo;
    XCTAssertEqualObjects([self.sequenceCoordinator findAvailableControllerWithAdId:OGAAdSequenceCoordinatorTestsAdIdTwo], self.controllerThree);
}

- (void)testFindFirstNonClosedControllerWithAdId_returnNilIfNotPresent {
    XCTAssertNil([self.sequenceCoordinator findAvailableControllerWithAdId:@"four"]);
}

- (void)testFindFirstNonClosedControllerWithAdId_returnNilIfAllClosed {
    OCMStub(self.controllerTwo.isClosed).andReturn(YES);
    XCTAssertNil([self.sequenceCoordinator findAvailableControllerWithAdId:OGAAdSequenceCoordinatorTestsAdIdTwo]);
}

#pragma mark - OGAAdControllerDelegate

- (void)testControllerDidLoadAd {
    OCMStub(self.sequenceCoordinator.isLoaded).andReturn(YES);

    [self.sequenceCoordinator controller:self.controllerOne didLoadAd:OCMClassMock([OGAAd class])];

    XCTAssertEqual(self.sequence.status, OGAAdSequenceStatusLoaded);
    OCMVerify([self.delegateDispatcher loaded]);
}

- (void)testControllerDidLoadAd_notAllControllersLoaded {
    OCMStub(self.sequenceCoordinator.isLoaded).andReturn(NO);
    OCMReject([self.delegateDispatcher loaded]);

    XCTAssertNotEqual(self.sequence.status, OGAAdSequenceStatusLoaded);
    [self.sequenceCoordinator controller:self.controllerOne didLoadAd:OCMClassMock([OGAAd class])];
}

- (void)testControllerDidOpenOverlayForAd {
    [self.sequenceCoordinator controller:self.controllerOne didOpenOverlayForAd:self.adOne];

    OCMVerify([self.sequenceRetainController retainSequence:self.sequence fromController:self.controllerOne]);
}

- (void)testControllerDidCloseOverlayForAd {
    [self.sequenceCoordinator controller:self.controllerOne didCloseOverlayForAd:self.adOne];

    OCMVerify([self.sequenceRetainController releaseSequence:self.sequence fromController:self.controllerOne]);
}

- (void)testControllerDidCloseWithNextAd_closeIfNoNextAd {
    [self.sequenceCoordinator controller:self.controllerOne didCloseWithNextAd:[OGANextAd nextAdFalse]];

    OCMVerify([self.sequenceCoordinator dispatchClosedIfNecessary]);
    OCMVerify([self.sequenceCoordinator close]);
}

- (void)testControllerDidCloseWithNextAd_closeIfCannotFindNextAd {
    OCMStub([self.sequenceCoordinator controllerForNextAd:[OCMArg any] closingController:[OCMArg any]]).andReturn(nil);

    [self.sequenceCoordinator controller:self.controllerOne didCloseWithNextAd:[OGANextAd nextAdTrue]];

    OCMVerify([self.sequenceCoordinator dispatchClosedIfNecessary]);
    OCMVerify([self.sequenceCoordinator close]);
}

- (void)testControllerDidCloseWithNextAd_displayNextAd {
    OGANextAd *nextAd = [OGANextAd nextAdTrue];
    OCMStub([self.sequenceCoordinator controllerForNextAd:[OCMArg any] closingController:[OCMArg any]]).andReturn(self.controllerTwo);
    OCMStub([self.controllerTwo show:[OCMArg anyObjectRef]]).andReturn(YES);
    OCMReject([self.sequenceCoordinator close]);

    [self.sequenceCoordinator controller:self.controllerOne didCloseWithNextAd:nextAd];

    OCMVerify([self.sequenceCoordinator controllerForNextAd:nextAd closingController:self.controllerOne]);
    OCMVerify([self.controllerTwo show:[OCMArg anyObjectRef]]);
}

- (void)testControllerDidCloseWithNextAd_failedToDisplayNextAd {
    OGANextAd *nextAd = [OGANextAd nextAdTrue];
    OCMStub([self.sequenceCoordinator controllerForNextAd:[OCMArg any] closingController:[OCMArg any]]).andReturn(self.controllerTwo);
    OguryError *showError = OCMClassMock([OguryAdError class]);
    OCMStub([self.controllerTwo show:[OCMArg anyObjectRef]])
        .andDo(^(NSInvocation *invocation) {
            OguryError *__autoreleasing *errorPointer = nil;
            [invocation getArgument:&errorPointer atIndex:2];
            *errorPointer = showError;
        })
        .andReturn(NO);

    [self.sequenceCoordinator controller:self.controllerOne didCloseWithNextAd:nextAd];

    OCMVerify([self.sequenceCoordinator close]);
    OCMVerify([self.delegateDispatcher failedWithError:showError]);
}

- (void)testContinueLoadingSequenceWithclosingControllerTrue {
    OCMStub(self.controllerOne.isLoaded).andReturn(YES);
    OCMStub(self.controllerTwo.isLoaded).andReturn(YES);
    OCMStub(self.controllerThree.isLoaded).andReturn(YES);
    XCTAssertTrue([self.sequenceCoordinator continueLoadingSequenceWithClosingController:self.controllerOne]);
}

- (void)testContinueLoadingSequenceWithclosingControllerFalse {
    OCMStub(self.controllerOne.isLoaded).andReturn(YES);
    OCMStub(self.controllerTwo.isLoaded).andReturn(YES);
    OCMStub(self.controllerThree.isLoaded).andReturn(YES);
    XCTAssertTrue([self.sequenceCoordinator continueLoadingSequenceWithClosingController:self.controllerOne]);
}

- (void)testWhenFirstAdHasExpiredThenMonitoringEventIsDispatched {
    OCMStub(self.controllerOne.isLoaded).andReturn(YES);
    OCMStub(self.controllerTwo.isLoaded).andReturn(YES);
    OCMStub(self.controllerThree.isLoaded).andReturn(YES);
    OCMStub(self.controllerOne.isExpired).andReturn(YES);
    OCMStub(self.controllerTwo.isExpired).andReturn(NO);
    OCMStub(self.controllerThree.isExpired).andReturn(NO);
    NSError *error;
    [self.sequenceCoordinator show:&error];
    XCTAssertNil(error);
}

- (void)testWhenTwoAdsHaveExpiredThenMonitoringEventIsDispatched {
    OCMStub(self.controllerOne.isLoaded).andReturn(YES);
    OCMStub(self.controllerTwo.isLoaded).andReturn(YES);
    OCMStub(self.controllerThree.isLoaded).andReturn(YES);
    OCMStub(self.controllerOne.isExpired).andReturn(YES);
    OCMStub(self.controllerTwo.isExpired).andReturn(YES);
    OCMStub(self.controllerThree.isExpired).andReturn(NO);
    NSError *error;
    [self.sequenceCoordinator show:&error];
    XCTAssertNil(error);
}

- (void)testWhenAllAdsHaveExpiredThenMonitoringEventDispatchedAndErrorIsReturned {
    OCMStub(self.controllerOne.isLoaded).andReturn(YES);
    OCMStub(self.controllerTwo.isLoaded).andReturn(YES);
    OCMStub(self.controllerThree.isLoaded).andReturn(YES);
    OCMStub(self.controllerOne.isExpired).andReturn(YES);
    OCMStub(self.controllerTwo.isExpired).andReturn(YES);
    OCMStub(self.controllerThree.isExpired).andReturn(YES);
    NSError *error;
    [self.sequenceCoordinator show:&error];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, OguryShowErrorCodeAdExpired);
}

- (void)testWhenDidUnloadIsCalledAndAdIsNotLoadedYetThenPreCachingErrorIsMonitored {
    OCMStub(self.controllerOne.isLoaded).andReturn(NO);
    OCMStub(self.controllerOne.isClosed).andReturn(NO);
    OCMStub([self.sequenceCoordinator isNotLoadedYet]).andReturn(YES);
    [self.sequenceCoordinator controller:self.controllerOne didUnLoadAd:self.adOne origin:UnloadOriginFormat];
    OCMVerify([self.monitoringDispatcher sendLoadErrorEventPrecacheFail:OGAMonitoringPrecacheErrorUnload adConfiguration:[OCMArg any]]);
}

- (void)testWhenUnloadBackgroundIsReceivedThenNoError2009IsDispatched {
    OCMStub(self.sequence.status).andReturn(OGAAdSequenceStatusLoaded);
    OCMStub([self.sequenceCoordinator continueLoadingSequenceWithClosingController:[OCMArg any]]).andReturn(NO);
    [self.sequenceCoordinator controller:self.controllerOne didUnLoadWithNextAd:[OCMArg any]];
    OCMReject([self.sequence.configuration.delegateDispatcher failedWithError:[OguryAdError noAdLoaded]]);
}

@end

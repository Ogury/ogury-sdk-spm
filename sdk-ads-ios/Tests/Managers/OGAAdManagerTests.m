//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <OguryCore/OguryEventEntry.h>
#import <XCTest/XCTest.h>
#import "OGAAdConfiguration.h"
#import "OGAAdManager+Testing.h"
#import "OGAAdSequence.h"
#import "OGAAdSequenceCoordinator.h"
#import "OGAConfigurationUtils+Profig.h"
#import "OGAIsKilledChecker.h"
#import "OGAKeyboardObserver.h"
#import "OGAPreCacheEvent.h"
#import "OGAProfigDao.h"
#import "OGAProfigFullResponse.h"
#import "OGAAdEnabledChecker.h"
#import "OGAAdController.h"

@interface OGAAdManagerTests : XCTestCase

@property(nonatomic, strong) OGAProfigManager *profigManager;
@property(nonatomic, strong) OGAAdSyncManager *adSyncManager;
@property(nonatomic, strong) OGAAdContentPreCacheManager *adContentPreCacheManager;
@property(nonatomic, strong) OGAAdControllerFactory *adControllerFactory;
@property(nonatomic, strong) OGAMetricsService *metricsService;

@property(nonatomic, strong) OGAAssetKeyManager *assetKeyManager;
@property(nonatomic, strong) OGAInternetConnectionChecker *internetConnectionChecker;
@property(nonatomic, strong) OGAIsLoadedChecker *isLoadedChecker;
@property(nonatomic, strong) OGAIsExpiredChecker *isExpiredChecker;
@property(nonatomic, strong) OGAIsKilledChecker *isKilledChecker;
@property(nonatomic, strong) OGAKeyboardObserver *keyboardObserver;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) OGAAdEnabledChecker *adEnabledChecker;

@property(nonatomic, strong) OGAAdManager *adManager;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) OGAPersistentEventBus *persistentEventBus;

@end

@interface OGAAdManager ()
- (OGAProfigDao *)profigDao;
@end

@implementation OGAAdManagerTests

- (void)setUp {
    self.profigManager = OCMClassMock([OGAProfigManager class]);
    self.adSyncManager = OCMClassMock([OGAAdSyncManager class]);
    self.log = OCMClassMock([OGALog class]);
    self.adContentPreCacheManager = OCMClassMock([OGAAdContentPreCacheManager class]);
    self.adControllerFactory = OCMClassMock([OGAAdControllerFactory class]);
    self.metricsService = OCMClassMock([OGAMetricsService class]);

    self.assetKeyManager = OCMClassMock([OGAAssetKeyManager class]);
    self.internetConnectionChecker = OCMClassMock([OGAInternetConnectionChecker class]);
    self.isLoadedChecker = OCMClassMock([OGAIsLoadedChecker class]);
    self.isKilledChecker = OCMClassMock([OGAIsKilledChecker class]);
    self.isExpiredChecker = OCMClassMock(OGAIsExpiredChecker.self);
    self.keyboardObserver = OCMClassMock([OGAKeyboardObserver class]);
    self.persistentEventBus = OCMClassMock([OGAPersistentEventBus class]);
    self.monitoringDispatcher = OCMClassMock([OGAMonitoringDispatcher class]);
    self.persistentEventBus = OCMClassMock([OGAPersistentEventBus class]);
    self.adEnabledChecker = OCMClassMock([OGAAdEnabledChecker class]);

    self.adManager = OCMPartialMock([[OGAAdManager alloc] initWithProfigManager:self.profigManager
                                                                  adSyncManager:self.adSyncManager
                                                       adContentPreCacheManager:self.adContentPreCacheManager
                                                            adControllerFactory:self.adControllerFactory
                                                                 metricsService:self.metricsService
                                                                assetKeyManager:self.assetKeyManager
                                                      internetConnectionChecker:self.internetConnectionChecker
                                                               keyboardObserver:self.keyboardObserver
                                                                isLoadedChecker:self.isLoadedChecker
                                                                isKilledChecker:self.isKilledChecker
                                                               isExpiredChecker:self.isExpiredChecker
                                                           monitoringDispatcher:self.monitoringDispatcher
                                                               adEnabledChecker:self.adEnabledChecker
                                                                            log:self.log]);
    self.adManager.persistentEventBus = self.persistentEventBus;
    [self.adManager registerToPersistentEventBus];
    OCMStub(self.assetKeyManager.assetKey).andReturn(@"");
    OCMStub(self.assetKeyManager.sdkState).andReturn(OgurySDKStateReady);
}

#pragma mark - Methods

- (void)testLoadAdConfigurationPreviousSequence_loadIfNoPreviousSequence {
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OGAAdConfiguration *copiedConfiguration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([configuration copy]).andReturn(copiedConfiguration);

    OGAAdSequence *sequence = [self.adManager loadAdConfiguration:configuration previousSequence:nil];

    XCTAssertEqual(sequence.configuration, copiedConfiguration);
    OCMVerify([self.adManager loadAdConfiguration:copiedConfiguration]);
}

- (void)testLoadAdConfigurationPreviousSequence_doNothingIfPreviousSequenceLoading {
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    OCMStub(sequence.status).andReturn(OGAAdSequenceStatusLoading);
    OCMReject([self.adManager loadAdConfiguration:[OCMArg any]]);

    XCTAssertEqual([self.adManager loadAdConfiguration:OCMClassMock([OGAAdConfiguration class]) previousSequence:sequence], sequence);
}

- (void)testLoadAdConfigurationPreviousSequence_notifyDelegateIfPreviousSequenceLoaded {
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    OCMStub(sequence.status).andReturn(OGAAdSequenceStatusLoaded);
    OCMStub([self.adManager isLoaded:sequence]).andReturn(YES);
    OCMReject([self.adManager loadAdConfiguration:[OCMArg any]]);

    XCTAssertEqual([self.adManager loadAdConfiguration:OCMClassMock([OGAAdConfiguration class]) previousSequence:sequence], sequence);
}

- (void)testLoadAdConfigurationPreviousSequence_loadIfPreviousSequenceShown {
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OGAAdConfiguration *copiedConfiguration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([configuration copy]).andReturn(copiedConfiguration);
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    OCMStub(sequence.status).andReturn(OGAAdSequenceStatusShown);

    XCTAssertNotEqual([self.adManager loadAdConfiguration:configuration previousSequence:sequence], sequence);
    OCMVerify([self.adManager loadAdConfiguration:copiedConfiguration]);
}

- (void)testLoadAdConfiguration_notWaitingForConsent {
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([self.adManager checkConditions:[OCMArg any] sequence:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(YES);
    OCMStub([self.adManager continueLoadAdSequenceAfterConsentEventReceived:[OCMArg any]]);
    OCMStub([self.persistentEventBus shouldContinueLoadingAdWith:[OCMArg any]]).andReturn(YES);
    OCMStub(self.assetKeyManager.sdkState).andReturn(OgurySDKStateReady);
    OCMStub(self.assetKeyManager.assetKey).andReturn(@"xxx");
    OCMStub([self.internetConnectionChecker checkForSequence:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(YES);

    OGAAdSequence *sequence = [self.adManager loadAdConfiguration:configuration];

    OCMVerify([self.adManager continueLoadAdSequenceAfterConsentEventReceived:sequence]);
    XCTAssertNotNil(sequence);
    XCTAssertEqual(sequence.status, OGAAdSequenceStatusLoading);
    XCTAssertEqual(sequence.configuration, configuration);
}

- (void)testLoadAdConfiguration_waitingForConsent {
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    self.adManager.lastConsentEventEntry = [[OguryEventEntry alloc] initWithEvent:@"CM-status" andMessage:@"LOADING"];
    OCMStub([self.adManager checkConditions:[OCMArg any] sequence:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(YES);
    OCMReject([self.adManager continueLoadAdSequenceAfterConsentEventReceived:[OCMArg any]]);
    OCMStub(self.assetKeyManager.sdkState).andReturn(OgurySDKStateReady);
    OCMStub(self.assetKeyManager.assetKey).andReturn(@"xxx");
    OCMStub([self.internetConnectionChecker checkForSequence:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(YES);

    OGAAdSequence *sequence = [self.adManager loadAdConfiguration:configuration];

    XCTAssertNotNil(sequence);
    XCTAssertEqual(sequence.status, OGAAdSequenceStatusLoading);
    XCTAssertEqual(sequence.configuration, configuration);
    XCTAssertEqual(self.adManager.sequencesWaitingForConsent.count, 1);
    XCTAssertEqual([[self.adManager.sequencesWaitingForConsent objectEnumerator] nextObject], sequence);
}

- (void)testContinueLoadAdSequenceAfterConsentEventReceived {
    // Test method
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    __block ProfigCompletionBlock profigCompletionBlock;
    OCMExpect([self.profigManager syncProfigWithCompletion:[OCMArg checkWithBlock:^BOOL(id obj) {
                                      profigCompletionBlock = obj;
                                      return YES;
                                  }]];);
    OCMStub([self.adManager continueLoadAdSequenceAfterProfigSynced:[OCMArg any]]);

    [self.adManager continueLoadAdSequenceAfterConsentEventReceived:sequence];

    OCMVerify([self.profigManager syncProfigWithCompletion:[OCMArg any]]);

    // Test callback
    OGAProfigFullResponse *profigFullResponse = OCMClassMock([OGAProfigFullResponse class]);
    OCMStub(profigFullResponse.isAdsEnabled).andReturn(YES);

    profigCompletionBlock(profigFullResponse, nil);

    OCMVerify([self.adManager continueLoadAdSequenceAfterProfigSynced:[OCMArg any]]);
}

- (void)testContinueLoadAdSequenceAfterConsentEventReceived_adDisabled {
    // Test method
    OGAAdSequence *sequence = [[OGAAdSequence alloc] initWithAdConfiguration:OCMClassMock([OGAAdConfiguration class])];
    __block ProfigCompletionBlock profigCompletionBlock;
    OCMExpect([self.profigManager syncProfigWithCompletion:[OCMArg checkWithBlock:^BOOL(id obj) {
                                      profigCompletionBlock = obj;
                                      return YES;
                                  }]];);
    OCMReject([self.adManager continueLoadAdSequenceAfterProfigSynced:[OCMArg any]]);

    [self.adManager continueLoadAdSequenceAfterConsentEventReceived:sequence];

    // Test callback
    OGAProfigFullResponse *profigFullResponse = OCMClassMock([OGAProfigFullResponse class]);
    OCMStub(profigFullResponse.isAdsEnabled).andReturn(NO);

    profigCompletionBlock(profigFullResponse, nil);

    XCTAssertEqual(sequence.status, OGAAdSequenceStatusError);
    OCMVerify([self.adManager dispatchError:[OguryError createAdDisabledError] sequence:sequence]);
}

- (void)testContinueLoadAdSequenceAfterConsentEventReceived_profigError {
    OGAAdSequence *sequence = [[OGAAdSequence alloc] initWithAdConfiguration:OCMClassMock([OGAAdConfiguration class])];
    __block ProfigCompletionBlock profigCompletionBlock;
    OCMExpect([self.profigManager syncProfigWithCompletion:[OCMArg checkWithBlock:^BOOL(id obj) {
                                      profigCompletionBlock = obj;
                                      return YES;
                                  }]];);
    OCMReject([self.adManager continueLoadAdSequenceAfterProfigSynced:[OCMArg any]]);

    [self.adManager continueLoadAdSequenceAfterConsentEventReceived:sequence];

    // Test callback
    profigCompletionBlock(nil, [OGAConfigurationUtils errorForOGAProfigError:OGAProfigExternalErrorSetupFailed]);

    XCTAssertEqual(sequence.status, OGAAdSequenceStatusError);
    OCMVerify([self.adManager dispatchError:[OguryError createProfigNotSyncedError] sequence:sequence]);
}

- (void)testErrorForProfigError {
    XCTAssertEqualObjects([self.adManager errorForProfigError:[OGAConfigurationUtils errorForOGAProfigError:OGAProfigExternalErrorSetupFailed]], [OguryError createProfigNotSyncedError]);
    XCTAssertEqualObjects([self.adManager errorForProfigError:[OGAConfigurationUtils errorForOGAProfigError:OGAProfigExternalErrorNoInternet]],
                          [OguryError createOguryErrorWithCode:OguryCoreErrorTypeNoInternetConnection]);
}

- (void)testContinueLoadAdSequenceAfterProfigSynced {
    // Test method
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OGAAdSequence *sequence = [[OGAAdSequence alloc] initWithAdConfiguration:configuration];
    __block void (^adSyncCompletionCallbacks)(__unused NSArray<OGAAd *> *ads, NSString *error);
    OCMExpect([self.adSyncManager postAdSyncForAdConfiguration:[OCMArg any]
                                          privacyConfiguration:[OCMArg any]
                                             completionHandler:[OCMArg checkWithBlock:^BOOL(id obj) {
                                                 adSyncCompletionCallbacks = obj;
                                                 return YES;
                                             }]]);
    OCMStub([self.adManager continueLoadAdAfterAdSynced:[OCMArg any] ads:[OCMArg any] error:[OCMArg any]])
        .andDo(^(NSInvocation *invocation){
        });

    [self.adManager continueLoadAdSequenceAfterProfigSynced:sequence];
    OCMVerify([self.metricsService sendEvent:[OCMArg any]]);
    OCMVerify([self.adSyncManager postAdSyncForAdConfiguration:configuration privacyConfiguration:[OCMArg any] completionHandler:[OCMArg any]]);

    // Test callback
    NSArray<OGAAd *> *ads = OCMClassMock([NSArray class]);
    OCMStub(ads.count).andReturn(1);
    adSyncCompletionCallbacks(ads, nil);
    OCMVerify([self.adManager continueLoadAdAfterAdSynced:sequence ads:ads error:nil]);
}

- (void)testContinueLoadAdSequenceAfterProfigSyncedHeaderBidding {
    // Test method
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub(configuration.isHeaderBidding).andReturn(true);
    OGAAdSequence *sequence = [[OGAAdSequence alloc] initWithAdConfiguration:configuration];
    __block void (^adSyncCompletionCallbacks)(__unused NSArray<OGAAd *> *ads, NSString *error);
    OCMExpect([self.adSyncManager postAdSyncForAdConfiguration:[OCMArg any]
                                          privacyConfiguration:[OCMArg any]
                                             completionHandler:[OCMArg checkWithBlock:^BOOL(id obj) {
                                                 adSyncCompletionCallbacks = obj;
                                                 return YES;
                                             }]]);
    OCMStub([self.adManager continueLoadAdAfterAdSynced:[OCMArg any] ads:[OCMArg any] error:[OCMArg any]])
        .andDo(^(NSInvocation *invocation){
        });
    [self.adManager continueLoadAdSequenceAfterProfigSynced:sequence];
    OCMReject([self.metricsService sendEvent:[OCMArg any]]);
    OCMVerify([self.adSyncManager postAdSyncForAdConfiguration:configuration privacyConfiguration:[OCMArg any] completionHandler:[OCMArg any]]);

    // Test callback
    NSArray<OGAAd *> *ads = OCMClassMock([NSArray class]);
    OCMStub(ads.count).andReturn(1);
    adSyncCompletionCallbacks(ads, nil);
    OCMVerify([self.adManager continueLoadAdAfterAdSynced:sequence ads:ads error:nil]);
}

- (void)testContinueLoadAdAferAdSynced_prepareAdContents {
    OGAAd *ad = OCMClassMock([OGAAd class]);
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OGAAdSequence *sequence = [[OGAAdSequence alloc] initWithAdConfiguration:configuration];
    __block OGAPrepareAdContentsCompletionHandler completionHandler = nil;
    OCMExpect([self.adContentPreCacheManager prepareAdContents:@[ ad ]
                                             completionHandler:[OCMArg checkWithBlock:^BOOL(id obj) {
                                                 completionHandler = obj;
                                                 return YES;
                                             }]]);
    OCMStub([self.adManager continueLoadAdAfterAdContentsPrepared:[OCMArg any] ads:[OCMArg any] error:[OCMArg any]])
        .andDo(^(NSInvocation *invocation){
        });

    [self.adManager continueLoadAdAfterAdSynced:sequence ads:@[ ad ] error:nil];
    OCMVerify([self.adContentPreCacheManager prepareAdContents:@[ ad ] completionHandler:[OCMArg any]]);

    // Test callback
    completionHandler(nil);
    OCMVerify([self.adManager continueLoadAdAfterAdContentsPrepared:[OCMArg any] ads:[OCMArg any] error:[OCMArg any]]);
}

- (void)testContinueLoadAdAferAdSynced_adSyncError {
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OGAAdSequence *sequence = [[OGAAdSequence alloc] initWithAdConfiguration:configuration];

    [self.adManager continueLoadAdAfterAdSynced:sequence ads:@[] error:[OguryError createNotAvailableError]];

    XCTAssertEqual(sequence.status, OGAAdSequenceStatusError);
    OCMVerify([self.adManager dispatchError:[OguryError createUnknownError] sequence:sequence]);
}

- (void)testContinueLoadAdAferAdSynced_notAdsReturnedByAdSync {
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OGAAdSequence *sequence = [[OGAAdSequence alloc] initWithAdConfiguration:configuration];

    [self.adManager continueLoadAdAfterAdSynced:sequence ads:@[] error:nil];

    XCTAssertEqual(sequence.status, OGAAdSequenceStatusError);
    OCMVerify([self.adManager dispatchError:[OguryError createNotAvailableError] sequence:sequence]);
}

- (void)testContinueLoadAdAferAdSynced_HeaderBiddingError {
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub(configuration.isHeaderBidding).andReturn(true);
    OGAAdSequence *sequence = [[OGAAdSequence alloc] initWithAdConfiguration:configuration];
    [self.adManager continueLoadAdAfterAdSynced:sequence ads:@[] error:[OguryError createBase64DecodeError]];
    XCTAssertEqual(sequence.status, OGAAdSequenceStatusError);
    OCMVerify([self.adManager dispatchError:[OguryError createNotLoadedError] sequence:sequence]);
    OCMVerify([self.log logAd:OguryLogLevelError forAdConfiguration:configuration message:@"failed to decode ad markup"]);

    OCMVerify([self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventAdMarkUpParsingError
                                                 stackTrace:@"Could not decode base64"
                                            adConfiguration:sequence.monitoringAdConfiguration]);
}

- (void)testErrorForAdSyncError {
    XCTAssertEqualObjects([self.adManager errorForAdSyncError:[OguryError createAdSyncNoFillError] ads:nil], [OguryError createNotAvailableError]);
    XCTAssertEqualObjects([self.adManager errorForAdSyncError:nil ads:nil], [OguryError createUnknownError]);
}

- (void)testContinueLoadAdAfterAdContentsPrepared_adContentsPrepared {
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OGAAdSequence *sequence = [[OGAAdSequence alloc] initWithAdConfiguration:configuration];
    NSArray<OGAAd *> *ads = OCMClassMock([NSArray class]);

    [self.adManager continueLoadAdAfterAdContentsPrepared:sequence ads:ads error:nil];

    OCMVerify([self.adControllerFactory createControllersForSequence:sequence ads:ads configuration:configuration]);
}

- (void)testContinueLoadAdAfterAdContentsPrepared_failedToPrepareAdContent {
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OGAAdSequence *sequence = [[OGAAdSequence alloc] initWithAdConfiguration:configuration];
    NSArray<OGAAd *> *ads = OCMClassMock([NSArray class]);
    OCMReject([self.adControllerFactory createControllersForSequence:[OCMArg any] ads:[OCMArg any] configuration:[OCMArg any]]);

    [self.adManager continueLoadAdAfterAdContentsPrepared:sequence ads:ads error:[OguryError createNotLoadedError]];

    XCTAssertEqual(sequence.status, OGAAdSequenceStatusError);
    OCMVerify([self.adManager dispatchError:[OguryError createNotLoadedError] sequence:sequence]);
}

- (void)testIsLoaded {
    OGAAdSequenceCoordinator *coordinator = OCMClassMock([OGAAdSequenceCoordinator class]);
    OCMStub(coordinator.isLoaded).andReturn(YES);
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    OCMStub(sequence.status).andReturn(OGAAdSequenceStatusLoaded);
    OCMStub(sequence.coordinator).andReturn(coordinator);

    XCTAssertTrue([self.adManager isLoaded:sequence]);
}

- (void)testIsLoaded_nilSequence {
    XCTAssertFalse([self.adManager isLoaded:nil]);
}

- (void)testIsLoaded_notLoadedStatus {
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);

    OCMStub(sequence.status).andReturn(OGAAdSequenceStatusLoading);
    XCTAssertFalse([self.adManager isLoaded:sequence]);

    OCMStub(sequence.status).andReturn(OGAAdSequenceStatusShown);
    XCTAssertFalse([self.adManager isLoaded:sequence]);

    OCMStub(sequence.status).andReturn(OGAAdSequenceStatusError);
    XCTAssertFalse([self.adManager isLoaded:sequence]);
}

- (void)testIsLoaded_noCoordinator {
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    OCMStub(sequence.status).andReturn(OGAAdSequenceStatusLoaded);
    OCMStub(sequence.coordinator).andReturn(nil);

    XCTAssertFalse([self.adManager isLoaded:sequence]);
}

- (void)testShow_withoutAdditionalConditions {
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OGAAdSequence *sequence = [[OGAAdSequence alloc] initWithAdConfiguration:configuration];
    OCMStub([self.adManager checkConditions:[OCMArg any] sequence:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(YES);
    OGAProfigDao *mockedDao = OCMClassMock([OGAProfigDao class]);
    OCMStub([self.adManager profigDao]).andReturn(mockedDao);
    OGAProfigFullResponse *profigResponse = OCMClassMock([OGAProfigFullResponse class]);
    OCMStub([mockedDao profigFullResponse]).andReturn(profigResponse);
    OCMStub([profigResponse isAdsEnabled]).andReturn(YES);
    OGAAdSequenceCoordinator *coordinator = OCMClassMock([OGAAdSequenceCoordinator class]);
    OCMStub([coordinator show:[OCMArg anyObjectRef]]).andReturn(YES);
    sequence.coordinator = coordinator;
    OCMStub(self.assetKeyManager.assetKey).andReturn(@"");
    OCMStub(self.assetKeyManager.sdkState).andReturn(OgurySDKStateReady);

    [self.adManager show:sequence additionalConditions:nil];

    XCTAssertEqual(sequence.status, OGAAdSequenceStatusShown);
    OCMVerify([coordinator show:[OCMArg anyObjectRef]]);

    __block NSArray<id<OGAConditionChecker>> *conditions;
    OCMVerify([self.adManager checkConditions:[OCMArg checkWithBlock:^BOOL(id obj) {
                                  conditions = obj;
                                  return YES;
                              }]
                                     sequence:sequence
                                        error:[OCMArg anyObjectRef]]);
}

- (void)testShow_ProfigNotSynced {
    OguryError *checkConditionsError = OCMClassMock([OguryError class]);
    OCMStub(checkConditionsError.code).andReturn(OguryAdsWebViewKilledError);
    OCMStub([self.isKilledChecker checkForSequence:[OCMArg any] error:[OCMArg anyObjectRef]])
        .andDo(^(NSInvocation *invocation) {
            OguryError *__autoreleasing *errorPointer = nil;
            [invocation getArgument:&errorPointer atIndex:3];
            *errorPointer = checkConditionsError;
        })
        .andReturn(NO);
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    OGAProfigDao *profigDao = OCMClassMock([OGAProfigDao class]);
    OCMStub(profigDao.profigFullResponse).andReturn(nil);
    OCMStub([self.adManager profigDao]).andReturn(profigDao);
    [self.adManager show:sequence additionalConditions:nil];
    OCMVerify([self.monitoringDispatcher sendShowErrorEvent:OGAShowErrorEventProfigNotSync adConfiguration:[OCMArg any] customSessionId:[OCMArg any]]);
}

- (void)testShow_withAdditionalConditions {
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OGAAdSequence *sequence = [[OGAAdSequence alloc] initWithAdConfiguration:configuration];
    OCMStub([self.adManager checkConditions:[OCMArg any] sequence:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(YES);
    OGAAdSequenceCoordinator *coordinator = OCMClassMock([OGAAdSequenceCoordinator class]);
    OCMStub([coordinator show:[OCMArg anyObjectRef]]).andReturn(YES);
    sequence.coordinator = coordinator;
    id<OGAConditionChecker> additionalCondition = OCMProtocolMock(@protocol(OGAConditionChecker));
    OGAProfigDao *mockedDao = OCMClassMock([OGAProfigDao class]);
    OCMStub([self.adManager profigDao]).andReturn(mockedDao);
    OGAProfigFullResponse *profigResponse = OCMClassMock([OGAProfigFullResponse class]);
    OCMStub([mockedDao profigFullResponse]).andReturn(profigResponse);
    OCMStub([profigResponse isAdsEnabled]).andReturn(YES);

    [self.adManager show:sequence additionalConditions:@[ additionalCondition ]];

    __block OGAPreCacheEvent *preCacheEvent;
    XCTAssertEqual(sequence.status, OGAAdSequenceStatusShown);
    OCMVerify([coordinator show:[OCMArg anyObjectRef]]);

    __block NSArray<id<OGAConditionChecker>> *conditions;
    OCMVerify([self.adManager checkConditions:[OCMArg checkWithBlock:^BOOL(id obj) {
                                  conditions = obj;
                                  return YES;
                              }]
                                     sequence:sequence
                                        error:[OCMArg anyObjectRef]]);
    XCTAssertEqual(conditions.count, 6);
    XCTAssertEqual(conditions[0], self.isKilledChecker);
    XCTAssertEqual(conditions[1], self.isExpiredChecker);
    XCTAssertEqual(conditions[2], self.isLoadedChecker);
    XCTAssertEqual(conditions[3], self.adEnabledChecker);
    XCTAssertEqual(conditions[4], additionalCondition);
    XCTAssertEqual(conditions[5], self.internetConnectionChecker);
    OCMVerify([self.metricsService enqueueEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                       if ([obj isKindOfClass:[OGAPreCacheEvent class]]) {
                                           preCacheEvent = obj;
                                           return YES;
                                       }
                                       return NO;
                                   }]]);
    XCTAssertEqualObjects(preCacheEvent.eventName, @"SHOW");
}

- (void)testShow_showFailsCheck {
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    OguryError *checkConditionsError = OCMClassMock([OguryError class]);
    OCMStub([self.adManager checkConditions:[OCMArg any] sequence:[OCMArg any] error:[OCMArg anyObjectRef]])
        .andDo(^(NSInvocation *invocation) {
            OguryError *__autoreleasing *errorPointer = nil;
            [invocation getArgument:&errorPointer atIndex:4];
            *errorPointer = checkConditionsError;
        })
        .andReturn(NO);
    OCMReject([self.metricsService enqueueEvent:[OCMArg isKindOfClass:[OGAPreCacheEvent class]]]);

    [self.adManager show:sequence additionalConditions:nil];

    OCMVerify([self.adManager dispatchError:checkConditionsError sequence:sequence]);
}

- (void)testShow_coordinatorFailsToShow {
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OGAAdSequence *sequence = [[OGAAdSequence alloc] initWithAdConfiguration:configuration];
    OCMStub([self.adManager checkConditions:[OCMArg any] sequence:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(YES);
    OguryError *coordinatorError = OCMClassMock([OguryError class]);
    OGAAdSequenceCoordinator *coordinator = OCMClassMock([OGAAdSequenceCoordinator class]);
    OCMStub([coordinator show:[OCMArg anyObjectRef]])
        .andDo(^(NSInvocation *invocation) {
            OguryError *__autoreleasing *errorPointer = nil;
            [invocation getArgument:&errorPointer atIndex:2];
            *errorPointer = coordinatorError;
        })
        .andReturn(NO);
    sequence.coordinator = coordinator;
    OGAProfigDao *mockedDao = OCMClassMock([OGAProfigDao class]);
    OCMStub([self.adManager profigDao]).andReturn(mockedDao);
    OGAProfigFullResponse *profigResponse = OCMClassMock([OGAProfigFullResponse class]);
    OCMStub([mockedDao profigFullResponse]).andReturn(profigResponse);
    OCMStub([profigResponse isAdsEnabled]).andReturn(YES);

    [self.adManager show:sequence additionalConditions:nil];

    __block OGAPreCacheEvent *preCacheEvent;
    XCTAssertEqual(sequence.status, OGAAdSequenceStatusError);
    OCMVerify([self.adManager dispatchError:coordinatorError sequence:sequence]);
    // For compatibility with the old architecture, we send the SHOW even if the ad fails to presented.
    OCMVerify([self.metricsService enqueueEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                       if ([obj isKindOfClass:[OGAPreCacheEvent class]]) {
                                           preCacheEvent = obj;
                                           return YES;
                                       }
                                       return NO;
                                   }]]);
    XCTAssertEqualObjects(preCacheEvent.eventName, @"SHOW");
}

- (void)test_ShouldReturnPreCacheTrackingURLFromSequenceWithHeaderBidding {
    NSArray *myArray = @[ @{
        @"ad_track_urls" : @{
            @"ad_precache_url" : @"https://pl-v2-us-east-1.presage.io/v2/pl",
            @"ad_track_url" : @"https://tr-v1-us-east-1.presage.io/v1/track",
            @"ad_history_url" : @"https://ah-v1-us-east-1.presage.io/v1/ad_history"
        }
    } ];

    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub(configuration.adMarkupSync).andReturn(myArray);
    OCMStub(configuration.isHeaderBidding).andReturn(true);

    OGAAdSequence *sequence = [[OGAAdSequence alloc] initWithAdConfiguration:configuration];

    NSURL *preCacheEventURL = [self.adManager preCacheEventTrackingURLFromAdConfiguration:sequence.configuration];

    XCTAssertNotNil(preCacheEventURL);
}

- (void)test_ShouldNotReturnPreCacheTrackingURLFromSequenceWithHeaderBiddingAndNoURL {
    NSArray *myArray = @[ @{@"ad_track_urls" : @{@"ad_track_url" : @"https://tr-v1-us-east-1.presage.io/v1/track", @"ad_history_url" : @"https://ah-v1-us-east-1.presage.io/v1/ad_history"}} ];

    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub(configuration.adMarkupSync).andReturn(myArray);

    OGAAdSequence *sequence = [[OGAAdSequence alloc] initWithAdConfiguration:configuration];

    NSURL *preCacheEventURL = [self.adManager preCacheEventTrackingURLFromAdConfiguration:sequence.configuration];

    XCTAssertNil(preCacheEventURL);
}

- (void)test_ShouldNotReturnPreCacheTrackingURLFromSequenceWithoutHeaderBidding {
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);

    OGAAdSequence *sequence = [[OGAAdSequence alloc] initWithAdConfiguration:configuration];

    NSURL *preCacheEventURL = [self.adManager preCacheEventTrackingURLFromAdConfiguration:sequence.configuration];

    XCTAssertNil(preCacheEventURL);
}

- (void)testWhenIsKillerCheckFailsThenProperErrorAndMonitoringEventsAreDispatched {
    OguryError *checkConditionsError = OCMClassMock([OguryError class]);
    OCMStub(checkConditionsError.code).andReturn(OguryAdsWebViewKilledError);
    OCMStub([self.isKilledChecker checkForSequence:[OCMArg any] error:[OCMArg anyObjectRef]])
        .andDo(^(NSInvocation *invocation) {
            OguryError *__autoreleasing *errorPointer = nil;
            [invocation getArgument:&errorPointer atIndex:3];
            *errorPointer = checkConditionsError;
        })
        .andReturn(NO);
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    [self.adManager show:sequence additionalConditions:nil];
    OCMVerify([self.adManager dispatchError:checkConditionsError sequence:sequence]);
    OCMVerify([self.monitoringDispatcher sendShowErrorEvent:OGAShowErrorEventWebviewTerminatedByOS adConfiguration:[OCMArg any]]);
}

- (void)testWhenContinueLoadAdAferAdSyncedIsCalledWithNoAdsThenMonitoringLoadErrorShouldBeDispatched {
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub(configuration.monitoringDetails.sessionId).andReturn(@"sessionId");
    OCMStub([configuration adUnitId]).andReturn(@"adUnitId");
    OGAAdSequence *sequence = [[OGAAdSequence alloc] initWithAdConfiguration:configuration];
    [self.adManager continueLoadAdAfterAdSynced:sequence ads:@[] error:nil];
    OCMVerify([self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventNoFill
                                            adConfiguration:[OCMArg any]]);
}

- (void)testWhenContinueLoadAdAferAdSyncedIsCalledWitErrorThenMonitoringLoadErrorShouldBeDispatched {
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub(configuration.monitoringDetails.sessionId).andReturn(@"sessionId");
    OCMStub([configuration adUnitId]).andReturn(@"adUnitId");
    OGAAdSequence *sequence = [[OGAAdSequence alloc] initWithAdConfiguration:configuration];
    [self.adManager continueLoadAdAfterAdSynced:sequence ads:@[] error:[OguryError createAdSyncParsingError]];
    OCMVerify([self.monitoringDispatcher sendLoadErrorEventParsingFailWithStackTrace:[OCMArg any]
                                                                     adConfiguration:[OCMArg any]]);
}

- (void)testWhenAllAdsAreExpiredThenMonitoringErrorShouldBeDispatched {
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OGAAdSequence *sequence = OCMPartialMock([[OGAAdSequence alloc] initWithAdConfiguration:configuration]);
    OGAAdSequenceCoordinator *coordinator = OCMPartialMock([[OGAAdSequenceCoordinator alloc] initWithSequence:sequence adControllers:@[]]);
    OCMStub([sequence coordinator]).andReturn(coordinator);
    OGAAdController *adController = OCMClassMock([OGAAdController class]);
    OGAExpirationContext *context = OCMPartialMock([[OGAExpirationContext alloc] initFrom:OGAdExpirationSourceProfig withExpirationTime:@10]);
    OCMStub(adController.expirationContext).andReturn(context);
    NSArray<OGAAdController *> *controllers = @[ adController ];
    OCMStub(coordinator.adControllers).andReturn(controllers);
    OCMStub([coordinator isExpired]).andReturn(YES);
    OCMStub([coordinator isLoaded]).andReturn(YES);
    OCMStub([coordinator isClosed]).andReturn(NO);
    OCMStub([self.adManager checkConditions:[OCMArg any] sequence:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(YES);
    OGAProfigDao *mockedDao = OCMClassMock([OGAProfigDao class]);
    OCMStub([self.adManager profigDao]).andReturn(mockedDao);
    OGAProfigFullResponse *profigResponse = OCMClassMock([OGAProfigFullResponse class]);
    OCMStub([mockedDao profigFullResponse]).andReturn(profigResponse);
    OCMStub([profigResponse isAdsEnabled]).andReturn(YES);
    [self.adManager show:sequence additionalConditions:nil];
    OCMVerify([self.monitoringDispatcher sendShowErrorEventAdExpired:[OCMArg any] context:[OCMArg any]]);
}

- (void)testRegisterToPersistentEventBus {
    [self.adManager registerToPersistentEventBus];
    XCTAssertEqual(self.adManager.persistentEventBus, self.persistentEventBus);
    OCMVerify([self.adManager registerToPersistentEventBus:[OCMArg any] eventSubscriber:[OCMArg any]]);
}

- (void)testRegisterToPersistentEventBusWithArguments {
    OGAEventSubscriber *subscriber = OCMClassMock([OGAEventSubscriber class]);
    [self.adManager registerToPersistentEventBus:self.persistentEventBus eventSubscriber:subscriber];
    XCTAssertEqual(self.adManager.eventSubscriber, subscriber);
    OCMVerify([self.persistentEventBus registerOguryEventSubscriber:subscriber]);
}

- (void)testHandleEventBusAfterEventExpiration {
    OguryEventEntry *eventEntry = OCMClassMock([OguryEventEntry class]);
    OCMStub(eventEntry.timestamp).andReturn([NSDate date]);
    [self.adManager handleEventBusAfterEventExpiration:eventEntry];
    XCTAssertNotNil(self.adManager.eventBusExprirationTimer);
    OguryEventEntry *event = [self.adManager.eventBusExprirationTimer.userInfo objectForKey:@"event"];
    XCTAssertEqual(event, eventEntry);
}

- (void)testTimerHasExpiredFor {
    NSTimer *timer = OCMClassMock([NSTimer class]);
    OCMStub([self.adManager handleConsentChange:[OCMArg any]]);
    [self.adManager timerHasExpiredFor:timer];
    OCMVerify([self.adManager handleConsentChange:[OCMArg any]]);
}

- (void)testHandleConsentChangeTimerExpired {
    self.adManager.eventBusExprirationTimer = OCMClassMock([NSTimer class]);
    ;
    OguryEventEntry *eventEntry = OCMClassMock([OguryEventEntry class]);
    OCMStub([self.adManager handleEventBusAfterEventExpiration:eventEntry]);
    OCMStub([self.persistentEventBus shouldContinueLoadingAdWith:eventEntry]).andReturn(NO);
    [self.adManager handleConsentChange:eventEntry];
    XCTAssertNil(self.adManager.eventBusExprirationTimer);
    OCMVerify([self.adManager handleEventBusAfterEventExpiration:eventEntry]);
}

- (void)testHandleConsentChangeTimerExpiredContinue {
    self.adManager.eventBusExprirationTimer = OCMClassMock([NSTimer class]);
    ;
    OguryEventEntry *eventEntry = OCMClassMock([OguryEventEntry class]);
    OCMStub([self.adManager handleEventBusAfterEventExpiration:eventEntry]);
    OCMStub([self.persistentEventBus shouldContinueLoadingAdWith:eventEntry]).andReturn(YES);
    [self.adManager handleConsentChange:eventEntry];
    XCTAssertNil(self.adManager.eventBusExprirationTimer);
    OCMReject([self.adManager handleEventBusAfterEventExpiration:eventEntry]);
}

- (void)testWhenCallingLoadWhileASequenceIsLoadingThenACallErrorShouldBeSent {
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    OCMStub(sequence.status).andReturn(OGAAdSequenceStatusLoading);
    OGAAdConfiguration *conf = OCMPartialMock([OGAAdConfiguration new]);
    [self.adManager loadAdConfiguration:conf previousSequence:sequence];
    OCMVerify([self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventCallError adConfiguration:[OCMArg any]]);
}

- (void)testWhenCallingLoadWhileAPrevisouSequenceHasLoadedThenLoadedShouldBeSent {
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    OCMStub(sequence.status).andReturn(OGAAdSequenceStatusLoaded);
    OCMStub([self.adManager isLoaded:sequence]).andReturn(YES);
    OCMStub([self.adManager isExpired:sequence]).andReturn(NO);
    OGAAdConfiguration *conf = OCMPartialMock([OGAAdConfiguration new]);
    [self.adManager loadAdConfiguration:conf previousSequence:sequence];
    OCMVerify([self.monitoringDispatcher sendLoadEvent:OGALoadEventLoadAdLoaded adConfiguration:[OCMArg any]]);
}

- (void)testWhenCallingLoadWhileAPrevisouSequenceHasLoadedThenSessionIdShouldBeUpdated {
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    OCMStub(sequence.status).andReturn(OGAAdSequenceStatusLoaded);
    OCMStub([self.adManager isLoaded:sequence]).andReturn(YES);
    OCMStub([self.adManager isExpired:sequence]).andReturn(NO);
    OGAAdConfiguration *conf = OCMPartialMock([OGAAdConfiguration new]);
    [self.adManager loadAdConfiguration:conf previousSequence:sequence];
    OCMVerify([sequence updateReloadStateWithSessionId:[OCMArg any]]);
}

- (void)testWhenShowIsCalledThenItIsCalledOnMainThread {
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    OCMStub([sequence.coordinator show:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
        XCTAssertTrue([NSThread isMainThread], @"doSomething should be called on the main thread");
    });
    [self.adManager show:sequence additionalConditions:nil];
}

@end

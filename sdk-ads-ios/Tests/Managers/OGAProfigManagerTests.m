//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "OGAAdLogMessage.h"
#import "OGAProfigManager+Testing.h"
#import "OGAAdIdentifierService.h"
#import "OGALog.h"
#import "OGAMetricsService.h"

@interface OGAProfigManagerTests : XCTestCase

@property(nonatomic, strong) OGAProfigDao *profigDao;
@property(nonatomic, strong) OGAProfigService *profigService;
@property(nonatomic, strong) OGAOMIDService *omidService;
@property(nonatomic, strong) OGAProfigManager *profigManager;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) OGAMetricsService *metricsService;

@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) OGCInternal *internalCore;
@property(nonatomic, strong) OGAUserDefaultsStore *userDefaultStore;

@end

@implementation OGAProfigManagerTests

static NSString *const TestUserAgent = @"userAgentTest";
static NSString *const TestInstanceToken = @"TestInstanceToken";

- (void)setUp {
    self.log = OCMClassMock([OGALog class]);
    self.profigDao = OCMClassMock([OGAProfigDao class]);
    self.profigService = OCMClassMock([OGAProfigService class]);
    self.omidService = OCMClassMock([OGAOMIDService class]);
    self.monitoringDispatcher = OCMClassMock([OGAMonitoringDispatcher class]);
    self.metricsService = OCMClassMock([OGAMetricsService class]);
    self.internalCore = OCMClassMock([OGCInternal class]);
    self.userDefaultStore = OCMClassMock([OGAUserDefaultsStore class]);
    OGAProfigManager *profigManager = [[OGAProfigManager alloc] initWithProfigDao:self.profigDao
                                                                    profigService:self.profigService
                                                                      omidService:self.omidService
                                                             monitoringDispatcher:self.monitoringDispatcher
                                                                   metricsService:self.metricsService
                                                                              log:self.log
                                                                     internalCore:self.internalCore
                                                                 userDefaultStore:self.userDefaultStore];
    self.profigManager = OCMPartialMock(profigManager);
}

- (void)testShared {
    OGAProfigManager *profigManager = [OGAProfigManager shared];
    XCTAssertNotNil(profigManager);
    XCTAssertNotNil(profigManager.profigDao);
    XCTAssertNotNil(profigManager.profigService);
}

- (void)testResetProfig {
    NSArray<ProfigCompletionBlock> *waitingCompletionBlocks = self.profigManager.waitingCompletionBlocks;

    [self.profigManager resetProfig];

    XCTAssertNotEqual(self.profigManager.waitingCompletionBlocks, waitingCompletionBlocks);
    OCMVerify([self.profigDao reset]);
}

- (void)testProfigParametersWereUpdated {
    OCMStub([self.profigDao profigInstanceToken]).andReturn(TestInstanceToken);
    id identifierService = OCMClassMock([OGAAdIdentifierService class]);
    OCMStub([identifierService getInstanceToken]).andReturn(TestInstanceToken);
    XCTAssertFalse([self.profigManager profigParametersWereUpdated]);
}

- (void)testProfigParametersWereUpdated_instanceTokenHasChanged {
    OCMStub([self.profigDao profigInstanceToken]).andReturn(TestInstanceToken);
    id identifierService = OCMClassMock([OGAAdIdentifierService class]);
    OCMStub([identifierService getInstanceToken]).andReturn(@"not TestInstanceToken");
    XCTAssertTrue([self.profigManager profigParametersWereUpdated]);
}

- (void)testSyncProfig_alreadySyncing {
    OCMReject([self.profigService loadWithCompletion:[OCMArg any]]);
    [self.profigManager.waitingCompletionBlocks addObject:^(OGAProfigFullResponse *response, NSError *error){
        // noop
    }];

    [self.profigManager syncProfigWithCompletion:^(OGAProfigFullResponse *response, NSError *error){
        // noop
    }];

    XCTAssertEqual(self.profigManager.waitingCompletionBlocks.count, 2);
}

- (void)testSyncProfig_shouldSync {
    OGAProfigFullResponse *response = OCMClassMock([OGAProfigFullResponse class]);
    __block ProfigCompletionBlock capturedCompletionBlock;
    OCMStub([self.profigManager shouldSync]).andReturn(YES);
    OCMStub([self.profigManager onProfigResponse:[OCMArg any] error:[OCMArg any] completionBlocks:[OCMArg any]]);
    OCMStub([self.profigManager fetchProfig]);

    [self.profigManager syncProfigWithCompletion:^(OGAProfigFullResponse *response, NSError *error){
        // noop
    }];

    XCTAssertEqual(self.profigManager.waitingCompletionBlocks.count, 1);
    OCMVerify([self.profigManager fetchProfig]);
}

- (void)testSyncProfig_profigAlreadySynced {
    OGAProfigFullResponse *expectedResponse = OCMClassMock([OGAProfigFullResponse class]);
    OCMStub(self.profigDao.profigFullResponse).andReturn(expectedResponse);
    OCMStub([self.profigManager shouldSync]).andReturn(NO);
    OCMReject([self.profigService loadWithCompletion:[OCMArg any]]);

    XCTestExpectation *expectation = [self expectationWithDescription:@"Profig completion block called."];
    [self.profigManager syncProfigWithCompletion:^(OGAProfigFullResponse *response, NSError *error) {
        XCTAssertEqual(response, expectedResponse);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    OCMVerify([self.profigManager updateMonitoringTrackingAndBlacklistedTracks:expectedResponse]);
    [self waitForExpectations:@[ expectation ] timeout:1.0];
}

- (void)testFetchProfig {
    OGAProfigFullResponse *fullResponse = OCMClassMock([OGAProfigFullResponse class]);
    __block ProfigCompletionBlock profigCompletionBlock;
    OCMStub([self.profigService loadWithCompletion:[OCMArg checkWithBlock:^BOOL(id obj) {
                                    profigCompletionBlock = obj;
                                    return YES;
                                }]]);

    [self.profigManager fetchProfig];

    // Do profig request.
    OCMVerify([self.profigService loadWithCompletion:[OCMArg any]]);
    XCTAssertNotNil(profigCompletionBlock);
    profigCompletionBlock(fullResponse, nil);

    // Then process the response.
    OCMVerify([self.profigManager onProfigResponse:fullResponse error:nil completionBlocks:[OCMArg any]]);
}

- (void)testOnProfigResponse_saveResponseAndDispatch {
    OGAProfigFullResponse *response = OCMClassMock([OGAProfigFullResponse class]);
    OCMStub([self.profigManager dispatchToCompletionBlocks:[OCMArg any] response:[OCMArg any] error:[OCMArg any]]);
    [self.profigManager onProfigResponse:response error:nil completionBlocks:self.profigManager.waitingCompletionBlocks];

    NSMutableArray<ProfigCompletionBlock> *completionBlocks = self.profigManager.waitingCompletionBlocks;
    OCMVerify([self.monitoringDispatcher setBlackListedTracks:response.blacklistedTracks]);
    OCMVerify([self.monitoringDispatcher setTrackingMask:OGATrackingMaskNone]);
    OCMVerify([self.profigDao updateWithFullProfig:response]);
    OCMVerify([self.profigManager dispatchToCompletionBlocks:completionBlocks response:response error:nil]);
}

- (void)testOnProfigResponse_dispatchError {
    NSError *error = OCMClassMock([NSError class]);
    OCMStub([self.profigManager dispatchToCompletionBlocks:[OCMArg any] response:[OCMArg any] error:[OCMArg any]]);
    [self.profigManager onProfigResponse:nil error:error completionBlocks:self.profigManager.waitingCompletionBlocks];
    NSMutableArray<ProfigCompletionBlock> *completionBlocks = self.profigManager.waitingCompletionBlocks;
    OCMVerify([self.profigManager dispatchToCompletionBlocks:completionBlocks response:nil error:error]);
}

- (void)testWhenProfigContainsErrorThenErrorIsLogged {
    NSError *error = OCMClassMock([NSError class]);
    OCMStub(error.localizedDescription).andReturn(@"ERROR_TYPE : ERROR_MESSAGE");
    OGAProfigFullResponse *response = OCMClassMock([OGAProfigFullResponse class]);
    [self.profigManager onProfigResponse:response error:error completionBlocks:self.profigManager.waitingCompletionBlocks];
    OGAAdLogMessage *message = [[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelError
                                                      adConfiguration:nil
                                                              logType:OguryLogTypePublisher
                                                              message:@"[Setup] Failed to retrieved configuration (ERROR_TYPE : ERROR_MESSAGE)"
                                                                 tags:nil];
    OCMVerify([self.log log:message]);
}

- (void)testWhenProfigContainsErrorThenProfigIsSaved {
    NSError *error = OCMClassMock([NSError class]);
    OCMStub(error.localizedDescription).andReturn(@"ERROR_TYPE : ERROR_MESSAGE");
    OGAProfigFullResponse *response = OCMClassMock([OGAProfigFullResponse class]);
    [self.profigManager onProfigResponse:response error:error completionBlocks:self.profigManager.waitingCompletionBlocks];
    OCMVerify([self.profigDao updateWithFullProfig:response]);
}

- (void)testDispatchToCompletionBlocks {
    OGAProfigFullResponse *expectedResponse = OCMClassMock([OGAProfigFullResponse class]);
    NSError *expectedError = OCMClassMock([NSError class]);
    XCTestExpectation *firstCompletionBlockExpectation = [self expectationWithDescription:@"first completion block called"];
    XCTestExpectation *secondCompletionBlockExpectation = [self expectationWithDescription:@"second completion block called"];
    NSMutableArray<ProfigCompletionBlock> *completionBlocks = [[NSMutableArray alloc] init];
    [completionBlocks addObject:^(OGAProfigFullResponse *response, NSError *error) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertEqual(response, expectedResponse);
        XCTAssertEqual(error, expectedError);
        [firstCompletionBlockExpectation fulfill];
    }];
    [completionBlocks addObject:^(OGAProfigFullResponse *response, NSError *error) {
        XCTAssertTrue([NSThread isMainThread]);
        XCTAssertEqual(response, expectedResponse);
        XCTAssertEqual(error, expectedError);
        [secondCompletionBlockExpectation fulfill];
    }];

    [self.profigManager dispatchToCompletionBlocks:completionBlocks response:expectedResponse error:expectedError];

    [self waitForExpectations:@[ firstCompletionBlockExpectation, secondCompletionBlockExpectation ] timeout:10.0];
}

- (void)testIsProfigExpired_noProfigInCache {
    OCMStub(self.profigDao.profigFullResponse).andReturn(nil);

    XCTAssertTrue(self.profigManager.isProfigExpired);
}

- (void)testIsProfigExpired_lastProfigSyncDateExpired {
    OGAProfigFullResponse *profigResponse = OCMClassMock([OGAProfigFullResponse class]);
    OCMStub(profigResponse.retryInterval).andReturn(@43200);
    OCMStub(self.profigDao.lastProfigSyncDate).andReturn([NSDate dateWithTimeIntervalSince1970:10]);
    OCMStub(self.profigDao.profigFullResponse).andReturn(profigResponse);

    XCTAssertTrue(self.profigManager.isProfigExpired);
}

- (void)testIsProfigExpired_lastProfigSyncDateValid {
    OGAProfigFullResponse *profigResponse = OCMClassMock([OGAProfigFullResponse class]);
    OCMStub(profigResponse.retryInterval).andReturn(@43200);
    OCMStub(self.profigDao.lastProfigSyncDate).andReturn([NSDate date]);
    OCMStub(self.profigDao.profigFullResponse).andReturn(profigResponse);

    XCTAssertFalse(self.profigManager.isProfigExpired);
}

- (void)testShouldSync_shouldSyncIfProfigExpiredAndParametersUpdated {
    OCMStub([self.profigManager isProfigExpired]).andReturn(YES);
    OCMStub([self.profigManager profigParametersWereUpdated]).andReturn(YES);
    XCTAssertTrue([self.profigManager shouldSync]);
}

- (void)testShouldSync_shouldSyncIfProfigExpiredAndParametersNotUpdated {
    OCMStub([self.profigManager isProfigExpired]).andReturn(YES);
    OCMStub([self.profigManager profigParametersWereUpdated]).andReturn(NO);
    XCTAssertTrue([self.profigManager shouldSync]);
}

- (void)testShouldSync_shouldSyncIfProfigValidAndParametersUpdated {
    OCMStub([self.profigManager isProfigExpired]).andReturn(NO);
    OCMStub([self.profigManager profigParametersWereUpdated]).andReturn(YES);
    XCTAssertTrue([self.profigManager shouldSync]);
}

- (void)testShouldSync_shouldNotSyncIfProfigValidAndParametersNotUpdated {
    OCMStub([self.profigManager isProfigExpired]).andReturn(NO);
    OCMStub([self.profigManager profigParametersWereUpdated]).andReturn(NO);
    XCTAssertFalse([self.profigManager shouldSync]);
}

- (void)testShouldSync_shouldSyncConsentChanged {
    OCMStub([self.internalCore gppConsentString]).andReturn(@"GPP");
    OCMStub([self.userDefaultStore dataForKey:@"OGY-HashConsentKeys"]).andReturn([[NSData alloc] init]);
    XCTAssertTrue([self.profigManager shouldSync]);
}

- (void)testShouldSync_shouldNotSyncNoConsentChanged {
    OCMStub([self.internalCore gppConsentString]).andReturn(@"GPP");
    OCMStub([self.userDefaultStore dataForKey:@"OGY-HashConsentKeys"]).andReturn([self.profigManager retrieveConsentData]);
    OCMStub([self.profigManager isProfigExpired]).andReturn(NO);
    OCMStub([self.profigManager profigParametersWereUpdated]).andReturn(NO);
    XCTAssertFalse([self.profigManager shouldSync]);
}

- (void)testUpdateMonitoringTrackingAndBlacklist {
    OGAProfigFullResponse *profigResponse = OCMClassMock([OGAProfigFullResponse class]);
    NSArray *blackList2 = @[ @"SI-001" ];
    OCMStub(profigResponse.adLifeCycleLogsEnabled).andReturn(YES);
    OCMStub(profigResponse.blacklistedTracks).andReturn(blackList2);
    [self.profigManager updateMonitoringTrackingAndBlacklistedTracks:profigResponse];
    OCMVerify([self.profigManager.monitoringDispatcher setTrackingMask:OGATrackingMaskAdsLifeCycle]);
    OCMVerify([self.profigManager.monitoringDispatcher setBlackListedTracks:blackList2]);
    OCMVerify([self.profigManager.metricsService setTrackingMask:OGATrackingMaskNone]);
}

- (void)testWhenCacheAndPreCacheLogsAreEnabledThenProperValuesAreDispatched {
    OGAProfigFullResponse *profigResponse = OCMClassMock([OGAProfigFullResponse class]);
    OCMStub(profigResponse.cacheLogsEnabled).andReturn(YES);
    OCMStub(profigResponse.precachingLogsEnabled).andReturn(YES);
    [self.profigManager updateMonitoringTrackingAndBlacklistedTracks:profigResponse];
    OCMVerify([self.profigManager.monitoringDispatcher setTrackingMask:OGATrackingMaskNone]);
    OCMVerify([self.profigManager.monitoringDispatcher setBlackListedTracks:nil]);
    OCMVerify([self.profigManager.metricsService setTrackingMask:OGATrackingMaskCache | OGATrackingMaskPreCache]);
}

- (void)testWhenAllProfigTrackingModeAreDisabledThenProperValueIsReturned {
    OGAProfigFullResponse *profigResponse = OCMClassMock([OGAProfigFullResponse class]);
    OCMStub([profigResponse cacheLogsEnabled]).andReturn(NO);
    OCMStub([profigResponse precachingLogsEnabled]).andReturn(NO);
    OCMStub([profigResponse adLifeCycleLogsEnabled]).andReturn(NO);
    XCTAssertEqual(OGATrackingMaskNone, [self.profigManager trackingMaskFromProfig:profigResponse]);
}

- (void)testWhenProfigTrackingModeCacheOnlyIsEnabledThenProperValueIsReturned {
    OGAProfigFullResponse *profigResponse = OCMClassMock([OGAProfigFullResponse class]);
    OCMStub([profigResponse cacheLogsEnabled]).andReturn(YES);
    OCMStub([profigResponse precachingLogsEnabled]).andReturn(NO);
    OCMStub([profigResponse adLifeCycleLogsEnabled]).andReturn(NO);
    XCTAssertEqual(OGATrackingMaskCache, [self.profigManager trackingMaskFromProfig:profigResponse]);
}

- (void)testWhenProfigTrackingModePreCacheOnlyIsEnabledThenProperValueIsReturned {
    OGAProfigFullResponse *profigResponse = OCMClassMock([OGAProfigFullResponse class]);
    OCMStub([profigResponse cacheLogsEnabled]).andReturn(NO);
    OCMStub([profigResponse precachingLogsEnabled]).andReturn(YES);
    OCMStub([profigResponse adLifeCycleLogsEnabled]).andReturn(NO);
    XCTAssertEqual(OGATrackingMaskPreCache, [self.profigManager trackingMaskFromProfig:profigResponse]);
}

- (void)testWhenProfigTrackingModeAdLifeCycleOnlyIsEnabledThenProperValueIsReturned {
    OGAProfigFullResponse *profigResponse = OCMClassMock([OGAProfigFullResponse class]);
    OCMStub([profigResponse cacheLogsEnabled]).andReturn(NO);
    OCMStub([profigResponse precachingLogsEnabled]).andReturn(NO);
    OCMStub([profigResponse adLifeCycleLogsEnabled]).andReturn(YES);
    OCMStub([profigResponse blacklistedTracks]).andReturn(@[]);
    XCTAssertEqual(OGATrackingMaskAdsLifeCycle, [self.profigManager trackingMaskFromProfig:profigResponse]);
}

- (void)testWhenProfigTrackingModeAdLifeCycleOnlyIsEnabledWithoutBlacklistThenDefaultValueIsReturned {
    OGAProfigFullResponse *profigResponse = OCMClassMock([OGAProfigFullResponse class]);
    OCMStub([profigResponse cacheLogsEnabled]).andReturn(NO);
    OCMStub([profigResponse precachingLogsEnabled]).andReturn(NO);
    OCMStub([profigResponse adLifeCycleLogsEnabled]).andReturn(YES);
    XCTAssertEqual(OGATrackingMaskNone, [self.profigManager trackingMaskFromProfig:profigResponse]);
}

- (void)testWhenAllProfigTrackingModeAreEnabledThenProperValueIsReturned {
    OGAProfigFullResponse *profigResponse = OCMClassMock([OGAProfigFullResponse class]);
    OCMStub([profigResponse cacheLogsEnabled]).andReturn(YES);
    OCMStub([profigResponse precachingLogsEnabled]).andReturn(YES);
    OCMStub([profigResponse adLifeCycleLogsEnabled]).andReturn(YES);
    OCMStub([profigResponse blacklistedTracks]).andReturn(@[]);
    XCTAssertEqual(OGATrackingMaskCache | OGATrackingMaskPreCache | OGATrackingMaskAdsLifeCycle, [self.profigManager trackingMaskFromProfig:profigResponse]);
}

- (void)testWhenAllProfigTrackingModeAreEnabledWithoutBlacklistThenProperValueIsReturned {
    OGAProfigFullResponse *profigResponse = OCMClassMock([OGAProfigFullResponse class]);
    OCMStub([profigResponse cacheLogsEnabled]).andReturn(YES);
    OCMStub([profigResponse precachingLogsEnabled]).andReturn(YES);
    OCMStub([profigResponse adLifeCycleLogsEnabled]).andReturn(YES);
    XCTAssertEqual(OGATrackingMaskCache | OGATrackingMaskPreCache, [self.profigManager trackingMaskFromProfig:profigResponse]);
}

- (void)testWhenAllProfigTrackingModeCacheAndPrecacheAreEnabledWithoutBlacklistThenProperValueIsReturned {
    OGAProfigFullResponse *profigResponse = OCMClassMock([OGAProfigFullResponse class]);
    OCMStub([profigResponse cacheLogsEnabled]).andReturn(YES);
    OCMStub([profigResponse precachingLogsEnabled]).andReturn(YES);
    OCMStub([profigResponse adLifeCycleLogsEnabled]).andReturn(NO);
    XCTAssertEqual(OGATrackingMaskCache | OGATrackingMaskPreCache, [self.profigManager trackingMaskFromProfig:profigResponse]);
}

@end

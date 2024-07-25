//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OguryCore/OguryNetworkClient.h>

#import <OCMock/OCMock.h>
#import "OGATrackEvent.h"
#import "OGAMetricsService.h"
#import "OGAAdImpressionManager.h"
#import "OGAAd+ImpressionSource.h"
#import "OGALog.h"
#import "OGAMonitoringDispatcher.h"
#import "OguryError+utility.h"

NSString *const OGAAdImpressionControllerTestsLocalIdentifier = @"local-id";
NSString *const OGAAdImpressionControllerTestsAdvertId = @"advert-id";
NSString *const OGAAdImpressionControllerTestsImpressionUrl = @"https://example.com";

@interface OGAAdImpressionManager (Testing)

@property(atomic, strong) NSMutableDictionary<NSString *, NSNumber *> *hasSentImpressionTrackByAdId;
@property(atomic, strong) NSMutableDictionary<NSString *, NSNumber *> *hasSentImpressionDelegateByAdId;
@property(atomic, strong) NSMutableDictionary<NSString *, NSNumber *> *hasSentImpressionTrackBySessionId;

- (instancetype)initWithMetricsService:(OGAMetricsService *)metricsService
                         networkClient:(OguryNetworkClient *)networkClient
                                   log:(OGALog *)log
                  monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher;
;

- (void)sendImpressionTracker:(OGAAdExposure *)exposure ad:(OGAAd *)ad delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher;

- (void)hasSentImpressionDelegateFor:(OGAAd *)ad;

- (void)sendDefaultImpressionTracker:(OGAAd *)ad;

- (void)sendCustomImpressionTracker:(OGAAd *)ad;

@end

@interface OGAAdImpressionControllerTests : XCTestCase

@property(nonatomic, strong) OGAAd *ad;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) OGAMetricsService *metricsService;
@property(nonatomic, strong) OguryNetworkClient *networkClient;
@property(nonatomic, strong) OGAAdImpressionManager *impressionManager;
@property(nonatomic, strong) OGADelegateDispatcher *delegateDispatcher;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;

@end

@implementation OGAAdImpressionControllerTests

- (void)setUp {
    self.ad = OCMClassMock([OGAAd class]);
    self.metricsService = OCMClassMock([OGAMetricsService class]);
    self.networkClient = OCMClassMock([OguryNetworkClient class]);
    self.delegateDispatcher = OCMClassMock([OGADelegateDispatcher class]);
    self.log = OCMClassMock([OGALog class]);
    self.monitoringDispatcher = OCMPartialMock([[OGAMonitoringDispatcher alloc] init]);

    OCMStub(self.ad.localIdentifier).andReturn(OGAAdImpressionControllerTestsLocalIdentifier);
    OCMStub(self.ad.identifier).andReturn(OGAAdImpressionControllerTestsAdvertId);

    OGAAdImpressionManager *impressionManager = [[OGAAdImpressionManager alloc] initWithMetricsService:self.metricsService
                                                                                         networkClient:self.networkClient
                                                                                                   log:self.log
                                                                                  monitoringDispatcher:self.monitoringDispatcher];
    self.impressionManager = OCMPartialMock(impressionManager);
}

#pragma mark - Methods

- (void)testSendIfNecessaryAfterExposureChanged_sendImpressionIfExposureAboveMin {
    OGAAdExposure *exposure = [[OGAAdExposure alloc] init];
    exposure.exposurePercentage = 75.0f;
    OCMStub([self.impressionManager sendImpressionTracker:OCMOCK_ANY ad:OCMOCK_ANY delegateDispatcher:OCMOCK_ANY]);

    [self.impressionManager sendIfNecessaryAfterExposureChanged:exposure ad:self.ad delegateDispatcher:OCMOCK_ANY];

    OCMVerify([self.impressionManager sendImpressionTracker:exposure ad:self.ad delegateDispatcher:OCMOCK_ANY]);
}

- (void)testSendIfNecessaryAfterExposureChanged_doNotSendImpressionIfBelowMin {
    OGAAdExposure *exposure = [[OGAAdExposure alloc] init];
    exposure.exposurePercentage = 40.0f;
    OCMStub([self.impressionManager sendImpressionTracker:OCMOCK_ANY ad:OCMOCK_ANY delegateDispatcher:OCMOCK_ANY]);

    [self.impressionManager sendIfNecessaryAfterExposureChanged:exposure ad:self.ad delegateDispatcher:OCMOCK_ANY];
}

- (void)testSendImpressionTracker_sendDefaultImpressionTrackerIfNoImpressionUrl {
    OGAAdExposure *exposure = [[OGAAdExposure alloc] init];
    exposure.exposurePercentage = 75.0f;

    OCMStub([self.impressionManager sendDefaultImpressionTracker:[OCMArg any]]);
    OCMReject([self.impressionManager sendCustomImpressionTracker:[OCMArg any]]);

    OGADelegateDispatcher *delegateDispatcher = OCMClassMock([OGADelegateDispatcher class]);
    OGAAdConfiguration *adConf = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([self.ad adConfiguration]).andReturn(adConf);
    OGAMonitoringDetails *details = OCMClassMock([OGAMonitoringDetails class]);
    OCMStub(adConf.monitoringDetails).andReturn(details);
    OCMStub(details.sessionId).andReturn(@"LKUHIOHN");

    [self.impressionManager sendImpressionTracker:exposure ad:self.ad delegateDispatcher:delegateDispatcher];

    XCTAssertTrue(self.impressionManager.hasSentImpressionTrackByAdId[OGAAdImpressionControllerTestsLocalIdentifier].boolValue);
    OCMVerify([self.impressionManager sendDefaultImpressionTracker:self.ad]);
}

- (void)testSendImpressionTracker_sendCustomImpressionTrackerFormat {
    OGAAdExposure *exposure = [[OGAAdExposure alloc] init];
    exposure.exposurePercentage = 75.0f;

    OGAAdConfiguration *adConf = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([self.ad adConfiguration]).andReturn(adConf);
    OGAMonitoringDetails *details = OCMClassMock([OGAMonitoringDetails class]);
    OCMStub(adConf.monitoringDetails).andReturn(details);
    OCMStub(details.sessionId).andReturn(@"LKUHIOHN");
    OCMStub(self.ad.isImpression).andReturn(YES);
    OCMStub([self.ad isImpressionSourceSDK]).andReturn(NO);
    OCMStub(self.ad.impressionUrl).andReturn(OGAAdImpressionControllerTestsImpressionUrl);
    OCMStub([self.impressionManager sendCustomImpressionTracker:[OCMArg any]]);
    OCMReject([self.impressionManager sendDefaultImpressionTracker:[OCMArg any]]);
    OCMReject([self.delegateDispatcher adImpression]);
    [self.impressionManager sendImpressionTracker:exposure ad:self.ad delegateDispatcher:self.delegateDispatcher];
    XCTAssertTrue(self.impressionManager.hasSentImpressionTrackByAdId[OGAAdImpressionControllerTestsLocalIdentifier].boolValue);
    OCMVerify([self.impressionManager sendCustomImpressionTracker:self.ad]);
    OCMVerify([self.delegateDispatcher displayed]);
}

- (void)testSendImpressionTracker_sendCustomImpressionTrackerSDK {
    OGAAdExposure *exposure = [[OGAAdExposure alloc] init];
    exposure.exposurePercentage = 75.0f;

    OGAAdConfiguration *adConf = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([self.ad adConfiguration]).andReturn(adConf);
    OGAMonitoringDetails *details = OCMClassMock([OGAMonitoringDetails class]);
    OCMStub(adConf.monitoringDetails).andReturn(details);
    OCMStub(details.sessionId).andReturn(@"LKUHIOHN");
    OCMStub(self.ad.isImpression).andReturn(YES);
    OCMStub([self.ad isImpressionSourceSDK]).andReturn(YES);
    OCMStub(self.ad.impressionUrl).andReturn(OGAAdImpressionControllerTestsImpressionUrl);
    OCMStub([self.impressionManager sendCustomImpressionTracker:[OCMArg any]]);
    OCMReject([self.impressionManager sendDefaultImpressionTracker:[OCMArg any]]);
    [self.impressionManager sendImpressionTracker:exposure ad:self.ad delegateDispatcher:self.delegateDispatcher];
    XCTAssertTrue(self.impressionManager.hasSentImpressionTrackByAdId[OGAAdImpressionControllerTestsLocalIdentifier].boolValue);
    OCMVerify([self.impressionManager sendCustomImpressionTracker:self.ad]);
    OCMVerify([self.delegateDispatcher displayed]);
    OCMVerify([self.delegateDispatcher adImpression]);
}

- (void)testSendImpressionTracker_sendCustomImpressionTrackerIfImpressionUrlSet {
    OGAAdExposure *exposure = [[OGAAdExposure alloc] init];
    exposure.exposurePercentage = 75.0f;

    OGAAdConfiguration *adConf = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([self.ad adConfiguration]).andReturn(adConf);
    OGAMonitoringDetails *details = OCMClassMock([OGAMonitoringDetails class]);
    OCMStub(adConf.monitoringDetails).andReturn(details);
    OCMStub(details.sessionId).andReturn(@"LKUHIOHN");
    OCMStub(self.ad.impressionUrl).andReturn(OGAAdImpressionControllerTestsImpressionUrl);
    OCMStub([self.impressionManager sendCustomImpressionTracker:[OCMArg any]]);
    OCMReject([self.impressionManager sendDefaultImpressionTracker:[OCMArg any]]);

    OGADelegateDispatcher *delegateDispatcher = OCMClassMock([OGADelegateDispatcher class]);

    [self.impressionManager sendImpressionTracker:exposure ad:self.ad delegateDispatcher:delegateDispatcher];

    XCTAssertTrue(self.impressionManager.hasSentImpressionTrackByAdId[OGAAdImpressionControllerTestsLocalIdentifier].boolValue);
    OCMVerify([self.impressionManager sendCustomImpressionTracker:self.ad]);
}

- (void)testSendImpressionTracker_doNotSendTrackerTwice {
    OGAAdExposure *exposure = [[OGAAdExposure alloc] init];
    exposure.exposurePercentage = 75.0f;

    OGAAdConfiguration *adConf = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([self.ad adConfiguration]).andReturn(adConf);
    OCMStub(adConf.monitoringDetails.sessionId).andReturn(@"LKUHIOHN");
    self.impressionManager.hasSentImpressionTrackByAdId[OGAAdImpressionControllerTestsLocalIdentifier] = @(YES);
    OCMReject([self.impressionManager sendDefaultImpressionTracker:[OCMArg any]]);

    [self.impressionManager sendImpressionTracker:exposure ad:self.ad delegateDispatcher:OCMOCK_ANY];
}

- (void)testSendDefaultImpressionTracker {
    [self.impressionManager sendDefaultImpressionTracker:self.ad];

    __block OGATrackEvent *event;
    OCMVerify([self.metricsService sendEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                       if ([obj isKindOfClass:[OGATrackEvent class]]) {
                                           event = obj;
                                           return YES;
                                       }
                                       return NO;
                                   }]]);
    XCTAssertNotNil(event);
    XCTAssertEqualObjects(event.advertId, OGAAdImpressionControllerTestsAdvertId);
}

- (void)testSendCustomImpressionTracker_doNotSendIfUrlIsMalformed {
    OCMStub(self.ad.impressionUrl).andReturn(@"malformed url");
    OCMReject([self.networkClient performRequest:[OCMArg any] completionHandler:[OCMArg any]]);

    [self.impressionManager sendCustomImpressionTracker:self.ad];
}

- (void)testHasSentImpressionDelegateFor {
    [self.impressionManager hasSentImpressionDelegateFor:self.ad];
    XCTAssertTrue(self.impressionManager.hasSentImpressionDelegateByAdId[OGAAdImpressionControllerTestsLocalIdentifier].boolValue);
}

- (void)testSendFormatImpressionTrackFor_no_track_by_session_id {
    NSMutableDictionary<NSString *, NSNumber *> *impressionTracksSent = [NSMutableDictionary dictionary];
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    OGAMonitoringDetails *details = OCMClassMock([OGAMonitoringDetails class]);
    OCMStub(adConfiguration.monitoringDetails).andReturn(details);
    OCMStub(details.sessionId).andReturn(@"LKUHIOHN");
    OCMStub(self.ad.adConfiguration).andReturn(adConfiguration);
    OCMStub(self.impressionManager.hasSentImpressionTrackBySessionId).andReturn(impressionTracksSent);
    [self.impressionManager sendFormatImpressionTrackFor:self.ad];
    OCMVerify([self.monitoringDispatcher sendShowEvent:OGAShowEventCreativeDisplayed impressionSource:[OCMArg any] adConfiguration:adConfiguration]);
    OCMVerify([self.monitoringDispatcher sendShowEvent:OGAShowEventDisplayed impressionSource:[OCMArg any] adConfiguration:adConfiguration]);
    OCMVerify([self.monitoringDispatcher sendShowEventForImpressionSource:[OCMArg any] position:@1 adConfiguration:adConfiguration]);
}

- (void)testSendFormatImpressionTrackFor_with_track_by_session_id {
    NSMutableDictionary<NSString *, NSNumber *> *impressionTracksSent = [NSMutableDictionary dictionary];
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    OGAMonitoringDetails *details = OCMClassMock([OGAMonitoringDetails class]);
    OCMStub(adConfiguration.monitoringDetails).andReturn(details);
    OCMStub(details.sessionId).andReturn(@"LKUHIOHN");
    OCMStub(self.ad.adConfiguration).andReturn(adConfiguration);
    NSNumber *order = @1;
    [impressionTracksSent setObject:order forKey:adConfiguration.monitoringDetails.sessionId];
    OCMStub(self.impressionManager.hasSentImpressionTrackBySessionId).andReturn(impressionTracksSent);
    [self.impressionManager sendFormatImpressionTrackFor:self.ad];
    OCMVerify([self.monitoringDispatcher sendShowEvent:OGAShowEventCreativeDisplayed impressionSource:[OCMArg any] adConfiguration:adConfiguration]);
    OCMVerify([self.monitoringDispatcher sendShowEvent:OGAShowEventDisplayed impressionSource:[OCMArg any] adConfiguration:adConfiguration]);
    OCMVerify([self.monitoringDispatcher sendShowEventForImpressionSource:[OCMArg any] position:@2 adConfiguration:adConfiguration]);
}

@end

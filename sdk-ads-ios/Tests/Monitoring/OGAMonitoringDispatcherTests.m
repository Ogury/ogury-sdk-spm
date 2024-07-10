//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "OGAAdConfiguration.h"
#import "OGAAdMonitorEvent.h"
#import "OGAEnvironmentConstants.h"
#import "OGAEnvironmentManager.h"
#import "OGAMetricsService.h"
#import "OGAMonitoringDispatcher.h"
#import "OGAOrderedDictionaryTestHelper.h"
#import "OGMMonitorManager.h"
#import "OguryAdsADType.h"
#import "OGAMonitorEventConfigurationFactory.h"

@interface OGMMonitorEvent ()
@property(nonatomic, retain, nullable) NSDictionary *details;
@property(nonatomic, retain, nullable) NSDictionary *errorContent;
@end

@interface OGAMonitoringDispatcher ()

@property(nonatomic, retain) NSArray<NSString *> *blackListedTracks;
@property(nonatomic, assign) BOOL monitoringEnabled;

- (instancetype)initWithLegacyEventMetrics:(OGAMetricsService *)legacyEventMetrics
                            monitorManager:(OGMMonitorManager *)monitorManager
                        environmentManager:(OGAEnvironmentManager *)environmentManager
                      configurationFactory:(OGAMonitorEventConfigurationFactory *)configurationFactory
                        notificationCenter:(NSNotificationCenter *)notificationCenter;

- (void)sendMonitoringEvent:(OGAAdMonitorEvent *)event;
- (BOOL)isEventBlacklisted:(NSString *)eventCode;

- (void)sendLoadErrorEvent:(OGAMonitoringEvent)event
           adConfiguration:(OGAAdConfiguration *)adConfiguration
           customSessionId:(NSString *_Nullable)sessionId
              errorContent:(OGAOrderedDictionary *_Nullable)errorContent;

- (void)prepareAndSend:(OGAMonitoringEvent)event
       adConfiguration:(OGAAdConfiguration *)adConfiguration
       customSessionId:(NSString *_Nullable)sessionId
               details:(OGAOrderedDictionary *_Nullable)details
          errorContent:(OGAOrderedDictionary *_Nullable)errorContent;

- (OGAOrderedDictionary *)errorContentFor:(OGAMonitoringPrecacheError)precacheErrorType arguments:(NSArray *_Nullable)arguments;
- (NSString *_Nullable)keyForPrecacheErrorType:(OGAMonitoringPrecacheError)precacheErrorType atIndex:(int)index;
- (NSString *)reasonForPrecacheError:(OGAMonitoringPrecacheError)precacheErrorType;

@end

@interface OGAMonitoringDispatcherTests : XCTestCase

@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) OGAMetricsService *legacyEventMetrics;
@property(nonatomic, strong) OGMMonitorManager *monitorManager;
@property(nonatomic, strong) OGAAdConfiguration *adConfiguration;
@property(nonatomic, strong) OGAEnvironmentManager *environmentManager;
@property(nonatomic, strong) NSNotificationCenter *notificationCenter;
@property(nonatomic, strong) OGAMonitorEventConfigurationFactory *configurationFactory;
@property(nonatomic, strong) OGAMonitoringDetails *details;

@end

@implementation OGAMonitoringDispatcherTests

- (void)setUp {
    //   self.formatter              = OCMClassMock([OGAMonitoringEventFormatter class]);
    self.configurationFactory = OCMPartialMock([OGAMonitorEventConfigurationFactory new]);
    self.legacyEventMetrics = OCMClassMock([OGAMetricsService class]);
    self.monitorManager = OCMClassMock([OGMMonitorManager class]);
    self.notificationCenter = OCMClassMock([NSNotificationCenter class]);
    self.environmentManager = OCMClassMock([OGAEnvironmentManager class]);
    self.monitoringDispatcher = OCMPartialMock([[OGAMonitoringDispatcher alloc] initWithLegacyEventMetrics:self.legacyEventMetrics
                                                                                            monitorManager:self.monitorManager
                                                                                        environmentManager:self.environmentManager
                                                                                      configurationFactory:self.configurationFactory
                                                                                        notificationCenter:self.notificationCenter]);
    self.adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    self.details = OCMClassMock([OGAMonitoringDetails class]);
    OCMStub(self.adConfiguration.monitoringDetails).andReturn(self.details);
    OCMStub(self.details.sessionId).andReturn(@"1");
    OCMStub([self.adConfiguration adUnitId]).andReturn(@"ad_unit");
}

- (void)testShared {
    OGAMonitoringDispatcher *monitoringDispatcher = [OGAMonitoringDispatcher shared];
    XCTAssertNotNil(monitoringDispatcher);
    XCTAssertEqualObjects(monitoringDispatcher, [OGAMonitoringDispatcher shared]);
}

- (void)testSetBlackListed {
    NSArray *blackList = @[ @"value1", @"value2" ];
    [self.monitoringDispatcher setBlackListedTracks:blackList];
    XCTAssertEqual(blackList.count, 2);
    XCTAssertEqualObjects(blackList, self.monitoringDispatcher.blackListedTracks);
}

- (void)testSingleSetTrackingMode {
    [self.monitoringDispatcher setTrackingMask:OGATrackingMaskAdsLifeCycle];
    XCTAssertTrue(self.monitoringDispatcher.monitoringEnabled == YES);
}

- (void)testSetTrackingMode {
    [self.monitoringDispatcher setTrackingMask:OGATrackingMaskAdsLifeCycle | OGATrackingMaskCache];
    XCTAssertTrue(self.monitoringDispatcher.monitoringEnabled == YES);
}

- (void)testSetTrackingModeFail {
    [self.monitoringDispatcher setTrackingMask:OGATrackingMaskCache];
    XCTAssertTrue(self.monitoringDispatcher.monitoringEnabled == NO);
}

- (void)testChangeMonitoringUrl {
    OCMStub([self.monitorManager resetMonitors]);
    NSNotification *notification = OCMClassMock([NSNotification class]);
    OCMStub(notification.name).andReturn(OGAEnvironmentChanged);
    [self.monitoringDispatcher didReceiveEnvironmentChange:notification];
    OCMVerify([self.monitorManager resetMonitors]);
    OCMVerify(times(3), [self.monitorManager addMonitor:[OCMArg any]]);
}

- (void)testIsEventBlacklistedFalse {
    NSArray *blackList = @[ @"value1", @"value2" ];
    [self.monitoringDispatcher setBlackListedTracks:blackList];
    XCTAssertFalse([self.monitoringDispatcher isEventBlacklisted:@"yata"]);
}

- (void)testIsEventBlacklistedNil {
    NSArray *blackList = nil;
    [self.monitoringDispatcher setBlackListedTracks:blackList];
    XCTAssertFalse([self.monitoringDispatcher isEventBlacklisted:@"yata"]);
}

- (void)testIsEventBlacklistedTrue {
    NSArray *blackList = @[ @"value1", @"value2", @"yata" ];
    [self.monitoringDispatcher setBlackListedTracks:blackList];
    XCTAssertTrue([self.monitoringDispatcher isEventBlacklisted:@"yata"]);
}

- (void)testSendMonitoringEventTrackingModeAll {
    [self.monitoringDispatcher setTrackingMask:OGATrackingMaskCache | OGATrackingMaskPreCache | OGATrackingMaskAdsLifeCycle];
    [self.monitoringDispatcher sendMonitoringEvent:OCMClassMock([OGAAdMonitorEvent class])];
    OCMVerify([self.monitorManager monitor:[OCMArg any]]);
}

- (void)testSendMonitoringEventTrackingModeLegacy {
    [self.monitoringDispatcher setTrackingMask:OGATrackingMaskAdsLifeCycle];
    [self.monitoringDispatcher sendMonitoringEvent:OCMClassMock([OGAAdMonitorEvent class])];
    OCMVerify([self.monitorManager monitor:[OCMArg any]]);
}

- (void)testSendMonitoringEventTrackingModeCacheLogs {
    [self.monitoringDispatcher setTrackingMask:OGATrackingMaskCache];
    [self.monitoringDispatcher sendMonitoringEvent:OCMClassMock([OGAAdMonitorEvent class])];
    OCMReject([self.monitorManager monitor:[OCMArg any]]);
}

- (void)testSendMonitoringEventTrackingModePreCacheLogs {
    [self.monitoringDispatcher setTrackingMask:OGATrackingMaskPreCache];
    [self.monitoringDispatcher sendMonitoringEvent:OCMClassMock([OGAAdMonitorEvent class])];
    OCMReject([self.monitorManager monitor:[OCMArg any]]);
}

- (void)testSendMonitoringEventTrackingModeOff {
    [self.monitoringDispatcher setTrackingMask:OGATrackingMaskNone];
    OCMReject([self.monitorManager monitor:[OCMArg any]]);
    [self.monitoringDispatcher sendMonitoringEvent:OCMClassMock([OGAAdMonitorEvent class])];
}

- (void)testSendLoadEventConfigurationNotBlackListed {
    OCMStub([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    [self.monitoringDispatcher sendLoadEvent:OGALoadEventLoadSendAdSyncRequest adConfiguration:adConfiguration];
    OCMVerify([self.configurationFactory configurationFor:OGALoadEventLoadSendAdSyncRequest]);
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
}

- (void)testSendLoadEventConfigurationBlackListed {
    OCMStub([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(YES);
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    OCMReject([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    [self.monitoringDispatcher sendLoadEvent:OGALoadEventLoadSendAdSyncRequest adConfiguration:adConfiguration];
}

- (void)testSendLoadPrecachingEventNotBlackListed {
    OCMStub([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    [self.monitoringDispatcher sendLoadEvent:OGALoadEventLoadAdPrecaching adConfiguration:adConfiguration];
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMVerify([self.configurationFactory configurationFor:OGALoadEventLoadAdPrecaching]);
}

- (void)testSendLoadPrecachingEventBlackListed {
    OCMStub([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(YES);
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    OCMReject([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    [self.monitoringDispatcher sendLoadEvent:OGALoadEventLoadAdPrecaching adConfiguration:adConfiguration];
}

- (void)testSendLoadedEventWithloadedSourceNotBlackListed {
    OCMStub([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    [self.monitoringDispatcher sendLoadEvent:OGALoadEventLoadAdLoaded adConfiguration:self.adConfiguration];
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMVerify([self.configurationFactory configurationFor:OGALoadEventLoadAdLoaded]);
}

- (void)testSendLoadPrecacheEventWithNbAdToPrecacheBlacklisted {
    OCMStub([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(YES);
    OCMReject([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    [self.monitoringDispatcher sendLoadEvent:OGALoadEventLoadAdPrecache adConfiguration:self.adConfiguration];
}

- (void)testSendLoadPrecacheEventWithNbAdToPrecacheNotBlacklisted {
    OCMStub([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    [self.monitoringDispatcher sendLoadEvent:OGALoadEventLoadAdPrecache adConfiguration:self.adConfiguration];
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMVerify([self.configurationFactory configurationFor:OGALoadEventLoadAdPrecache]);
}

- (void)testSendLoadedEventWithloadedSourceBlackListed {
    OCMStub([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(YES);
    OCMReject([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    [self.monitoringDispatcher sendLoadEvent:OGALoadEventLoadAdLoaded adConfiguration:self.adConfiguration];
}

- (void)testSendLoadErrorEventBlackListed {
    OCMStub([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(YES);
    OCMReject([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    [self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventSdkNotInitialized adConfiguration:self.adConfiguration];
    OCMVerify([self.configurationFactory configurationFor:OGALoadErrorEventSdkNotInitialized]);
}

- (void)testSendLoadErrorEventNotBlackListed {
    OCMStub([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    [self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventNoInternetConnection adConfiguration:self.adConfiguration];
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMVerify([self.configurationFactory configurationFor:OGALoadErrorEventNoInternetConnection]);
}

- (void)testSendLoadAdErrorEventBlackListed {
    OCMStub([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(YES);
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    OCMReject([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    [self.monitoringDispatcher sendLoadAdErrorEvent:OGALoadErrorEventNoInternetConnection adConfiguration:adConfiguration];
    OCMVerify([self.configurationFactory configurationFor:OGALoadErrorEventNoInternetConnection]);
}

- (void)testSendLoadAdErrorEventNotBlackListed {
    OCMStub([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    [self.monitoringDispatcher sendLoadAdErrorEvent:OGALoadErrorEventNoInternetConnection adConfiguration:adConfiguration];
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMVerify([self.configurationFactory configurationFor:OGALoadErrorEventNoInternetConnection]);
}

- (void)testSendLoadErrorEventWithStackTraceNotBlackListed {
    OCMStub([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    [self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventNoInternetConnection stackTrace:@"stack_trace" adConfiguration:self.adConfiguration];
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMVerify([self.configurationFactory configurationFor:OGALoadErrorEventNoInternetConnection]);
}

- (void)testSendLoadErrorEventWithErrorContent {
    OGAOrderedDictionary *disablingReasonErrorContent = [[OGAOrderedDictionary alloc] initWithDictionary:@{@"disabling_reason" : @"CONSENT_DENIED"}];
    OCMStub([self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventAdDisabled adConfiguration:self.adConfiguration customSessionId:nil errorContent:disablingReasonErrorContent]);
    [self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventAdDisabled adConfiguration:self.adConfiguration errorContent:disablingReasonErrorContent];
    OCMVerify([self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventAdDisabled adConfiguration:self.adConfiguration customSessionId:nil errorContent:disablingReasonErrorContent]);
}

- (void)testSendLoadErrorEventWithCustomSessionIdAndErrorContent {
    OGAOrderedDictionary *disablingReasonErrorContent = [[OGAOrderedDictionary alloc] initWithDictionary:@{@"disabling_reason" : @"CONSENT_DENIED"}];
    NSString *customSessionID = @"session_id";
    OCMStub([self.monitoringDispatcher prepareAndSend:OGALoadErrorEventAdDisabled adConfiguration:self.adConfiguration customSessionId:customSessionID details:[OCMArg any] errorContent:disablingReasonErrorContent]);
    [self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventAdDisabled adConfiguration:self.adConfiguration customSessionId:customSessionID errorContent:disablingReasonErrorContent];
    OCMVerify([self.monitoringDispatcher prepareAndSend:OGALoadErrorEventAdDisabled adConfiguration:self.adConfiguration customSessionId:customSessionID details:[OCMArg any] errorContent:disablingReasonErrorContent]);
}

- (void)testSendLoadErrorEventWithStackTraceBlackListed {
    OCMStub([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(YES);
    OCMReject([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    [self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventInitFail stackTrace:@"stack_trace" adConfiguration:self.adConfiguration];
    OCMVerify([self.configurationFactory configurationFor:OGALoadErrorEventInitFail]);
}

- (void)testSendLoadErrorEventPasingFailWithStackTraceNotBlacklisted {
    OCMStub([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    [self.monitoringDispatcher sendLoadErrorEventParsingFailWithStackTrace:@"stack_trace" adConfiguration:self.adConfiguration];
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMVerify([self.configurationFactory configurationFor:OGALoadErrorEventAdParsingError]);
}

- (void)testSendLoadErrorEventPasingFailWithStackTraceBlacklisted {
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(YES);
    OCMReject([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    [self.monitoringDispatcher sendLoadErrorEventParsingFailWithStackTrace:@"stack_trace" adConfiguration:self.adConfiguration];
    OCMVerify([self.configurationFactory configurationFor:OGALoadErrorEventAdParsingError]);
}

#pragma mark - Show event method

- (void)testSendShowEventWithImpressionSourceBlackListed {
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(YES);
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    OCMReject([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMReject([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]);
    [self.monitoringDispatcher sendShowEvent:OGAShowEventShow impressionSource:@"format" adConfiguration:adConfiguration];
    OCMVerify([self.configurationFactory configurationFor:OGAShowEventShow]);
}

- (void)testSendShowEventWithImpressionSourceNotBlackListed {
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    [self.monitoringDispatcher sendShowEvent:OGAShowEventShow impressionSource:@"format" adConfiguration:adConfiguration];
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMVerify([self.configurationFactory configurationFor:OGAShowEventShow]);
    OCMVerify([self.configurationFactory configurationFor:OGAShowEventShow]);
}

- (void)testSendShowEventBlackListed {
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(YES);
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    OCMReject([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    [self.monitoringDispatcher sendShowEvent:OGAShowEventShow adConfiguration:adConfiguration];
    OCMVerify([self.configurationFactory configurationFor:OGAShowEventShow]);
}

- (void)testSendShowEventNotBlackListed {
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    [self.monitoringDispatcher sendShowEvent:OGAShowEventShow adConfiguration:adConfiguration];
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMVerify([self.configurationFactory configurationFor:OGAShowEventShow]);
    OCMVerify([self.configurationFactory configurationFor:OGAShowEventShow]);
}

- (void)testSendShowEventAllDisplayedBlackListed {
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(YES);
    OCMReject([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    [self.monitoringDispatcher sendShowEventAllDisplayed:@"format" adConfiguration:self.adConfiguration];
    OCMVerify([self.configurationFactory configurationFor:OGAShowEventDisplayed]);
}

- (void)testSendShowEventAllDisplayed_not_blackListed {
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    [self.monitoringDispatcher sendShowEventAllDisplayed:@"format" adConfiguration:self.adConfiguration];
    OCMVerify([self.configurationFactory configurationFor:OGAShowEventDisplayed]);
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMVerify([self.configurationFactory configurationFor:OGAShowEventDisplayed]);
}

- (void)testSendShowEventShowCalledWithNbAdsToShowBlackListed {
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(YES);
    OCMReject([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    [self.monitoringDispatcher sendShowEventShowCalledWithNbAdsToShow:@1 adConfiguration:self.adConfiguration];
    OCMVerify([self.configurationFactory configurationFor:OGAShowEventShow]);
}

- (void)testSendShowEventShowCalledWithNbAdsToShowNotBlackListed {
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    [self.monitoringDispatcher sendShowEventShowCalledWithNbAdsToShow:@1 adConfiguration:self.adConfiguration];
    OCMVerify([self.configurationFactory configurationFor:OGAShowEventShow]);
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMVerify([self.configurationFactory configurationFor:OGAShowEventShow]);
}

- (void)testSendShowEventDisplayBlackListed {
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(YES);
    OCMReject([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    [self.monitoringDispatcher sendShowEventDisplay:@1 adConfiguration:self.adConfiguration];
    OCMVerify([self.configurationFactory configurationFor:OGAShowEventDisplay]);
}

- (void)testSendShowEventDisplayNotBlackListed {
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    [self.monitoringDispatcher sendShowEventDisplay:@1 adConfiguration:self.adConfiguration];
    OCMVerify([self.configurationFactory configurationFor:OGAShowEventDisplay]);
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMVerify([self.configurationFactory configurationFor:OGAShowEventDisplay]);
}

- (void)testSendShowEventsendShowEventForImpressionSourcePositionAdConfigurationBlackListed {
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(YES);
    OCMReject([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    [self.monitoringDispatcher sendShowEventForImpressionSource:@"details" position:@1 adConfiguration:adConfiguration];
    OCMVerify([self.configurationFactory configurationFor:OGAShowEventImpression]);
}

- (void)testSendShowEventsendShowEventForImpressionSourcePositionAdConfigurationNotBlackListed {
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    [self.monitoringDispatcher sendShowEventForImpressionSource:@"details" position:@1 adConfiguration:adConfiguration];
    OCMVerify([self.configurationFactory configurationFor:OGAShowEventImpression]);
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMVerify([self.configurationFactory configurationFor:OGAShowEventImpression]);
}

- (void)testSendShowEventImpressionSourceAdConfigurationBlackListed {
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(YES);
    OCMReject([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    [self.monitoringDispatcher sendShowEvent:OGAShowEventImpression impressionSource:@"format" adConfiguration:adConfiguration];
    OCMVerify([self.configurationFactory configurationFor:OGAShowEventImpression]);
}

- (void)testSendShowEventImpressionSourceAdConfigurationNotBlackListed {
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    [self.monitoringDispatcher sendShowEvent:OGAShowEventImpression impressionSource:@"format" adConfiguration:adConfiguration];
    OCMVerify([self.configurationFactory configurationFor:OGAShowEventImpression]);
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMVerify([self.configurationFactory configurationFor:OGAShowEventImpression]);
}

- (void)testSendShowEventContainerDisplayedWithImpressionSourceBlackListed {
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(YES);
    OCMReject([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    [self.monitoringDispatcher sendShowEventContainerDisplayedWithImpressionSource:@"format" exposure:@100 adConfiguration:adConfiguration];
    OCMVerify([self.configurationFactory configurationFor:OGAShowEventContainerDisplayed]);
}

- (void)testSendShowEventContainerDisplayedWithImpressionSourceNotBlackListed {
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    [self.monitoringDispatcher sendShowEventContainerDisplayedWithImpressionSource:@"format" exposure:@100 adConfiguration:adConfiguration];
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMVerify([self.configurationFactory configurationFor:OGAShowEventContainerDisplayed]);
    OCMVerify([self.configurationFactory configurationFor:OGAShowEventContainerDisplayed]);
}

- (void)testSendShowErrorEventBlackListed {
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(YES);
    OCMReject([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    [self.monitoringDispatcher sendShowErrorEvent:OGAShowErrorEventAdDisabled adConfiguration:self.adConfiguration];
    OCMVerify([self.configurationFactory configurationFor:OGAShowErrorEventAdDisabled]);
}

- (void)testSendShowErrorEventNotBlackListed {
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    [self.monitoringDispatcher sendShowErrorEvent:OGAShowErrorEventAdDisabled adConfiguration:self.adConfiguration];
    OCMVerify([self.configurationFactory configurationFor:OGAShowErrorEventAdDisabled]);
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
}

- (void)testSendShowErrorEventAdExpiredBlackListed {
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(YES);
    OCMReject([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OGAExpirationContext *context = OCMPartialMock([[OGAExpirationContext alloc] initFrom:OGAdExpirationSourceProfig withExpirationTime:@10]);
    [self.monitoringDispatcher sendShowErrorEventAdExpired:self.adConfiguration context:context];
    OCMVerify([self.configurationFactory configurationFor:OGAShowErrorEventAdExpired]);
}

- (void)testSendShowErrorEventAdExpiredNotBlackListed {
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    OGAExpirationContext *context = OCMPartialMock([[OGAExpirationContext alloc] initFrom:OGAdExpirationSourceProfig withExpirationTime:@10]);
    [self.monitoringDispatcher sendShowErrorEventAdExpired:self.adConfiguration context:context];
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMVerify([self.configurationFactory configurationFor:OGAShowErrorEventAdExpired]);
}

- (void)testSendShowErrorEventAdExpiredNotBlackListedSourceProfigTimeSpan {
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    OGAExpirationContext *context = OCMPartialMock([[OGAExpirationContext alloc] initFrom:OGAdExpirationSourceProfig withExpirationTime:@10]);
    [self.monitoringDispatcher sendShowErrorEventAdExpired:self.adConfiguration context:context];
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMVerify([self.configurationFactory configurationFor:OGAShowErrorEventAdExpired]);
}

- (void)testWhenLoadedEventWithloadedSourceEventIsSentThenDetailsAreOrderedAsExpected {
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    OCMStub(self.details.loadedSource).andReturn(@"format");
    [self.monitoringDispatcher sendLoadEvent:OGALoadEventLoadAdLoaded adConfiguration:self.adConfiguration];

    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                             OGAAdMonitorEvent *event = (OGAAdMonitorEvent *)obj;
                                             OGAMutableOrderedDictionary *details = (OGAMutableOrderedDictionary *)event.details;
                                             return [OGAOrderedDictionaryTestHelper testDictionary:details against:@"{\"from_ad_markup\":false,\"loaded_source\":\"format\",\"reload\":false}"];
                                         }]]);
}

- (void)testWhenLoadedEventForReloadedTrackIsSentThenDetailsAreOrderedAsExpected {
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    OCMStub(self.details.reloaded).andReturn(YES);
    OCMStub(self.details.loadedSource).andReturn(@"format");
    [self.monitoringDispatcher sendLoadEvent:OGALoadEventLoadAdLoaded adConfiguration:self.adConfiguration];

    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                             OGAAdMonitorEvent *event = (OGAAdMonitorEvent *)obj;
                                             OGAMutableOrderedDictionary *details = (OGAMutableOrderedDictionary *)event.details;
                                             return [OGAOrderedDictionaryTestHelper testDictionary:details against:@"{\"from_ad_markup\":false,\"loaded_source\":\"format\",\"reload\":true}"];
                                         }]]);
}

- (void)testWhenLoadErrorEventWithStackTraceEventIsSentThenErrorContentIsOrderedAsExpected {
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    [self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventNoInternetConnection stackTrace:@"stack_trace" adConfiguration:self.adConfiguration];

    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                             OGAAdMonitorEvent *event = (OGAAdMonitorEvent *)obj;
                                             OGAMutableOrderedDictionary *errorContent = (OGAMutableOrderedDictionary *)event.errorContent;
                                             return [OGAOrderedDictionaryTestHelper testDictionary:errorContent against:@"{\"reason\":\"No Internet connection\",\"stacktrace\":\"stack_trace\"}"];
                                         }]]);
}

- (void)testWhenLoadErrorEventParsingFailWithStackTraceEventIsSentThenErrorContentIsOrderedAsExpected {
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    [self.monitoringDispatcher sendLoadErrorEventParsingFailWithStackTrace:@"stack_trace" adConfiguration:self.adConfiguration];

    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                             OGAAdMonitorEvent *event = (OGAAdMonitorEvent *)obj;
                                             OGAMutableOrderedDictionary *errorContent = (OGAMutableOrderedDictionary *)event.errorContent;
                                             return [OGAOrderedDictionaryTestHelper testDictionary:errorContent against:@"{\"reason\":\"Ad response parsing has failed\",\"stacktrace\":\"stack_trace\"}"];
                                         }]]);
}

- (void)testWhenShowEventForImpressionSourceEventIsSentThenDetailsAreOrderedAsExpected {
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    [self.monitoringDispatcher sendShowEventForImpressionSource:@"details" position:@1 adConfiguration:adConfiguration];

    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                             OGAAdMonitorEvent *event = (OGAAdMonitorEvent *)obj;
                                             OGAMutableOrderedDictionary *details = (OGAMutableOrderedDictionary *)event.details;
                                             return [OGAOrderedDictionaryTestHelper testDictionary:details against:@"{\"from_ad_markup\":false,\"impression_source\":\"details\",\"reload\":false}"];
                                         }]]);
}

- (void)testWhenShowEventContainerDisplayedWithImpressionSourceEventIsSentThenDetailsAreOrderedAsExpected {
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    [self.monitoringDispatcher sendShowEventContainerDisplayedWithImpressionSource:@"format" exposure:@100 adConfiguration:adConfiguration];

    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                             OGAAdMonitorEvent *event = (OGAAdMonitorEvent *)obj;
                                             OGAMutableOrderedDictionary *details = (OGAMutableOrderedDictionary *)event.details;
                                             return [OGAOrderedDictionaryTestHelper testDictionary:details against:@"{\"exposure\":100,\"from_ad_markup\":false,\"impression_source\":\"format\",\"reload\":false}"];
                                         }]]);
}

- (void)testReasonsForPrecacheErrors {
    XCTAssertEqualObjects([self.monitoringDispatcher reasonForPrecacheError:OGAMonitoringPrecacheErrorHtmlEmpty], @"The ad HTML is empty");
    XCTAssertEqualObjects([self.monitoringDispatcher reasonForPrecacheError:OGAMonitoringPrecacheErrorUnload], @"Ad unloaded");
    XCTAssertEqualObjects([self.monitoringDispatcher reasonForPrecacheError:OGAMonitoringPrecacheErrorTimeOut], @"Timeout");
    XCTAssertEqualObjects([self.monitoringDispatcher reasonForPrecacheError:OGAMonitoringPrecacheErrorHtmlLoadFailed], @"Webview ad content embedding error");
    XCTAssertEqualObjects([self.monitoringDispatcher reasonForPrecacheError:OGAMonitoringPrecacheErrorMraidDownloadFailed], @"Mraid file failed to download");
}

- (void)testKeysForPrecacheErrors {
    XCTAssertEqualObjects([self.monitoringDispatcher keyForPrecacheErrorType:OGAMonitoringPrecacheErrorTimeOut atIndex:0], @"accomplished");
    XCTAssertEqualObjects([self.monitoringDispatcher keyForPrecacheErrorType:OGAMonitoringPrecacheErrorTimeOut atIndex:1], @"time_span");
    XCTAssertEqualObjects([self.monitoringDispatcher keyForPrecacheErrorType:OGAMonitoringPrecacheErrorTimeOut atIndex:2], @"timeout_duration");
    XCTAssertNil([self.monitoringDispatcher keyForPrecacheErrorType:OGAMonitoringPrecacheErrorTimeOut atIndex:3]);
    XCTAssertEqualObjects([self.monitoringDispatcher keyForPrecacheErrorType:OGAMonitoringPrecacheErrorMraidDownloadFailed atIndex:0], @"url");
    XCTAssertEqualObjects([self.monitoringDispatcher keyForPrecacheErrorType:OGAMonitoringPrecacheErrorMraidDownloadFailed atIndex:1], @"stacktrace");
    XCTAssertNil([self.monitoringDispatcher keyForPrecacheErrorType:OGAMonitoringPrecacheErrorMraidDownloadFailed atIndex:2]);
    XCTAssertNil([self.monitoringDispatcher keyForPrecacheErrorType:OGAMonitoringPrecacheErrorUnload atIndex:0]);
    XCTAssertNil([self.monitoringDispatcher keyForPrecacheErrorType:OGAMonitoringPrecacheErrorHtmlEmpty atIndex:0]);
    XCTAssertNil([self.monitoringDispatcher keyForPrecacheErrorType:OGAMonitoringPrecacheErrorHtmlLoadFailed atIndex:0]);
}

- (void)testWhenRetrievingErrorContentForPrecacheTimeOutThenAllValuesAreSet {
    OGAMonitoringDispatcher *sut = [[OGAMonitoringDispatcher alloc] initWithLegacyEventMetrics:self.legacyEventMetrics
                                                                                monitorManager:self.monitorManager
                                                                            environmentManager:self.environmentManager
                                                                          configurationFactory:self.configurationFactory
                                                                            notificationCenter:self.notificationCenter];
    OGAOrderedDictionary *dict = [sut errorContentFor:OGAMonitoringPrecacheErrorTimeOut arguments:@[ @"1", @"2", @"3" ]];
    XCTAssertEqual(dict.count, 4);
    XCTAssertEqualObjects(dict[@"reason"], @"Timeout");
    XCTAssertEqualObjects(dict[@"accomplished"], @"1");
    XCTAssertEqualObjects(dict[@"time_span"], @"2");
    XCTAssertEqualObjects(dict[@"timeout_duration"], @"3");
}

- (void)testWhenRetrievingErrorContentForPrecacheMraidThenAllValuesAreSet {
    OGAMonitoringDispatcher *sut = [[OGAMonitoringDispatcher alloc] initWithLegacyEventMetrics:self.legacyEventMetrics
                                                                                monitorManager:self.monitorManager
                                                                            environmentManager:self.environmentManager
                                                                          configurationFactory:self.configurationFactory
                                                                            notificationCenter:self.notificationCenter];
    OGAOrderedDictionary *dict = [sut errorContentFor:OGAMonitoringPrecacheErrorMraidDownloadFailed arguments:@[ @"1", @"2" ]];
    XCTAssertEqual(dict.count, 3);
    XCTAssertEqualObjects(dict[@"reason"], @"Mraid file failed to download");
    XCTAssertEqualObjects(dict[@"url"], @"1");
    XCTAssertEqualObjects(dict[@"stacktrace"], @"2");
}

- (void)testWhenRetrievingErrorContentForPrecacheEmptyHtmlThenAllValuesAreSet {
    OGAMonitoringDispatcher *sut = [[OGAMonitoringDispatcher alloc] initWithLegacyEventMetrics:self.legacyEventMetrics
                                                                                monitorManager:self.monitorManager
                                                                            environmentManager:self.environmentManager
                                                                          configurationFactory:self.configurationFactory
                                                                            notificationCenter:self.notificationCenter];
    OGAOrderedDictionary *dict = [sut errorContentFor:OGAMonitoringPrecacheErrorHtmlEmpty arguments:nil];
    XCTAssertEqual(dict.count, 1);
    XCTAssertEqualObjects(dict[@"reason"], @"The ad HTML is empty");
}

- (void)testWhenRetrievingErrorContentForPrecacheBadHtmlThenAllValuesAreSet {
    OGAMonitoringDispatcher *sut = [[OGAMonitoringDispatcher alloc] initWithLegacyEventMetrics:self.legacyEventMetrics
                                                                                monitorManager:self.monitorManager
                                                                            environmentManager:self.environmentManager
                                                                          configurationFactory:self.configurationFactory
                                                                            notificationCenter:self.notificationCenter];
    OGAOrderedDictionary *dict = [sut errorContentFor:OGAMonitoringPrecacheErrorHtmlLoadFailed arguments:nil];
    XCTAssertEqual(dict.count, 1);
    XCTAssertEqualObjects(dict[@"reason"], @"Webview ad content embedding error");
}

- (void)testWhenRetrievingErrorContentForPrecacheUnloadThenAllValuesAreSet {
    OGAMonitoringDispatcher *sut = [[OGAMonitoringDispatcher alloc] initWithLegacyEventMetrics:self.legacyEventMetrics
                                                                                monitorManager:self.monitorManager
                                                                            environmentManager:self.environmentManager
                                                                          configurationFactory:self.configurationFactory
                                                                            notificationCenter:self.notificationCenter];
    OGAOrderedDictionary *dict = [sut errorContentFor:OGAMonitoringPrecacheErrorUnload arguments:nil];
    XCTAssertEqual(dict.count, 1);
    XCTAssertEqualObjects(dict[@"reason"], @"Ad unloaded");
}
@end

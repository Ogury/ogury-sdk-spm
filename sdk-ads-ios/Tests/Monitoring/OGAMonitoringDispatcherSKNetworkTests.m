//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "OGAAdMonitorEvent.h"
#import "OGAEnvironmentManager.h"
#import "OGAMetricsService.h"
#import "OGAMonitoringDispatcher+SKNetwork.h"
#import "OGAOrderedDictionaryTestHelper.h"
#import "OGMMonitorManager.h"
#import "OGAMonitorEventConfigurationFactory.h"

@interface OGAMonitoringDispatcher (Tests)

@property(nonatomic, retain) OGAMonitoringDispatcher *monitoringDispatcher;

- (instancetype)initWithLegacyEventMetrics:(OGAMetricsService *)legacyEventMetrics
                            monitorManager:(OGMMonitorManager *)monitorManager
                        environmentManager:(OGAEnvironmentManager *)environmentManager
                      configurationFactory:(OGAMonitorEventConfigurationFactory *)configurationFactory
                        notificationCenter:(NSNotificationCenter *)notificationCenter;

- (void)sendMonitoringEvent:(OGAAdMonitorEvent *)event;

- (BOOL)isEventBlacklisted:(NSString *)eventCode;

@end

@interface OGAMonitoringDispatcherSKNetworkTests : XCTestCase

@property(nonatomic, retain) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) OGAMonitorEventConfigurationFactory *configurationFactory;
@property(nonatomic, strong) OGAMetricsService *legacyEventMetrics;
@property(nonatomic, retain) OGAMetricsService *metricsService;
@property(nonatomic, retain) OGMMonitorManager *monitorManager;
@property(nonatomic, retain) OGAEnvironmentManager *environmentManager;
@property(nonatomic, retain) NSNotificationCenter *notificationCenter;

@end

@interface OGMMonitorEvent ()

@property(nonatomic, retain, nullable) NSDictionary *details;
@property(nonatomic, retain, nullable) NSDictionary *errorContent;

@end

@implementation OGAMonitoringDispatcherSKNetworkTests

- (void)setUp {
    self.configurationFactory = OCMPartialMock([OGAMonitorEventConfigurationFactory new]);
    self.legacyEventMetrics = OCMClassMock([OGAMetricsService class]);
    self.metricsService = OCMClassMock([OGAMetricsService class]);
    self.monitorManager = OCMClassMock([OGMMonitorManager class]);
    self.environmentManager = OCMClassMock([OGAEnvironmentManager class]);
    self.notificationCenter = OCMClassMock([NSNotificationCenter class]);
    self.monitoringDispatcher = OCMPartialMock([[OGAMonitoringDispatcher alloc] initWithLegacyEventMetrics:self.legacyEventMetrics
                                                                                            monitorManager:self.monitorManager
                                                                                        environmentManager:self.environmentManager
                                                                                      configurationFactory:self.configurationFactory
                                                                                        notificationCenter:self.notificationCenter]);
}

- (void)testSendSKNetworkLoadStoreControllerEvent_YES {
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    NSString *nonce = @"68753A44-4D6F-1226-9C60-0050E4C00067";
    NSNumber *itunesItemId = @124456;
    OCMStub([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    [self.monitoringDispatcher sendSKNetworkLoadStoreControllerEvent:OGASKNetworkLoadEventStoreViewControllerLoaded nonce:nonce itunesItemId:itunesItemId adConfiguration:adConfiguration];
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
}

- (void)testSendSKNetworkLoadStoreControllerEvent_NO {
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    NSString *nonce = @"68753A44-4D6F-1226-9C60-0050E4C00067";
    NSNumber *itunesItemId = @124456;
    OCMStub([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(YES);
    OCMReject([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    [self.monitoringDispatcher sendSKNetworkLoadStoreControllerEvent:OGASKNetworkLoadEventStoreViewControllerLoaded nonce:nonce itunesItemId:itunesItemId adConfiguration:adConfiguration];
}

- (void)testSendSKNetworkImpressionEvent_YES {
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    NSNumber *advertisedAppStoreItemIdentifier = @124456;
    OCMStub([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    [self.monitoringDispatcher sendSKNetworkImpressionEvent:OGASKNetworkShowEventStartingImpression advertisedAppStoreItemIdentifier:advertisedAppStoreItemIdentifier adConfiguration:adConfiguration];
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
}

- (void)testSendSKNetworkImpressionEvent_NO {
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    NSNumber *advertisedAppStoreItemIdentifier = @124456;
    OCMStub([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(YES);
    OCMReject([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    [self.monitoringDispatcher sendSKNetworkImpressionEvent:OGASKNetworkShowEventStartingImpression advertisedAppStoreItemIdentifier:advertisedAppStoreItemIdentifier adConfiguration:adConfiguration];
}

- (void)testSendSKNetworkFailedLoadStoreControllerEvent_YES {
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    NSString *nonce = @"68753A44-4D6F-1226-9C60-0050E4C00067";
    NSNumber *itunesItemId = @124456;
    OCMStub([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    [self.monitoringDispatcher sendSKNetworkFailedLoadStoreControllerEvent:OGASKNetworkLoadErrorEventFailedLoadingStoreController nonce:nonce itunesItemId:itunesItemId adConfiguration:adConfiguration];
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
}

- (void)testSendSKNetworkFailedLoadStoreControllerEvent_NO {
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    NSString *nonce = @"68753A44-4D6F-1226-9C60-0050E4C00067";
    NSNumber *itunesItemId = @124456;
    OCMStub([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(YES);
    OCMReject([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    [self.monitoringDispatcher sendSKNetworkFailedLoadStoreControllerEvent:OGASKNetworkLoadErrorEventFailedLoadingStoreController nonce:nonce itunesItemId:itunesItemId adConfiguration:adConfiguration];
}

- (void)testSendSKNetworkFailedImpressionEvent_YES {
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    NSNumber *advertisedAppStoreItemIdentifier = @124456;
    OCMStub([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    [self.monitoringDispatcher sendSKNetworkFailedImpressionEvent:OGASKNetworkShowErrorEventFailedToStartImpression
                                 advertisedAppStoreItemIdentifier:advertisedAppStoreItemIdentifier
                                                  adConfiguration:adConfiguration];
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
}

- (void)testSendSKNetworkFailedImpressionEvent_NO {
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    NSNumber *advertisedAppStoreItemIdentifier = @124456;
    OCMStub([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(YES);
    OCMReject([self.monitoringDispatcher sendMonitoringEvent:[OCMArg any]]);
    [self.monitoringDispatcher sendSKNetworkFailedImpressionEvent:OGASKNetworkShowErrorEventFailedToStartImpression
                                 advertisedAppStoreItemIdentifier:advertisedAppStoreItemIdentifier
                                                  adConfiguration:adConfiguration];
}

- (void)testWhenSKNetworkFailedLoadStoreControllerEventIsSentThenDetailsAreOrderedAsExpected {
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    NSString *nonce = @"68753A44-4D6F-1226-9C60-0050E4C00067";
    NSNumber *itunesItemId = @124456;
    [self.monitoringDispatcher sendSKNetworkLoadStoreControllerEvent:OGASKNetworkLoadEventStoreViewControllerLoaded
                                                               nonce:nonce
                                                        itunesItemId:itunesItemId
                                                     adConfiguration:adConfiguration];

    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                             OGAAdMonitorEvent *event = (OGAAdMonitorEvent *)obj;
                                             OGAMutableOrderedDictionary *details = (OGAMutableOrderedDictionary *)event.details;
                                             return [OGAOrderedDictionaryTestHelper testDictionary:details against:@"{\"from_ad_markup\":false,\"itunesItemId\":124456,\"nonce\":\"68753A44-4D6F-1226-9C60-0050E4C00067\",\"reload\":false}"];
                                         }]]);
}

- (void)testWhenSKNetworkLoadStoreControllerEventIsSentThenErrorContentIsOrderedAsExpected {
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    NSString *nonce = @"68753A44-4D6F-1226-9C60-0050E4C00067";
    NSNumber *itunesItemId = @124456;
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    [self.monitoringDispatcher sendSKNetworkFailedLoadStoreControllerEvent:OGASKNetworkLoadErrorEventFailedLoadingStoreController nonce:nonce itunesItemId:itunesItemId adConfiguration:adConfiguration];

    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                             OGAAdMonitorEvent *event = (OGAAdMonitorEvent *)obj;
                                             OGAMutableOrderedDictionary *errorContent = (OGAMutableOrderedDictionary *)event.errorContent;
                                             return [OGAOrderedDictionaryTestHelper
                                                 testDictionary:errorContent
                                                        against:@"{\"itunesItemId\":124456,\"nonce\":\"68753A44-4D6F-1226-9C60-0050E4C00067\",\"reason\":\"Error during presentation of StoreKit\"}"];
                                         }]]);
}

- (void)testWhenSKNetworkFailedImpressionEventIsSentThenErrorContentIsOrderedAsExpected {
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    NSNumber *advertisedAppStoreItemIdentifier = @124456;
    OCMStub([self.monitoringDispatcher isEventBlacklisted:[OCMArg any]]).andReturn(NO);
    [self.monitoringDispatcher sendSKNetworkFailedImpressionEvent:OGASKNetworkShowErrorEventFailedToStartImpression
                                 advertisedAppStoreItemIdentifier:advertisedAppStoreItemIdentifier
                                                  adConfiguration:adConfiguration];

    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                             OGAAdMonitorEvent *event = (OGAAdMonitorEvent *)obj;
                                             OGAMutableOrderedDictionary *errorContent = (OGAMutableOrderedDictionary *)event.errorContent;
                                             return [OGAOrderedDictionaryTestHelper testDictionary:errorContent
                                                                                           against:@"{\"advertisedAppStoreItemIdentifier\":124456,\"reason\":\"Failed to notify StoreKit of starting the impression\"}"];
                                         }]]);
}

@end

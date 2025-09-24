//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "OGAAdConfiguration.h"
#import "OGAAdMonitorEvent.h"
#import "OGADelegateDispatcher.h"
#import "OGAEnvironmentConstants.h"
#import "OGAEnvironmentManager.h"
#import "OGAExpirationContext.h"
#import "OGAMetricsService.h"
#import "OGAMonitoringDispatcher.h"
#import "OGMMonitorManager.h"
#import "OguryAdsADType.h"
#import "OGALog.h"
#import "OguryThumbnailAdDelegateDispatcher.h"
#import "NSDate+OGAFormatter.h"
#import "OGAMonitorEventConfigurationFactory.h"

@interface OGAAdMonitorEvent ()
- (instancetype)initWithTimestamp:(NSNumber *)timestamp
                        sessionId:(NSString *)sessionId
                        eventCode:(NSString *)eventCode
                        eventName:(NSString *)eventName
                     dispatchType:(OGMDispatchType)dispatchType
                         adUnitId:(NSString *)adUnitId
                        mediation:(OguryMediation *)mediation
                       campaignId:(NSString *_Nullable)campaignId
                       creativeId:(NSString *_Nullable)creativeId
                           extras:(NSArray *_Nullable)extras
                detailsDictionary:(NSDictionary *_Nullable)detailsDictionary
                        errorType:(NSString *_Nullable)errorType
                     errorContent:(NSDictionary *)errorContent;
@end

@interface OGAMonitoringDispatcher ()

- (instancetype)initWithLegacyEventMetrics:(OGAMetricsService *)legacyEventMetrics
                            monitorManager:(OGMMonitorManager *)monitorManager
                        environmentManager:(OGAEnvironmentManager *)environmentManager
                      configurationFactory:(OGAMonitorEventConfigurationFactory *)configurationFactory
                                       log:(OGALog *)log
                        notificationCenter:(NSNotificationCenter *)notificationCenter;

- (void)sendMonitoringEvent:(OGAAdMonitorEvent *)event;

- (NSNumber *)getTimestampInMilliseconds;

@end

@interface OGAMonitoringDispatcherJSONTests : XCTestCase

@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) OGAMonitorEventConfigurationFactory *configurationFactory;
@property(nonatomic, strong) OGAMetricsService *legacyEventMetrics;
@property(nonatomic, strong) OGMMonitorManager *monitorManager;
@property(nonatomic, retain) OGAAdConfiguration *adConfiguration;
@property(nonatomic, retain) OGAMonitoringDetails *monitoringDetails;
@property(nonatomic, retain) OGAExpirationContext *expirationContext;
@property(nonatomic, strong) OGAEnvironmentManager *environmentManager;
@property(nonatomic, strong) NSNotificationCenter *notificationCenter;
@property(nonatomic, strong) NSArray *extras;
@property(nonatomic, strong) OGALog *log;

@end

@implementation OGAMonitoringDispatcherJSONTests

- (void)setUp {
    self.configurationFactory = OCMPartialMock([OGAMonitorEventConfigurationFactory new]);
    self.legacyEventMetrics = OCMClassMock([OGAMetricsService class]);
    self.monitorManager = OCMClassMock([OGMMonitorManager class]);
    self.notificationCenter = OCMClassMock([NSNotificationCenter class]);
    self.environmentManager = OCMClassMock([OGAEnvironmentManager class]);
    self.log = OCMClassMock([OGALog class]);
    self.monitoringDispatcher = OCMPartialMock([[OGAMonitoringDispatcher alloc] initWithLegacyEventMetrics:self.legacyEventMetrics
                                                                                            monitorManager:self.monitorManager
                                                                                        environmentManager:self.environmentManager
                                                                                      configurationFactory:self.configurationFactory
                                                                                                       log:self.log
                                                                                        notificationCenter:self.notificationCenter]);
    [self.monitoringDispatcher setTrackingMask:OGATrackingMaskAdsLifeCycle];
    [self.monitoringDispatcher setBlackListedTracks:@[]];
    OCMStub([OCMClassMock([NSDate class]) timestampInMilliseconds]).andReturn(@1234);
    [self setUpAdConfiguration];
    self.expirationContext = OCMPartialMock([[OGAExpirationContext alloc] initFrom:OGAdExpirationSourceAd withExpirationTime:@1]);
    OCMStub([self.expirationContext timeSpan]).andReturn(@2);
}

- (void)setUpAdConfiguration {
    OguryThumbnailAdDelegateDispatcher *delegateDispatcher = OCMClassMock([OguryThumbnailAdDelegateDispatcher class]);
    self.adConfiguration = OCMPartialMock([[OGAAdConfiguration alloc] initWithType:OguryAdsTypeThumbnailAd
                                                                          adUnitId:@"adUnitId"
                                                                delegateDispatcher:delegateDispatcher
                                                            viewControllerProvider:^UIViewController *_Nonnull {
                                                                return nil;
                                                            }]);
    self.monitoringDetails = OCMClassMock([OGAMonitoringDetails class]);
    OCMStub(self.adConfiguration.monitoringDetails).andReturn(self.monitoringDetails);
    OCMStub(self.monitoringDetails.sessionId).andReturn(@"sessionId");
    OCMStub([self.adConfiguration campaignId]).andReturn(@"campaignId");
    OCMStub([self.adConfiguration creativeId]).andReturn(@"creativeId");
    NSDictionary *firstDictionnary = @{@"name" : @"dsp", @"value" : @"{\"creative_id\": \"123\", \"region\":\"east-us\"}", @"version" : @2};
    NSDictionary *secondDictionnary = @{@"name" : @"vast_version", @"value" : @"4.0", @"version" : @1};
    self.extras = @[ firstDictionnary, secondDictionnary ];
    OCMStub(self.adConfiguration.extras).andReturn(self.extras);
}

- (void)testSendLoadEventEnvelopeNoAdSync {
    OCMStub([self.adConfiguration adMarkupSync]).andReturn(nil);
    NSDictionary *detail = @{@"from_ad_markup" : @NO, @"reload" : @NO};
    [self.monitoringDispatcher sendLoadEvent:OGALoadEventLoad adConfiguration:self.adConfiguration];
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                             OGAAdMonitorEvent *event = (OGAAdMonitorEvent *)obj;
                                             OGAAdMonitorEvent *loadEvent = [[OGAAdMonitorEvent alloc] initWithTimestamp:@1234
                                                                                                               sessionId:@"sessionId"
                                                                                                               eventCode:@"LI-001"
                                                                                                               eventName:@"SDK_EVENT_LOAD"
                                                                                                            dispatchType:OGMDispatchTypeImmediate
                                                                                                                adUnitId:@"adUnitId"
                                                                                                               mediation:nil
                                                                                                              campaignId:nil
                                                                                                              creativeId:nil
                                                                                                                  extras:nil
                                                                                                       detailsDictionary:detail
                                                                                                               errorType:nil
                                                                                                            errorContent:nil];
                                             return [event isEqual:loadEvent];
                                         }]]);
}

- (void)testSendLoadEventEnvelopeWithAdSync {
    OCMStub([self.adConfiguration isHeaderBidding]).andReturn(true);
    OCMStub(self.monitoringDetails.reloaded).andReturn(NO);
    NSDictionary *detail = @{@"from_ad_markup" : @YES, @"reload" : @NO};
    [self.monitoringDispatcher sendLoadEvent:OGALoadEventLoad adConfiguration:self.adConfiguration];
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                             OGAAdMonitorEvent *event = (OGAAdMonitorEvent *)obj;
                                             OGAAdMonitorEvent *loadEvent = [[OGAAdMonitorEvent alloc] initWithTimestamp:@1234
                                                                                                               sessionId:@"sessionId"
                                                                                                               eventCode:@"LI-001"
                                                                                                               eventName:@"SDK_EVENT_LOAD"
                                                                                                            dispatchType:OGMDispatchTypeImmediate
                                                                                                                adUnitId:@"adUnitId"
                                                                                                               mediation:nil
                                                                                                              campaignId:nil
                                                                                                              creativeId:nil
                                                                                                                  extras:nil
                                                                                                       detailsDictionary:detail
                                                                                                               errorType:nil
                                                                                                            errorContent:nil];
                                             return [event isEqual:loadEvent];
                                         }]]);
}

- (void)testSendLoadErrorEventWithStackTraceEnvelope {
    [self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventNoInternetConnection stackTrace:@"failed to find any ads from ad markup" adConfiguration:self.adConfiguration];
    NSDictionary *detail = @{@"from_ad_markup" : @NO, @"reload" : @NO};

    NSDictionary *errorContent = @{@"reason" : @"No Internet connection", @"stacktrace" : @"failed to find any ads from ad markup"};

    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                             OGAAdMonitorEvent *event = (OGAAdMonitorEvent *)obj;
                                             OGAAdMonitorEvent *loadEvent = [[OGAAdMonitorEvent alloc] initWithTimestamp:@1234
                                                                                                               sessionId:@"sessionId"
                                                                                                               eventCode:@"LE-001"
                                                                                                               eventName:@"SDK_EVENT_LOAD_ERROR"
                                                                                                            dispatchType:OGMDispatchTypeImmediate
                                                                                                                adUnitId:@"adUnitId"
                                                                                                               mediation:nil
                                                                                                              campaignId:nil
                                                                                                              creativeId:nil
                                                                                                                  extras:nil
                                                                                                       detailsDictionary:detail
                                                                                                               errorType:@"CONDITIONS_NOT_MET"
                                                                                                            errorContent:errorContent];
                                             return [event isEqual:loadEvent];
                                         }]]);
}

- (void)testSendShowErrorEventEnvelope {
    [self.monitoringDispatcher sendShowErrorEvent:OGAShowErrorEventNoAdLoaded adConfiguration:self.adConfiguration];

    NSDictionary *errorContent = @{@"reason" : @"No ad loaded"};
    NSDictionary *detail = @{@"from_ad_markup" : @NO, @"reload" : @NO};

    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                             OGAAdMonitorEvent *event = (OGAAdMonitorEvent *)obj;
                                             OGAAdMonitorEvent *loadEvent = [[OGAAdMonitorEvent alloc] initWithTimestamp:@1234
                                                                                                               sessionId:@"sessionId"
                                                                                                               eventCode:@"SE-004"
                                                                                                               eventName:@"SDK_EVENT_SHOW_ERROR"
                                                                                                            dispatchType:OGMDispatchTypeImmediate
                                                                                                                adUnitId:@"adUnitId"
                                                                                                               mediation:nil
                                                                                                              campaignId:nil
                                                                                                              creativeId:nil
                                                                                                                  extras:nil
                                                                                                       detailsDictionary:detail
                                                                                                               errorType:@"PRECACHE_ERROR"
                                                                                                            errorContent:errorContent];
                                             return [event isEqual:loadEvent];
                                         }]]);
}

#warning Temporarly deactivated to avoid jenkins random build failure
- (void)testSendLoadErrorEventEnvelope {
    [self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventNoFill adConfiguration:self.adConfiguration];

    NSDictionary *errorContent = @{@"reason" : @"No ad received"};
    NSDictionary *detail = @{@"from_ad_markup" : @NO, @"reload" : @NO};

    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                             OGAAdMonitorEvent *event = (OGAAdMonitorEvent *)obj;
                                             OGAAdMonitorEvent *loadEvent = [[OGAAdMonitorEvent alloc] initWithTimestamp:@1234
                                                                                                               sessionId:@"sessionId"
                                                                                                               eventCode:@"LE-011"
                                                                                                               eventName:@"SDK_EVENT_LOAD_ERROR"
                                                                                                            dispatchType:OGMDispatchTypeImmediate
                                                                                                                adUnitId:@"adUnitId"
                                                                                                               mediation:nil
                                                                                                              campaignId:nil
                                                                                                              creativeId:nil
                                                                                                                  extras:nil
                                                                                                       detailsDictionary:detail
                                                                                                               errorType:@"ADSYNC_ERROR"
                                                                                                            errorContent:errorContent];
                                             return [event isEqual:loadEvent];
                                         }]]);
}

- (void)testSendLoadPrecacheEventEnvelopeNoAdSync {
    OCMStub(self.monitoringDetails.loadedSource).andReturn(@"format");
    [self.monitoringDispatcher sendLoadEvent:OGALoadEventLoadAdLoaded adConfiguration:self.adConfiguration];
    NSDictionary *details = @{
        @"from_ad_markup" : @NO,
        @"loaded_source" : @"format",
        @"reload" : @NO
    };

    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                             OGAAdMonitorEvent *event = (OGAAdMonitorEvent *)obj;
                                             OGAAdMonitorEvent *loadEvent = [[OGAAdMonitorEvent alloc] initWithTimestamp:@1234
                                                                                                               sessionId:@"sessionId"
                                                                                                               eventCode:@"LI-009"
                                                                                                               eventName:@"SDK_EVENT_LOADED"
                                                                                                            dispatchType:OGMDispatchTypeImmediate
                                                                                                                adUnitId:@"adUnitId"
                                                                                                               mediation:nil
                                                                                                              campaignId:@"campaignId"
                                                                                                              creativeId:@"creativeId"
                                                                                                                  extras:self.extras
                                                                                                       detailsDictionary:details
                                                                                                               errorType:nil
                                                                                                            errorContent:nil];
                                             return [event isEqual:loadEvent];
                                         }]]);
}

- (void)testSendBackgroundUnLoadEventEnvelope {
    NSDictionary *detail = @{@"from_ad_markup" : @NO, @"reload" : @NO};
    [self.monitoringDispatcher sendLoadEvent:OGALoadEventLoadAdBackgroundUnloaded adConfiguration:self.adConfiguration];
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                             OGAAdMonitorEvent *event = (OGAAdMonitorEvent *)obj;
                                             OGAAdMonitorEvent *loadEvent = [[OGAAdMonitorEvent alloc] initWithTimestamp:@1234
                                                                                                               sessionId:@"sessionId"
                                                                                                               eventCode:@"LI-010"
                                                                                                               eventName:@"SDK_EVENT_BACKGROUND_UNLOAD"
                                                                                                            dispatchType:OGMDispatchTypeImmediate
                                                                                                                adUnitId:@"adUnitId"
                                                                                                               mediation:nil
                                                                                                              campaignId:@"campaignId"
                                                                                                              creativeId:@"creativeId"
                                                                                                                  extras:self.extras
                                                                                                       detailsDictionary:detail
                                                                                                               errorType:nil
                                                                                                            errorContent:nil];
                                             return [event isEqual:loadEvent];
                                         }]]);
}

- (void)testSendShowAllDisplayedEventEnvelopeNoAdSync {
    NSDictionary *detail = @{@"from_ad_markup" : @NO, @"reload" : @NO};
    [self.monitoringDispatcher sendShowEventAllDisplayed:@"format" adConfiguration:self.adConfiguration];

    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                             OGAAdMonitorEvent *event = (OGAAdMonitorEvent *)obj;
                                             OGAAdMonitorEvent *loadEvent = [[OGAAdMonitorEvent alloc] initWithTimestamp:@1234
                                                                                                               sessionId:@"sessionId"
                                                                                                               eventCode:@"SI-006"
                                                                                                               eventName:@"SDK_EVENT_AD_DISPLAYED"
                                                                                                            dispatchType:OGMDispatchTypeImmediate
                                                                                                                adUnitId:@"adUnitId"
                                                                                                               mediation:nil
                                                                                                              campaignId:@"campaignId"
                                                                                                              creativeId:@"creativeId"
                                                                                                                  extras:self.extras
                                                                                                       detailsDictionary:detail
                                                                                                               errorType:nil
                                                                                                            errorContent:nil];
                                             return [event isEqual:loadEvent];
                                         }]]);
}

- (void)testSendShowEventShowCalledWithNbAdsToShowEnvelopeNoAdSync {
    [self.monitoringDispatcher sendShowEventShowCalledWithNbAdsToShow:@1 adConfiguration:self.adConfiguration];
    NSDictionary *detail = @{@"from_ad_markup" : @NO, @"reload" : @NO};

    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                             OGAAdMonitorEvent *event = (OGAAdMonitorEvent *)obj;
                                             OGAAdMonitorEvent *loadEvent = [[OGAAdMonitorEvent alloc] initWithTimestamp:@1234
                                                                                                               sessionId:@"sessionId"
                                                                                                               eventCode:@"SI-001"
                                                                                                               eventName:@"SDK_EVENT_SHOW"
                                                                                                            dispatchType:OGMDispatchTypeImmediate
                                                                                                                adUnitId:@"adUnitId"
                                                                                                               mediation:nil
                                                                                                              campaignId:@"campaignId"
                                                                                                              creativeId:@"creativeId"
                                                                                                                  extras:self.extras
                                                                                                       detailsDictionary:detail
                                                                                                               errorType:nil
                                                                                                            errorContent:nil];
                                             return [event isEqual:loadEvent];
                                         }]]);
}

- (void)testSendLoadErrorEventNoFill {
    [self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventNoFill adConfiguration:self.adConfiguration];
    NSDictionary *detail = @{@"from_ad_markup" : @NO, @"reload" : @NO};

    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                             OGAAdMonitorEvent *event = (OGAAdMonitorEvent *)obj;
                                             OGAAdMonitorEvent *loadEvent = [[OGAAdMonitorEvent alloc] initWithTimestamp:@1234
                                                                                                               sessionId:@"sessionId"
                                                                                                               eventCode:@"LE-011"
                                                                                                               eventName:@"SDK_EVENT_LOAD_ERROR"
                                                                                                            dispatchType:OGMDispatchTypeImmediate
                                                                                                                adUnitId:@"adUnitId"
                                                                                                               mediation:nil
                                                                                                              campaignId:nil
                                                                                                              creativeId:nil
                                                                                                                  extras:nil
                                                                                                       detailsDictionary:detail
                                                                                                               errorType:@"ADSYNC_ERROR"
                                                                                                            errorContent:@{@"reason" : @"No ad received"}];
                                             return [event isEqual:loadEvent];
                                         }]]);
}

- (void)testSendShowErrorEventAdExpiredEventEnvelope {
    OGAExpirationContext *context = OCMClassMock([OGAExpirationContext class]);
    OCMStub(context.expirationTime).andReturn(@1);
    OCMStub(context.timeSpan).andReturn(@2);
    OCMStub(context.expirationSource).andReturn(OGAdExpirationSourceAd);
    [self.monitoringDispatcher sendShowErrorEventAdExpired:self.adConfiguration context:context];

    NSDictionary *errorContent = @{
        @"expiration_source" : @"ad",
        @"expiration_time" : @1,
        @"reason" : @"Ad expired",
        @"time_span" : @2
    };
    NSDictionary *detail = @{
        @"from_ad_markup" : @NO,
        @"reload" : @NO,
    };

    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                             OGAAdMonitorEvent *event = (OGAAdMonitorEvent *)obj;
                                             OGAAdMonitorEvent *loadEvent = [[OGAAdMonitorEvent alloc] initWithTimestamp:@1234
                                                                                                               sessionId:@"sessionId"
                                                                                                               eventCode:@"SE-002"
                                                                                                               eventName:@"SDK_EVENT_SHOW_ERROR"
                                                                                                            dispatchType:OGMDispatchTypeImmediate
                                                                                                                adUnitId:@"adUnitId"
                                                                                                               mediation:nil
                                                                                                              campaignId:@"campaignId"
                                                                                                              creativeId:@"creativeId"
                                                                                                                  extras:self.extras
                                                                                                       detailsDictionary:detail
                                                                                                               errorType:@"CONFIG_RESTRICTIONS"
                                                                                                            errorContent:errorContent];
                                             return [event isEqual:loadEvent];
                                         }]]);
}

// MARK: - CustomSessionId
- (void)testSendShowErrorEventEnvelopeWithoutCustomSessionId {
    [self.monitoringDispatcher sendShowErrorEvent:OGAShowErrorEventAdExpired adConfiguration:self.adConfiguration customSessionId:nil];
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                             OGAAdMonitorEvent *event = (OGAAdMonitorEvent *)obj;
                                             return [[event valueForKey:@"sessionId"] isEqual:@"sessionId"];
                                         }]]);
}

- (void)testSendShowErrorEventEnvelopeForSessionId {
    [self.monitoringDispatcher sendShowErrorEvent:OGAShowErrorEventAdExpired adConfiguration:self.adConfiguration];
    OCMVerify([self.monitoringDispatcher sendShowErrorEvent:OGAShowErrorEventAdExpired adConfiguration:self.adConfiguration customSessionId:nil]);
}

- (void)testSendShowErrorEventEnvelopeWithCustomSessionId {
    [self.monitoringDispatcher sendShowErrorEvent:OGAShowErrorEventAdExpired adConfiguration:self.adConfiguration customSessionId:@"customSessionId"];
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                             OGAAdMonitorEvent *event = (OGAAdMonitorEvent *)obj;
                                             return [[event valueForKey:@"sessionId"] isEqual:@"customSessionId"];
                                         }]]);
}

- (void)testSendShowEventShowCalledWithNbAdsToShowEventEnvelopeWithoutCustomSessionId {
    [self.monitoringDispatcher sendShowEventShowCalledWithNbAdsToShow:@1 adConfiguration:self.adConfiguration customSessionId:nil];
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                             OGAAdMonitorEvent *event = (OGAAdMonitorEvent *)obj;
                                             return [[event valueForKey:@"sessionId"] isEqual:@"sessionId"];
                                         }]]);
}

- (void)testSendShowEventShowCalledWithNbAdsToShowEventEnvelopeForSessionId {
    [self.monitoringDispatcher sendShowEventShowCalledWithNbAdsToShow:@1 adConfiguration:self.adConfiguration];
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                             OGAAdMonitorEvent *event = (OGAAdMonitorEvent *)obj;
                                             return [[event valueForKey:@"sessionId"] isEqual:@"sessionId"];
                                         }]]);
}

- (void)testSendShowEventShowCalledWithNbAdsToShowEventEnvelopeWithCustomSessionId {
    [self.monitoringDispatcher sendShowEventShowCalledWithNbAdsToShow:@1 adConfiguration:self.adConfiguration customSessionId:@"customSessionId"];
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                             OGAAdMonitorEvent *event = (OGAAdMonitorEvent *)obj;
                                             return [[event valueForKey:@"sessionId"] isEqual:@"customSessionId"];
                                         }]]);
}

- (void)testSendLoadErrorEventEnvelopeWithoutCustomSessionId {
    [self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventNoFill adConfiguration:self.adConfiguration customSessionId:nil];
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                             OGAAdMonitorEvent *event = (OGAAdMonitorEvent *)obj;
                                             return [[event valueForKey:@"sessionId"] isEqual:@"sessionId"];
                                         }]]);
}

- (void)testSendLoadErrorEventEnvelopeForSessionId {
    [self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventNoFill adConfiguration:self.adConfiguration];
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                             OGAAdMonitorEvent *event = (OGAAdMonitorEvent *)obj;
                                             return [[event valueForKey:@"sessionId"] isEqual:@"sessionId"];
                                         }]]);
}

- (void)testSendLoadrrorEventEnvelopeWithCustomSessionId {
    [self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventNoFill adConfiguration:self.adConfiguration customSessionId:@"customSessionId"];
    OCMVerify([self.monitoringDispatcher sendMonitoringEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                             OGAAdMonitorEvent *event = (OGAAdMonitorEvent *)obj;
                                             return [[event valueForKey:@"sessionId"] isEqual:@"customSessionId"];
                                         }]]);
}

@end

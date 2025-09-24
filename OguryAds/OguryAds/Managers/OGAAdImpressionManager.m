//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import "OGAAdImpressionManager.h"

#import <OguryCore/OguryNetworkClient.h>
#import <OguryCore/OguryNetworkRequestBuilder.h>

#import "OGAMetricsService.h"
#import "NSString+OGAUtility.h"
#import "OGATrackEvent.h"
#import "OGALog.h"
#import "OGADelegateDispatcher.h"
#import "OGAAd+ImpressionSource.h"
#import "OGASKAdNetworkManager.h"
#import "OGAMonitoringDispatcher.h"
#import "OGAAd+ImpressionSource.h"

CGFloat const OGAAdImpressionControllerMinExposureForImpression = 50.0F;

@interface OGAAdImpressionManager ()

@property(nonatomic, strong) OGAMetricsService *metricsService;
@property(nonatomic, strong) OguryNetworkClient *networkClient;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;

@property(atomic, strong) NSMutableDictionary<NSString *, NSNumber *> *hasSentImpressionTrackByAdId;
@property(atomic, strong) NSMutableDictionary<NSString *, NSNumber *> *hasSentImpressionDelegateByAdId;
@property(atomic, strong) NSMutableDictionary<NSString *, NSNumber *> *hasSentImpressionTrackBySessionId;

@end

@implementation OGAAdImpressionManager

#pragma mark - Initialization

+ (instancetype)shared {
    static OGAAdImpressionManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    return [self initWithMetricsService:[OGAMetricsService shared]
                          networkClient:[OguryNetworkClient shared]
                                    log:[OGALog shared]
                   monitoringDispatcher:[OGAMonitoringDispatcher shared]];
}

- (instancetype)initWithMetricsService:(OGAMetricsService *)metricsService
                         networkClient:(OguryNetworkClient *)networkClient
                                   log:(OGALog *)log
                  monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher {
    if (self = [super init]) {
        _metricsService = metricsService;
        _networkClient = networkClient;
        _hasSentImpressionTrackByAdId = [[NSMutableDictionary alloc] init];
        _hasSentImpressionDelegateByAdId = [[NSMutableDictionary alloc] init];
        _hasSentImpressionTrackBySessionId = [[NSMutableDictionary alloc] init];
        _log = log;
        _monitoringDispatcher = monitoringDispatcher;
    }
    return self;
}

#pragma mark - Methods

- (void)sendIfNecessaryAfterExposureChanged:(OGAAdExposure *)exposure
                                         ad:(OGAAd *)ad
                         delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher
                                  displayer:(id<OGAAdDisplayer>)displayer {
    if (exposure.exposurePercentage >= OGAAdImpressionControllerMinExposureForImpression) {
        [self sendImpressionTracker:exposure ad:ad delegateDispatcher:delegateDispatcher displayer:displayer];
    }
}

- (void)sendImpressionTracker:(OGAAdExposure *)exposure
                           ad:(OGAAd *)ad
           delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher
                    displayer:(id<OGAAdDisplayer>)displayer {
    @synchronized(self) {
        // We use the localIdentifier instead of the identifier due to a server bug that causes
        // the identifier to used twice.

        if (!self.hasSentImpressionTrackByAdId[ad.localIdentifier].boolValue) {
            [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                                 adConfiguration:ad.adConfiguration
                                                         logType:OguryLogTypeInternal
                                                         message:@"Sending SHOWN track for ad"
                                                            tags:nil]];

            self.hasSentImpressionTrackByAdId[ad.localIdentifier] = @(YES);
            if (![NSString ogaIsNilOrEmpty:ad.impressionUrl]) {
                [self sendCustomImpressionTracker:ad];
            } else {
                [self sendDefaultImpressionTracker:ad];
            }

            [[OGASKAdNetworkManager shared] startImpressionWithAd:ad];

            if (![self.hasSentImpressionTrackBySessionId objectForKey:ad.adConfiguration.monitoringDetails.sessionId]) {
                self.hasSentImpressionTrackBySessionId[ad.adConfiguration.monitoringDetails.sessionId] = @(0);
                [self.monitoringDispatcher sendShowEventContainerDisplayedWithImpressionSource:[ad getRawImpressionSource]
                                                                                      exposure:@(exposure.exposurePercentage)
                                                                               adConfiguration:ad.adConfiguration];
                // Ad Quality : we create the controller here to handle profig changes and updates since Impression Manager is only created once for every Ad created
                [displayer performQualityChecks];
            }

            if ([ad isImpressionSourceSDK]) {
                [self.monitoringDispatcher sendShowEvent:OGAShowEventDisplayed
                                        impressionSource:[ad getRawImpressionSource]
                                         adConfiguration:ad.adConfiguration];
            }

            if (ad.isImpression && [ad isImpressionSourceSDK] && ![self isImpressionDelegateSentFor:ad]) {
                self.hasSentImpressionDelegateByAdId[ad.localIdentifier] = @(YES);

                [self.monitoringDispatcher sendShowEventForImpressionSource:[ad getRawImpressionSource]
                                                                   position:self.hasSentImpressionTrackBySessionId[ad.adConfiguration.monitoringDetails.sessionId]
                                                            adConfiguration:ad.adConfiguration];
                [delegateDispatcher adImpression];
            }
        }
    }
}

- (BOOL)isImpressionDelegateSentFor:(OGAAd *)ad {
    return self.hasSentImpressionDelegateByAdId[ad.localIdentifier].boolValue;
}

- (void)hasSentImpressionDelegateFor:(OGAAd *)ad {
    self.hasSentImpressionDelegateByAdId[ad.localIdentifier] = @(YES);
}

- (void)sendDefaultImpressionTracker:(OGAAd *)ad {
    [self.metricsService sendEvent:[[OGATrackEvent alloc] initWithAd:ad event:OGAMetricsEventShown]];
}

- (void)sendCustomImpressionTracker:(OGAAd *)ad {
    [self.metricsService sendTrackEventForAd:ad withURL:ad.impressionUrl];
}

- (void)sendFormatImpressionTrackFor:(OGAAd *)ad {
    if (![self.hasSentImpressionTrackBySessionId objectForKey:ad.adConfiguration.monitoringDetails.sessionId]) {
        self.hasSentImpressionTrackBySessionId[ad.adConfiguration.monitoringDetails.sessionId] = @(0);
    }

    self.hasSentImpressionTrackBySessionId[ad.adConfiguration.monitoringDetails.sessionId] = @(self.hasSentImpressionTrackBySessionId[ad.adConfiguration.monitoringDetails.sessionId].intValue + 1);

    [self.monitoringDispatcher sendShowEvent:OGAShowEventCreativeDisplayed
                            impressionSource:[ad getRawImpressionSource]
                             adConfiguration:ad.adConfiguration];

    [self.monitoringDispatcher sendShowEvent:OGAShowEventDisplayed
                            impressionSource:[ad getRawImpressionSource]
                             adConfiguration:ad.adConfiguration];

    [self.monitoringDispatcher sendShowEventForImpressionSource:[ad getRawImpressionSource]
                                                       position:self.hasSentImpressionTrackBySessionId[ad.adConfiguration.monitoringDetails.sessionId]
                                                adConfiguration:ad.adConfiguration];
}
@end

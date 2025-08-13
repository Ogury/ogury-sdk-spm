//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import "OGAMonitoringDispatcher.h"
#import <Foundation/Foundation.h>
#import "NSDate+OGAFormatter.h"
#import "OGAAdMonitorEvent.h"
#import "OGAAdServerMonitorRequestBuilder.h"
#import "OGAEnvironmentConstants.h"
#import "OGAEnvironmentManager.h"
#import "OGAExpirationContext.h"
#import "OGAMetricsService.h"
#import "OGAOrderedDictionary.h"
#import "OGAProfigManager.h"
#import "OGMEventPersistanceStore.h"
#import "OGMMonitorManager.h"
#import "OGMOSLogMonitor.h"
#import "OGMServerMonitor.h"
#import "OGALog.h"
#import "OGAMonitoringLogMessage.h"
#import "OGAMonitorEventConfigurationFactory.h"

@interface OGAMonitoringDispatcher ()

@property(nonatomic, strong) OGAMonitorEventConfigurationFactory *configurationFactory;
@property(nonatomic, strong) OGMMonitorManager *monitorManager;
@property(nonatomic, strong) OGAMetricsService *legacyEventMetrics;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic) BOOL monitoringEnabled;
@property(nonatomic, strong, nullable) NSArray<NSString *> *blackListedTracks;
@property(nonatomic, assign) OGAEnvironmentManager *environmentManager;
@property(nonatomic, assign) NSNotificationCenter *notificationCenter;

/// This method creates an event from the permissions of OGAMonitorEventConfigurationFactory,
/// it adds the OGAMonitoringErrorEventContentReason to errorContent if it is an error,
/// cheks if the event is not blacklisted
/// and finally sends the event to all Monitorables
/// - Parameters:
///   - event: the event to handle
///   - adConfiguration: the associated ad configuration
///   - sessionId: custom sessions Id to use. It will use ``adConfiguration.sessionId`` if nil
///   - details: the details dictionary if any
///   - errorContent: the error content dictionary if any
///
/// - Warning it adds the OGAMonitoringErrorEventContentReason to errorContent if it is an error
- (void)prepareAndSend:(OGAMonitoringEvent)event
       adConfiguration:(OGAAdConfiguration *)adConfiguration
       customSessionId:(NSString *_Nullable)sessionId
               details:(OGAOrderedDictionary *_Nullable)details
          errorContent:(OGAOrderedDictionary *_Nullable)errorContent;
@end

@implementation OGAMonitoringDispatcher

+ (instancetype)shared {
    static OGAMonitoringDispatcher *instance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[OGAMonitoringDispatcher alloc] initWithLegacyEventMetrics:OGAMetricsService.shared
                                                                monitorManager:[[OGMMonitorManager alloc] init]
                                                            environmentManager:OGAEnvironmentManager.shared
                                                          configurationFactory:OGAMonitorEventConfigurationFactory.shared
                                                                           log:[OGALog shared]
                                                            notificationCenter:NSNotificationCenter.defaultCenter];
    });
    return instance;
}

- (instancetype)initWithLegacyEventMetrics:(OGAMetricsService *)legacyEventMetrics
                            monitorManager:(OGMMonitorManager *)monitorManager
                        environmentManager:(OGAEnvironmentManager *)environmentManager
                      configurationFactory:(OGAMonitorEventConfigurationFactory *)configurationFactory
                                       log:(OGALog *)log
                        notificationCenter:(NSNotificationCenter *)notificationCenter {
    if (self = [self init]) {
        _configurationFactory = configurationFactory;
        _legacyEventMetrics = legacyEventMetrics;
        _monitorManager = monitorManager;
        _blackListedTracks = [OGAProfigFullResponse defaultBlackList];
        _monitoringEnabled = YES;
        _environmentManager = environmentManager;
        _log = log;
        [_monitorManager addMonitor:[[OGMServerMonitor alloc] initWithRequestBuilder:[[OGAAdServerMonitorRequestBuilder alloc] initWithUrl:_environmentManager.monitoringURL]
                                                                    persistanceStore:[[OGMEventPersistanceStore alloc] init]]];
        _notificationCenter = notificationCenter;
        [_notificationCenter addObserver:self selector:@selector(didReceiveEnvironmentChange:) name:OGAEnvironmentChanged object:nil];
    }
    return self;
}

- (void)didReceiveEnvironmentChange:(NSNotification *)notification {
    [self.monitorManager resetMonitors];
    [self.monitorManager addMonitor:[[OGMServerMonitor alloc] initWithRequestBuilder:[[OGAAdServerMonitorRequestBuilder alloc] initWithUrl:self.environmentManager.monitoringURL]
                                                                    persistanceStore:[[OGMEventPersistanceStore alloc] init]]];
}

- (void)setBlackListedTracks:(NSArray<NSString *> *)blackListed {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                         adConfiguration:nil
                                                 logType:OguryLogTypeMonitoring
                                                 message:@"Set Blacklist"
                                                    tags:@[ [OguryLogTag tagWithKey:@"blacklit" value:blackListed] ]]];
    _blackListedTracks = blackListed;
}

- (void)setTrackingMask:(OGATrackingMask)trackingMask {
    self.monitoringEnabled = trackingMask & OGATrackingMaskAdsLifeCycle;
}

- (BOOL)isEventBlacklisted:(NSString *)eventCode {
    if (self.blackListedTracks == nil) {
        return NO;
    }
    return [self.blackListedTracks containsObject:eventCode];
}

- (void)sendMonitoringEvent:(OGAAdMonitorEvent *)event {
    [self.log log:[[OGAMonitoringLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                                 adConfiguration:event.adConfiguration
                                                         message:@"Handle event"
                                                           event:event]];
    if (self.monitoringEnabled) {
        [self.monitorManager monitor:event];
    }
}

- (void)prepareAndSend:(OGAMonitoringEvent)event
       adConfiguration:(OGAAdConfiguration *)adConfiguration
       customSessionId:(NSString *_Nullable)sessionId
               details:(OGAOrderedDictionary *_Nullable)details
          errorContent:(OGAOrderedDictionary *_Nullable)errorContent {
    OGAMonitorEventConfiguration *eventConfiguration = [self.configurationFactory configurationFor:event];
    if (eventConfiguration == nil) {
        return;
    }
    if ([self isEventBlacklisted:eventConfiguration.eventCode]) {
        [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                             adConfiguration:nil
                                                     logType:OguryLogTypeMonitoring
                                                     message:[NSString stringWithFormat:@"Event (%ld) is blacklisted", event]
                                                        tags:nil]];
        return;
    }
    // add reload and fromAdMarkUp fields
    OGAMutableOrderedDictionary *detailsDictionary = details == nil ? [OGAMutableOrderedDictionary new] : [details mutableCopy];
    detailsDictionary[OGAMonitoringEventDetailFromAdMarkUp] = adConfiguration.isHeaderBidding ? @YES : @NO;
    detailsDictionary[OGAMonitorEventBodyReload] = adConfiguration.monitoringDetails.reloaded ? @YES : @NO;
    if (adConfiguration.numberOfWebviewTerminatedReloadAttempts > 0 && detailsDictionary[OGAMonitoringEventDetailWebviewTermination] == nil) {
        detailsDictionary[OGAMonitoringEventDetailWebviewTermination] = @(adConfiguration.numberOfWebviewTerminatedReloadAttempts);
    }
    if (adConfiguration.monitoringDetails.loadedSource != nil) {
        detailsDictionary[OGAMonitoringEventDetailLoadedSource] = adConfiguration.monitoringDetails.loadedSource;
    }
    [detailsDictionary sort];

    // add the error description if available
    if (eventConfiguration.errorDescription != nil) {
        OGAMutableOrderedDictionary *mutableDict = [errorContent mutableCopy] ?: [OGAMutableOrderedDictionary new];
        if (errorContent[OGAMonitoringErrorEventContentReason] == nil) {
            mutableDict[OGAMonitoringErrorEventContentReason] = eventConfiguration.errorDescription;
        }
        [mutableDict sort];
        errorContent = mutableDict;
    }
    OGAAdMonitorEvent *monitorable = [[OGAAdMonitorEvent alloc] initWithEventConfiguration:eventConfiguration
                                                                           adConfiguration:adConfiguration
                                                                           customSessionId:sessionId
                                                                         detailsDictionary:detailsDictionary
                                                                              errorContent:errorContent];
    [self sendMonitoringEvent:monitorable];
}

#pragma mark - Load event method
- (void)sendLoadEvent:(OGAMonitoringEvent)event adConfiguration:(OGAAdConfiguration *)adConfiguration {
    [self sendLoadEvent:event adConfiguration:adConfiguration details:nil];
}

- (void)sendLoadEvent:(OGAMonitoringEvent)event
      adConfiguration:(OGAAdConfiguration *)adConfiguration
              details:(NSDictionary *_Nullable)details {
    [self prepareAndSend:event
         adConfiguration:adConfiguration
         customSessionId:nil
                 details:details == nil ? nil : [[OGAMutableOrderedDictionary alloc] initWithDictionary:details]
            errorContent:nil];
}

#pragma mark - Load error event method

- (void)sendLoadErrorEvent:(OGAMonitoringEvent)event adConfiguration:(OGAAdConfiguration *)adConfiguration {
    [self sendLoadErrorEvent:event adConfiguration:adConfiguration errorContent:nil];
}

- (void)sendLoadErrorEvent:(OGAMonitoringEvent)event adConfiguration:(nonnull OGAAdConfiguration *)adConfiguration customSessionId:(NSString *_Nullable)sessionId {
    [self sendLoadErrorEvent:event adConfiguration:adConfiguration customSessionId:sessionId errorContent:nil];
}

- (void)sendLoadErrorEvent:(OGAMonitoringEvent)event adConfiguration:(OGAAdConfiguration *)adConfiguration errorContent:(OGAOrderedDictionary *_Nullable)errorContent {
    [self sendLoadErrorEvent:event adConfiguration:adConfiguration customSessionId:nil errorContent:errorContent];
}

- (void)sendLoadErrorEvent:(OGAMonitoringEvent)event adConfiguration:(OGAAdConfiguration *)adConfiguration customSessionId:(NSString *_Nullable)sessionId errorContent:(OGAOrderedDictionary *_Nullable)errorContent {
    [self prepareAndSend:event
         adConfiguration:adConfiguration
         customSessionId:sessionId
                 details:nil
            errorContent:errorContent];
}

- (void)sendLoadAdErrorEvent:(OGAMonitoringEvent)event adConfiguration:(OGAAdConfiguration *)adConfiguration {
    [self prepareAndSend:event
         adConfiguration:adConfiguration
         customSessionId:nil
                 details:nil
            errorContent:nil];
}

- (void)sendLoadErrorEvent:(OGAMonitoringEvent)event
                stackTrace:(NSString *)stacktrace
           adConfiguration:(OGAAdConfiguration *)adConfiguration {
    OGAMutableOrderedDictionary *errorContent = [OGAMutableOrderedDictionary new];
    errorContent[OGAMonitoringErrorEventContentStacktrace] = stacktrace;

    [self prepareAndSend:event
         adConfiguration:adConfiguration
         customSessionId:nil
                 details:nil
            errorContent:errorContent];
}

- (void)sendLoadErrorEventPrecacheFail:(OGAMonitoringPrecacheError)precacheErrorType
                       adConfiguration:(OGAAdConfiguration *)adConfiguration {
    [self sendLoadErrorEventPrecacheFail:precacheErrorType adConfiguration:adConfiguration arguments:nil];
}
- (void)sendLoadErrorEventPrecacheFail:(OGAMonitoringPrecacheError)precacheErrorType
                       adConfiguration:(OGAAdConfiguration *)adConfiguration
                             arguments:(NSArray *_Nullable)args {
    [self prepareAndSend:OGALoadErrorEventPrecacheError
         adConfiguration:adConfiguration
         customSessionId:nil
                 details:nil
            errorContent:[self errorContentFor:precacheErrorType arguments:args]];
}

- (OGAOrderedDictionary *)errorContentFor:(OGAMonitoringPrecacheError)precacheErrorType arguments:(NSArray *_Nullable)args {
    OGAMutableOrderedDictionary *errorContent = [[OGAMutableOrderedDictionary alloc] init];
    errorContent[OGAMonitoringErrorEventContentReason] = [self reasonForPrecacheError:precacheErrorType];
    for (int index = 0; index < args.count; index++) {
        NSString *key = [self keyForPrecacheErrorType:precacheErrorType atIndex:index];
        if (key) {
            errorContent[key] = args[index];
        }
    }
    return errorContent;
}

- (NSString *_Nullable)keyForPrecacheErrorType:(OGAMonitoringPrecacheError)precacheErrorType atIndex:(int)index {
    switch (precacheErrorType) {
        case OGAMonitoringPrecacheErrorTimeOut:
            switch (index) {
                case 0:
                    return OGAMonitoringErrorEventContentAccomplished;
                case 1:
                    return OGAMonitoringErrorEventContentTimeSpan;
                case 2:
                    return OGAMonitoringErrorEventContentTimeoutDuration;
                default:
                    return nil;
            }

        case OGAMonitoringPrecacheErrorMraidDownloadFailed:
            switch (index) {
                case 0:
                    return OGAMonitoringErrorEventContentUrl;
                case 1:
                    return OGAMonitoringErrorEventContentStacktrace;
                default:
                    return nil;
            }

        default:
            return nil;
    }
}

- (NSString *)reasonForPrecacheError:(OGAMonitoringPrecacheError)precacheErrorType {
    switch (precacheErrorType) {
        case OGAMonitoringPrecacheErrorHtmlEmpty:
            return @"The ad HTML is empty";

        case OGAMonitoringPrecacheErrorTimeOut:
            return @"Timeout";

        case OGAMonitoringPrecacheErrorHtmlLoadFailed:
            return @"Webview ad content embedding error";

        case OGAMonitoringPrecacheErrorUnload:
            return @"Ad unloaded";

        case OGAMonitoringPrecacheErrorMraidDownloadFailed:
            return @"Mraid file failed to download";
    }
}

- (void)sendLoadErrorEventParsingFailWithStackTrace:(NSString *)stacktrace adConfiguration:(OGAAdConfiguration *)adConfiguration {
    OGAMutableOrderedDictionary *errorContent = [OGAMutableOrderedDictionary new];
    errorContent[OGAMonitoringErrorEventContentStacktrace] = stacktrace;
    errorContent[OGAMonitoringErrorEventContentReason] = adConfiguration.monitoringDetails.fromAdMarkUp ? @"Ad markup parsing has failed" : @"Ad response parsing has failed";
    [self prepareAndSend:OGALoadErrorEventAdParsingError
         adConfiguration:adConfiguration
         customSessionId:nil
                 details:nil
            errorContent:errorContent];
}

#pragma mark - Show event method

- (void)sendShowEvent:(OGAMonitoringEvent)event adConfiguration:(OGAAdConfiguration *)adConfiguration {
    [self prepareAndSend:event
         adConfiguration:adConfiguration
         customSessionId:nil
                 details:nil
            errorContent:nil];
}

- (void)sendShowEventAllDisplayed:(NSString *)impressionSource adConfiguration:(OGAAdConfiguration *)adConfiguration {
    [self prepareAndSend:OGAShowEventDisplayed
         adConfiguration:adConfiguration
         customSessionId:nil
                 details:nil
            errorContent:nil];
}

- (void)sendShowEventShowCalledWithNbAdsToShow:(NSNumber *)nbAdsToShow adConfiguration:(OGAAdConfiguration *)adConfiguration {
    [self sendShowEventShowCalledWithNbAdsToShow:nbAdsToShow adConfiguration:adConfiguration customSessionId:nil];
}

- (void)sendShowEventShowCalledWithNbAdsToShow:(NSNumber *)nbAdsToShow
                               adConfiguration:(OGAAdConfiguration *)adConfiguration
                               customSessionId:(NSString *_Nullable)sessionId {
    [self prepareAndSend:OGAShowEventShow
         adConfiguration:adConfiguration
         customSessionId:sessionId
                 details:nil
            errorContent:nil];
}

- (void)sendShowEventDisplay:(NSNumber *)nbAdsToExpose adConfiguration:(OGAAdConfiguration *)adConfiguration {
    [self prepareAndSend:OGAShowEventDisplay
         adConfiguration:adConfiguration
         customSessionId:nil
                 details:nil
            errorContent:nil];
}

- (void)sendShowEventForImpressionSource:(NSString *)impressionSource
                                position:(NSNumber *)position
                         adConfiguration:(OGAAdConfiguration *)adConfiguration {
    OGAMutableOrderedDictionary *details = [OGAMutableOrderedDictionary new];
    details[OGAMonitoringEventDetailImpressionSource] = impressionSource ?: @"";
    [self prepareAndSend:OGAShowEventImpression
         adConfiguration:adConfiguration
         customSessionId:nil
                 details:details
            errorContent:nil];
}

- (void)sendShowEvent:(OGAMonitoringEvent)event impressionSource:(NSString *)impressionSource adConfiguration:(OGAAdConfiguration *)adConfiguration {
    [self prepareAndSend:event
         adConfiguration:adConfiguration
         customSessionId:nil
                 details:[[OGAOrderedDictionary alloc]
                             initWithDictionary:@{OGAMonitoringEventDetailImpressionSource : impressionSource ?: @""}]
            errorContent:nil];
}

- (void)sendShowEventContainerDisplayedWithImpressionSource:(NSString *)impressionSource exposure:(NSNumber *)exposure adConfiguration:(OGAAdConfiguration *)adConfiguration {
    OGAMutableOrderedDictionary *details = [OGAMutableOrderedDictionary new];
    details[OGAMonitoringEventDetailImpressionSource] = impressionSource ?: @"";
    details[OGAMonitoringEventDetailExposure] = exposure;
    [self prepareAndSend:OGAShowEventContainerDisplayed
         adConfiguration:adConfiguration
         customSessionId:nil
                 details:details
            errorContent:nil];
}

#pragma mark - Show error event method

- (void)sendShowErrorEvent:(OGAMonitoringEvent)event adConfiguration:(OGAAdConfiguration *)adConfiguration {
    [self sendShowErrorEvent:event adConfiguration:adConfiguration customSessionId:nil];
}

- (void)sendShowErrorEvent:(OGAMonitoringEvent)event
           adConfiguration:(OGAAdConfiguration *)adConfiguration
           customSessionId:(NSString *_Nullable)sessionId {
    [self prepareAndSend:event
         adConfiguration:adConfiguration
         customSessionId:sessionId
                 details:nil
            errorContent:nil];
}

- (void)sendShowErrorEventAdExpired:(OGAAdConfiguration *)adConfiguration context:(OGAExpirationContext *)expirationContext {
    OGAMutableOrderedDictionary *error = [OGAMutableOrderedDictionary new];
    long expirationTime = [expirationContext.expirationTime doubleValue];
    error[OGAMonitoringEventContentAdExpired] = @(expirationTime);
    error[OGAMonitoringEventContentExpirationSource] = expirationContext.expirationSource == OGAdExpirationSourceAd
        ? OGAMonitoringErrorEventContentExpirationSourceAd
        : OGAMonitoringErrorEventContentExpirationSourceProfig;
    error[OGAMonitoringEventContentExpirationTimeSpan] = @(expirationContext.timeSpan.intValue);
    [self prepareAndSend:OGAShowErrorEventAdExpired
         adConfiguration:adConfiguration
         customSessionId:nil
                 details:nil
            errorContent:error];
}

- (void)dealloc {
    [self.notificationCenter removeObserver:self];
}

@end

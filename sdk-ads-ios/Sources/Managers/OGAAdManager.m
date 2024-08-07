//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAAdContentPreCacheManager.h"
#import "OGAAdController.h"
#import "OGAAdControllerFactory.h"
#import "OGAAdManager+Check.h"
#import "OGAAdSequence.h"
#import "OGAAdSequenceCoordinator.h"
#import "OGAAdSyncManager.h"
#import "OGAAssetKeyChecker.h"
#import "OGAAssetKeyManager.h"
#import "OGAConfigurationUtils+Profig.h"
#import "OGAEXTScope.h"
#import "OGAExpirationContext.h"
#import "OGAInternetConnectionChecker.h"
#import "OGAIsExpiredChecker.h"
#import "OGAIsKilledChecker.h"
#import "OGAIsLoadedChecker.h"
#import "OGAKeyboardObserver.h"
#import "OGALog.h"
#import "OGAMetricsService.h"
#import "OGAMonitoringDispatcher.h"
#import "OGAPreCacheEvent.h"
#import "OGAProfigDao.h"
#import "OGAProfigManager.h"
#import "OGAReachability.h"
#import "OguryError+Ads.h"
#import "OGAOrderedDictionary.h"
#import "OGAAdEnabledChecker.h"

static NSString *const OGAHeaderBiddingTrackingURLOverrides = @"ad_track_urls";
static NSString *const OGAHeaderBiddingTrackingPreCachingURLOverride = @"ad_precache_url";
static NSString *const OGAEventEntry = @"event";
static NSString *const OGADisablingReason = @"disabling_reason";

@interface OGAAdManager () <OGAAdSequenceCoordinatorDelegate, OGAAssetKeyManagerDelegate>

@property(nonatomic, strong) OGAProfigManager *profigManager;
@property(nonatomic, strong) OGAAdSyncManager *adSyncManager;
@property(nonatomic, strong) OGAAdContentPreCacheManager *adContentPreCacheManager;
@property(nonatomic, strong) OGAAdControllerFactory *adControllerFactory;
@property(nonatomic, strong) OGAMetricsService *metricsService;

@property(nonatomic, strong) OGAAssetKeyManager *assetKeyManager;
@property(nonatomic, strong) OGAInternetConnectionChecker *internetConnectionChecker;
@property(nonatomic, strong) OGAIsLoadedChecker *isLoadedChecker;
@property(nonatomic, strong) OGAIsKilledChecker *isKilledChecker;
@property(nonatomic, strong) OGAIsExpiredChecker *isExpiredChecker;
@property(nonatomic, strong) OGAAdEnabledChecker *adEnabledChecker;

@property(nonatomic, strong) NSHashTable *sequencesWaitingForInit;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong, readwrite) NSHashTable *sequencesShowing;

@end

@implementation OGAAdManager

#pragma mark - Class Methods

+ (instancetype)sharedManager {
    static OGAAdManager *instance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });

    return instance;
}

#pragma mark - Initialization

- (instancetype)init {
    return [self initWithProfigManager:[OGAProfigManager shared]
                         adSyncManager:[OGAAdSyncManager shared]
              adContentPreCacheManager:[[OGAAdContentPreCacheManager alloc] init]
                   adControllerFactory:[[OGAAdControllerFactory alloc] init]
                        metricsService:[OGAMetricsService shared]
                       assetKeyManager:[OGAAssetKeyManager shared]
             internetConnectionChecker:[OGAInternetConnectionChecker shared]
                      keyboardObserver:[OGAKeyboardObserver shared]
                       isLoadedChecker:[[OGAIsLoadedChecker alloc] init]
                       isKilledChecker:[[OGAIsKilledChecker alloc] init]
                      isExpiredChecker:[[OGAIsExpiredChecker alloc] initWithAdManager:self]
                  monitoringDispatcher:[OGAMonitoringDispatcher shared]
                      adEnabledChecker:[[OGAAdEnabledChecker alloc] init]
                                   log:[OGALog shared]];
}

- (instancetype)initWithProfigManager:(OGAProfigManager *)profigManager
                        adSyncManager:(OGAAdSyncManager *)adSyncManager
             adContentPreCacheManager:(OGAAdContentPreCacheManager *)adContentPreCacheManager
                  adControllerFactory:(OGAAdControllerFactory *)adControllerFactory
                       metricsService:(OGAMetricsService *)metricsService
                      assetKeyManager:(OGAAssetKeyManager *)assetKeyManager
            internetConnectionChecker:(OGAInternetConnectionChecker *)internetConnectionChecker
                     keyboardObserver:(OGAKeyboardObserver *)KeyboardObserver
                      isLoadedChecker:(OGAIsLoadedChecker *)isLoadedChecker
                      isKilledChecker:(OGAIsKilledChecker *)isKilledChecker
                     isExpiredChecker:(OGAIsExpiredChecker *)isExpiredChecker
                 monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher
                     adEnabledChecker:(OGAAdEnabledChecker *)adEnabledChecker
                                  log:(OGALog *)log {
    if (self = [super init]) {
        _profigManager = profigManager;
        _adSyncManager = adSyncManager;
        _adContentPreCacheManager = adContentPreCacheManager;
        _adControllerFactory = adControllerFactory;
        _metricsService = metricsService;
        _isKilledChecker = isKilledChecker;
        _isKilledChecker.adManager = self;
        _assetKeyManager = assetKeyManager;
        _assetKeyManager.delegate = self;
        _isLoadedChecker = isLoadedChecker;
        _isLoadedChecker.adManager = self;
        _isExpiredChecker = isExpiredChecker;
        _internetConnectionChecker = internetConnectionChecker;
        _sequencesWaitingForInit = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        _sequencesShowing = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        _monitoringDispatcher = monitoringDispatcher;
        _adEnabledChecker = adEnabledChecker;
        _log = log;
    }

    return self;
}

#pragma mark - Methods
- (OGAAdSequence *)loadAdConfiguration:(OGAAdConfiguration *)configuration previousSequence:(OGAAdSequence *)previousSequence {
    // Copy configuration to prevent any mutation on parameters that may impact the result of the load.
    // ex. campaign id.
    configuration = [configuration copy];
    [configuration startNewMonitoringSession];
    if ([self isLoaded:previousSequence]) {
        configuration.monitoringDetails.reloaded = YES;
    } else if ([self sequenceHasFailed:previousSequence]) {
        [configuration reset];
    }

    [self.monitoringDispatcher sendLoadEvent:OGALoadEventLoad adConfiguration:configuration];

    if (previousSequence) {
        if (previousSequence.status == OGAAdSequenceStatusLoading) {
            [self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventCallError adConfiguration:configuration];
            return previousSequence;
        }

        if (previousSequence.status == OGAAdSequenceStatusLoaded && [self isLoaded:previousSequence] && ![self isExpired:previousSequence]) {
            [previousSequence.configuration.delegateDispatcher loaded];
            // now we must track the new event, so update the sessionId on the sequence and all associated ads
            [previousSequence updateReloadStateWithSessionId:configuration.monitoringDetails.sessionId];
            [self.monitoringDispatcher sendLoadEvent:OGALoadEventLoadAdLoaded adConfiguration:previousSequence.monitoringAdConfiguration];
            return previousSequence;
        }
    }

    return [self loadAdConfiguration:configuration];
}
- (OGAAdSequence *)loadAdConfiguration:(OGAAdConfiguration *)configuration {
    OGAAdSequence *sequence = [[OGAAdSequence alloc] initWithAdConfiguration:configuration];

    if (self.assetKeyManager.sdkState == OgurySDKStateStarting) {
        [self.sequencesWaitingForInit addObject:sequence];
        return sequence;
    }

    if (self.assetKeyManager.assetKey == NULL) {
        sequence.status = OGAAdSequenceStatusInitError;
        [self.assetKeyManager setSdkState:OgurySDKStateError];
        [self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventSdkNeverInitialized
                                      adConfiguration:sequence.monitoringAdConfiguration];
        [sequence.configuration.delegateDispatcher failedWithError:[OguryError createSdkInitNotCalledError]];
        return sequence;
    }

    if (self.assetKeyManager.sdkState != OgurySDKStateReady) {
        sequence.status = OGAAdSequenceStatusInitError;
        [self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventSdkNotInitialized
                                      adConfiguration:sequence.monitoringAdConfiguration];
        [sequence.configuration.delegateDispatcher failedWithError:[OguryError createSdkInitNotCalledError]];
        return sequence;
    }

    [self loadSequence:sequence];

    return sequence;
}

- (void)loadSequence:(OGAAdSequence *)sequence {
    OguryError *error = nil;

    if (self.assetKeyManager.sdkState == OgurySDKStateError) {
        sequence.status = OGAAdSequenceStatusInitError;
        [self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventSdkNotInitialized
                                           stackTrace:@"SDK initialization failed"
                                      adConfiguration:sequence.monitoringAdConfiguration];
        [sequence.configuration.delegateDispatcher failedWithError:[OguryError createUnknownError]];
        return;
    }

    if (![self.internetConnectionChecker checkForSequence:sequence error:&error]) {
        sequence.status = OGAAdSequenceStatusInitError;
        [self sendMonitoringEventFor:sequence oguryError:error customSessionId:nil];
        [self dispatchError:error sequence:sequence];
        return;
    }

    // TODO: Add wait for consent here

    // Otherwise continue loading
    [self continueLoadAdSequenceAfterConsentEventReceived:sequence];
}

- (BOOL)checkConditions:(NSArray<id<OGAConditionChecker>> *)conditions sequence:(OGAAdSequence *)sequence error:(OguryError **)error {
    for (id<OGAConditionChecker> condition in conditions) {
        if (![condition checkForSequence:sequence error:error]) {
            return NO;
        }
    }
    return YES;
}

- (void)continueLoadAdSequenceAfterConsentEventReceived:(OGAAdSequence *)sequence {
    @weakify(self, sequence)[self.profigManager syncProfigWithCompletion:^(OGAProfigFullResponse *response, NSError *error) {
        @strongify(self, sequence) if (!sequence || !self) {
            return;
        }

        sequence.privacyConfiguration = [response getPrivacyConfiguration];

        if (error != nil) {
            sequence.status = OGAAdSequenceStatusError;
            [self dispatchError:[self errorForProfigError:error] sequence:sequence];
            [self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventProfigFailToSync
                                               stackTrace:@"Network error"
                                          adConfiguration:sequence.monitoringAdConfiguration];
            return;
        } else if (response == nil) {
            [self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventProfigIsNull
                                          adConfiguration:sequence.monitoringAdConfiguration];
            sequence.status = OGAAdSequenceStatusError;
            [self dispatchError:[OguryError createProfigNotSyncedError] sequence:sequence];
            return;
        }

        if ([response isAdsEnabled] == NO) {
            sequence.status = OGAAdSequenceStatusError;
            [self dispatchError:[OguryError createAdDisabledError] sequence:sequence];
            OGAMutableOrderedDictionary *disablingReasonErrorContent = [[OGAMutableOrderedDictionary alloc] init];
            if (response.disablingReason) {
                disablingReasonErrorContent[OGADisablingReason] = response.disablingReason;
            }
            [self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventAdDisabled
                                          adConfiguration:sequence.monitoringAdConfiguration
                                             errorContent:disablingReasonErrorContent];
            return;
        }

        sequence.configuration.expirationContext = [[OGAExpirationContext alloc] initFrom:OGAdExpirationSourceProfig withExpirationTime:response.adExpirationTime];
        [self continueLoadAdSequenceAfterProfigSynced:sequence];
    }];
}

- (OguryError *)errorForProfigError:(NSError *)error {
    if (error.code == OGAProfigExternalErrorNoInternet) {
        return [OguryError createOguryErrorWithCode:OguryCoreErrorTypeNoInternetConnection];
    }
    return [OguryError createProfigNotSyncedError];
}

- (void)continueLoadAdSequenceAfterProfigSynced:(OGAAdSequence *)sequence {
    if (!sequence.configuration.isHeaderBidding) {
        OGAPreCacheEvent *preCacheEvent = [[OGAPreCacheEvent alloc] initWithAdUnitId:sequence.configuration.adUnitId privacyConfiguration:sequence.privacyConfiguration eventType:OGAMetricsEventLoad];
        [self.metricsService sendEvent:preCacheEvent];
    }
    @weakify(self, sequence)
        [self.adSyncManager postAdSyncForAdConfiguration:sequence.configuration
                                    privacyConfiguration:sequence.privacyConfiguration
                                       completionHandler:^(NSArray<OGAAd *> *ads, NSError *error) {
                                           @strongify(self, sequence) if (!self || !sequence) {
                                               return;
                                           }
                                           [self continueLoadAdAfterAdSynced:sequence ads:ads error:error];
                                       }];
}

- (NSURL *_Nullable)preCacheEventTrackingURLFromAdConfiguration:(OGAAdConfiguration *)adConfiguration {
    __block NSURL *preCacheURLOverride;

    // Header Bidding can override some tracking URL
    if (adConfiguration.isHeaderBidding && adConfiguration.adMarkupSync != nil && adConfiguration.adMarkupSync.count > 0) {
        // Find the first URL override for precaching
        [adConfiguration.adMarkupSync enumerateObjectsUsingBlock:^(NSDictionary *currentRawAd, NSUInteger index, BOOL *_Nonnull stop) {
            NSDictionary *trackingURLs = currentRawAd[OGAHeaderBiddingTrackingURLOverrides];

            if (trackingURLs && trackingURLs[OGAHeaderBiddingTrackingPreCachingURLOverride]) {
                NSString *preCachingURL = trackingURLs[OGAHeaderBiddingTrackingPreCachingURLOverride];

                if (preCachingURL.length > 0) {
                    preCacheURLOverride = [NSURL URLWithString:preCachingURL];
                    return;
                }
            }
        }];
    }

    return preCacheURLOverride;
}

- (void)continueLoadAdAfterAdSynced:(OGAAdSequence *)sequence ads:(NSArray<OGAAd *> *)ads error:(NSError *)error {
    if (error == nil && ads.count == 0) {
        error = sequence.configuration.isHeaderBidding
            ? [OguryError createHBNoFillError]
            : [OguryError createAdSyncNoFillError];
    }
    if (error != nil) {
        sequence.status = OGAAdSequenceStatusError;
        if (!sequence.configuration.isHeaderBidding) {
            switch (error.code) {
                case OGAInternalErrorAdSyncNoFill:
                    [self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventNoFill adConfiguration:sequence.monitoringAdConfiguration];
                    break;

                case OGAInternalErrorAdSyncParsingError:
                    [self.monitoringDispatcher sendLoadErrorEventParsingFailWithStackTrace:error.localizedDescription
                                                                           adConfiguration:sequence.monitoringAdConfiguration];
                    break;

                case OGAInternalClientError:
                case OGAInternalServerError:
                    [self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventAdSyncRequestFail
                                                       stackTrace:error.localizedDescription
                                                  adConfiguration:sequence.monitoringAdConfiguration];
                    break;

                default:
                    if ([error isKindOfClass:[OguryError class]]) {
                        [self.monitoringDispatcher sendLoadErrorEventParsingFailWithStackTrace:[NSString stringWithFormat:@"AdParseError (%@)", error.localizedDescription]
                                                                               adConfiguration:sequence.monitoringAdConfiguration];
                    } else {
                        [self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventAdSyncRequestFail
                                                           stackTrace:error.localizedDescription
                                                      adConfiguration:sequence.monitoringAdConfiguration];
                    }
                    break;
            }
            [self dispatchError:[self errorForAdSyncError:error ads:ads] sequence:sequence];
        } else {
            NSString *errorMessage = @"failed to decode base64 from ad markup";
            if ([error isKindOfClass:[OguryError class]]) {
                errorMessage = error.localizedDescription;
            }
            [self.log logAd:OguryLogLevelError forAdConfiguration:sequence.configuration message:@"failed to decode ad markup"];
            [self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventAdMarkUpParsingError
                                               stackTrace:errorMessage
                                          adConfiguration:sequence.monitoringAdConfiguration];
            [self dispatchError:[OguryError createNotLoadedError] sequence:sequence];
        }
        return;
    }
    // mraid script precache
    @weakify(self, sequence)[self.adContentPreCacheManager prepareAdContents:ads
                                                           completionHandler:^(OguryError *error) {
                                                               @strongify(self, sequence) if (!self || !sequence) {
                                                                   return;
                                                               }
                                                               [self continueLoadAdAfterAdContentsPrepared:sequence ads:ads error:error];
                                                           }];
}

- (OguryError *)errorForAdSyncError:(NSError *_Nullable)error ads:(NSArray<OGAAd *> *_Nullable)ads {
    if (error.code == OGAInternalErrorAdSyncNoFill) {
        return [OguryError createNotAvailableError];
    } else {
        return [OguryError createUnknownError];
    }
}

- (void)continueLoadAdAfterAdContentsPrepared:(OGAAdSequence *)sequence ads:(NSArray<OGAAd *> *)ads error:(OguryError *)error {
    if (error) {
        sequence.status = OGAAdSequenceStatusError;
        [self dispatchError:error sequence:sequence];
        return;
    }

    [self.adControllerFactory createControllersForSequence:sequence
                                                       ads:ads
                                             configuration:sequence.monitoringAdConfiguration];
    sequence.coordinator.delegate = self;
}

- (BOOL)isLoaded:(OGAAdSequence *)sequence {
    if (!sequence || sequence.status != OGAAdSequenceStatusLoaded) {
        return NO;
    }

    return [sequence.coordinator isLoaded];
}

- (BOOL)sequenceHasFailed:(OGAAdSequence *)sequence {
    if (!sequence) {
        return NO;
    }
    return sequence.status == OGAAdSequenceStatusError || sequence.status == OGAAdSequenceStatusInitError;
}

- (BOOL)isKilled:(OGAAdSequence *)sequence {
    return [sequence.coordinator isKilled];
}

- (BOOL)isExpanded:(OGAAdSequence *)sequence {
    if (!sequence) {
        return NO;
    }

    return [sequence.coordinator isExpanded];
}

- (BOOL)isExpired:(OGAAdSequence *)sequence {
    return [sequence.coordinator isExpired];
}

- (void)show:(OGAAdSequence *)sequence additionalConditions:(NSArray<id<OGAConditionChecker>> *)additionalConditions {
    // If the ad is not loaded, then it should not be tighted to the sequence's sessionID and a new one should be created and passed along other events in the current method
    NSString *sessionId = [self isLoaded:sequence] || [self isKilled:sequence] ? sequence.configuration.monitoringDetails.sessionId : [NSUUID UUID].UUIDString;
    [self.monitoringDispatcher sendShowEventShowCalledWithNbAdsToShow:@(sequence.coordinator.adControllers.count)
                                                      adConfiguration:sequence.monitoringAdConfiguration
                                                      customSessionId:sessionId];

    if (self.assetKeyManager.assetKey == NULL) {
        sequence.status = OGAAdSequenceStatusInitError;
        [self.assetKeyManager setSdkState:OgurySDKStateError];
        [self.monitoringDispatcher sendShowErrorEvent:OGAShowErrorEventSdkNeverInitialized
                                      adConfiguration:sequence.monitoringAdConfiguration
                                      customSessionId:sessionId];
        [self dispatchError:[OguryError createSdkInitNotCalledError] sequence:sequence];
        return;
    }

    if (self.assetKeyManager.sdkState != OgurySDKStateReady) {
        sequence.status = OGAAdSequenceStatusInitError;
        [self.monitoringDispatcher sendShowErrorEvent:OGAShowErrorEventSdkNotInitialized
                                      adConfiguration:sequence.monitoringAdConfiguration
                                      customSessionId:sessionId];
        [self dispatchError:[OguryError createSdkInitNotCalledError] sequence:sequence];
        return;
    }

    if (![self profigDao].profigFullResponse) {
        sequence.status = OGAAdSequenceStatusInitError;
        [self.monitoringDispatcher sendShowErrorEvent:OGAShowErrorEventProfigNotSync
                                      adConfiguration:sequence.monitoringAdConfiguration
                                      customSessionId:sessionId];
        [self dispatchError:[OguryError createSdkInitNotCalledError] sequence:sequence];
        return;
    }

    NSMutableArray<id<OGAConditionChecker>> *conditions = [@[ self.isKilledChecker, self.isExpiredChecker, self.isLoadedChecker, self.adEnabledChecker ] mutableCopy];
    if (additionalConditions) {
        [conditions addObjectsFromArray:additionalConditions];
    }
    [conditions addObject:self.internetConnectionChecker];
    OguryError *error = nil;
    if (![self checkConditions:conditions sequence:sequence error:&error]) {
        sequence.status = OGAAdSequenceStatusError;
        [self dispatchError:error sequence:sequence];

        // to make difference with no internet error on load
        if (error.code == OguryCoreErrorTypeNoInternetConnection) {
            [self.monitoringDispatcher sendShowErrorEvent:OGAShowErrorEventNoInternetConnection
                                          adConfiguration:sequence.monitoringAdConfiguration
                                          customSessionId:sessionId];
        } else {
            [self sendMonitoringEventFor:sequence oguryError:error customSessionId:sessionId];
        }
        return;
    }

#warning TODO: Combine old track & monitoring
    OGAPreCacheEvent *preCacheEvent = [[OGAPreCacheEvent alloc] initWithAdUnitId:sequence.configuration.adUnitId privacyConfiguration:sequence.privacyConfiguration eventType:OGAMetricsEventShow];
    preCacheEvent.trackURL = [self preCacheEventTrackingURLFromAdConfiguration:sequence.configuration];

    [self.metricsService enqueueEvent:preCacheEvent];

    if (![sequence.coordinator show:&error]) {
        sequence.status = OGAAdSequenceStatusError;
        [self dispatchError:error sequence:sequence];
        [self sendMonitoringEventFor:sequence oguryError:error customSessionId:sessionId];
        return;
    }

    @synchronized(self.sequencesShowing) {
        [self.sequencesShowing addObject:sequence];
    }
    sequence.status = OGAAdSequenceStatusShown;
}

- (OGAProfigDao *)profigDao {
    return [OGAProfigDao shared];
}

- (void)close:(OGAAdSequence *)sequence {
    [sequence.coordinator close];
    sequence.status = OGAAdSequenceStatusClosed;
}

- (void)dispatchError:(OguryError *_Nullable)error sequence:(OGAAdSequence *_Nullable)sequence {
    if (!sequence) {
        return;
    }

    if (!error) {
        error = [OguryError createUnknownError];
    }

    [sequence.configuration.delegateDispatcher failedWithError:error];
}

#pragma mark - OGAAdSequenceCoordinatorDelegate

- (void)didCloseSequence:(OGAAdSequence *)sequence {
    @synchronized(self.sequencesShowing) {
        [self.sequencesShowing removeObject:sequence];
    }
}

- (void)defineSDKType:(OGASDKType)sdkType {
    _sdkType = sdkType;
}

- (void)defineMediationName:(NSString *)mediationName {
    _mediation = mediationName;
}

- (void)sendMonitoringEventFor:(OGAAdSequence *)sequence oguryError:(OguryError *)error configuration:(OGAAdConfiguration *)configuration {
    [self sendMonitoringEventFor:sequence oguryError:error customSessionId:nil];
}

- (void)sendMonitoringEventFor:(OGAAdSequence *)sequence
                    oguryError:(OguryError *)error
               customSessionId:(NSString *_Nullable)sessionId {
    if (!error) {
        return;
    }

    OGAAdConfiguration *configuration = sequence.monitoringAdConfiguration;

    switch (error.code) {
        case OguryCoreErrorTypeNoInternetConnection:
            [self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventNoInternetConnection adConfiguration:configuration customSessionId:sessionId];
            break;
        case OguryAdsSdkInitNotCalledError:
            [self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventSdkNotInitialized adConfiguration:configuration customSessionId:sessionId];
            break;
        case OguryAdsAssetKeyNotValidError:
            [self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventEmptyAssetKey adConfiguration:configuration customSessionId:sessionId];
            break;
        case OguryAdsAdExpiredError: {
            [self.monitoringDispatcher sendShowErrorEventAdExpired:configuration context:sequence.coordinator.adControllers[0].expirationContext];
            break;
        }
        case OguryAdsErrorAdDisable:
            [self.monitoringDispatcher sendShowErrorEvent:OGAShowErrorEventAdDisabled adConfiguration:configuration customSessionId:sessionId];
            break;
        case OguryAdsNotLoadedError:
            [self.monitoringDispatcher sendShowErrorEvent:OGAShowErrorEventNoAdLoaded adConfiguration:configuration customSessionId:sessionId];
            break;
        case OguryAdsAnotherAdAlreadyDisplayedError:
            [self.monitoringDispatcher sendShowErrorEvent:OGAShowErrorEventAnotherAdAlreadyDisplayed adConfiguration:configuration customSessionId:sessionId];
            break;
        case OguryAdsCantShowAdsInPresentingViewControllerError:
            [self.monitoringDispatcher sendShowErrorEvent:OGAShowErrorEventViewInBackground adConfiguration:configuration customSessionId:sessionId];
            break;
        case OguryAdsWebViewKilledError:
            [self.monitoringDispatcher sendShowErrorEvent:OGAShowErrorEventWebviewTerminatedByOS adConfiguration:configuration];
            break;
        default:
            return;
    }
}

- (void)didSDKStatusChange {
    if (self.assetKeyManager.sdkState == OgurySDKStateStarting) {
        return;
    }
    @synchronized(self) {
        for (OGAAdSequence *sequence in self.sequencesWaitingForInit) {
            [self loadSequence:sequence];
        }
        [self.sequencesWaitingForInit removeAllObjects];
    }
}

@end

//
// Copyright (c) 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGAAdManager.h"
#import "OGAAssetKeyManager.h"
#import "OGAProfigManager.h"
#import "OGAAdSyncManager.h"
#import "OGAAdContentPreCacheManager.h"
#import "OGAAdControllerFactory.h"
#import "OGAMetricsService.h"
#import "OGAReachability.h"
#import "OGAAssetKeyChecker.h"
#import "OGAInternetConnectionChecker.h"
#import "OGAIsLoadedChecker.h"
#import "OGAIsExpiredChecker.h"
#import "OGAKeyboardObserver.h"
#import "OGAIsKilledChecker.h"
#import "OGALog.h"
#import "OGAMonitoringDispatcher.h"
#import "OGAAdEnabledChecker.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdManager (Testing)

#pragma mark - Properties

@property(nonatomic, strong) NSHashTable *sequencesShowing;

#pragma mark - Initialization

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
                                  log:(OGALog *)log;

#pragma mark - Methods

- (OGAAdSequence *)loadAdConfiguration:(OGAAdConfiguration *)configuration;

- (BOOL)checkConditions:(NSArray<id<OGAConditionChecker>> *)conditions sequence:(OGAAdSequence *)sequence error:(OguryError *_Nullable *_Nullable)error;

- (void)continueLoadAdSequenceAfterConsentEventReceived:(OGAAdSequence *)sequence;

- (OguryError *)errorForProfigError:(NSError *)error;

- (void)continueLoadAdSequenceAfterProfigSynced:(OGAAdSequence *)sequence;

- (void)continueLoadAdAfterAdSynced:(OGAAdSequence *)sequence ads:(NSArray<OGAAd *> *_Nullable)ads error:(OguryError *_Nullable)error;

- (void)continueLoadAdAfterAdContentsPrepared:(OGAAdSequence *)sequence ads:(NSArray<OGAAd *> *_Nullable)ads error:(OguryError *_Nullable)error;

- (void)dispatchError:(OguryError *)error sequence:(OGAAdSequence *)sequence;

- (BOOL)isAnotherAdInOverlayState:(OGAAdSequence *)sequence;

- (NSURL *_Nullable)preCacheEventTrackingURLFromAdConfiguration:(OGAAdConfiguration *)adConfiguration;

@end

NS_ASSUME_NONNULL_END

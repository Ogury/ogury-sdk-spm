//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import "OGAAdSyncService.h"

#import <OguryCore/OguryNetworkClient.h>

#import "OGAAssetKeyManager.h"
#import "OGAProfigManager.h"
#import "OGAWebViewUserAgentService.h"
#import "OGAOMIDService.h"
#import "OGAProfigDao.h"
#import "OGAEnvironmentManager.h"
#import "OGAReachability.h"
#import "OGAMonitoringDispatcher.h"
#import "OGALog.h"
#import "OGAMetricsService.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdSyncService (Testing)

- (instancetype)initWithNetworkClient:(OguryNetworkClient *)networkClient
                      assetKeyManager:(OGAAssetKeyManager *)assetKeyManager
                        profigManager:(OGAProfigManager *)profigManager
              webViewUserAgentService:(OGAWebViewUserAgentService *)webViewUserAgentService
                          omidService:(OGAOMIDService *)omidService
                    profigPersistence:(OGAProfigDao *)profigPersistence
                          environment:(OGAEnvironmentManager *)environment
                         reachability:(OGAReachability *)reachability
                 monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher
                       metricsService:(OGAMetricsService *)metricsService
                                  log:(OGALog *)log;

- (void)handleAdSyncRequestWithAdConfiguration:(OGAAdConfiguration *)adConfiguration
                          privacyConfiguration:(OGAAdPrivacyConfiguration *)privacyConfiguration
                                        result:(NSData *_Nullable)result
                                      response:(NSURLResponse *_Nullable)response
                                         error:(NSError *_Nullable)error
                             completionHandler:(void (^)(NSArray<OGAAd *> *ads, NSError *_Nullable error))completionHandler;

- (NSArray<OGAAd *> *_Nullable)parseAdsFromData:(NSData *_Nullable)data adConfiguration:(OGAAdConfiguration *)adConfiguration privacyConfiguration:(OGAAdPrivacyConfiguration *)privacyConfiguration error:(NSError **)error;

- (NSURLRequest *_Nullable)adSyncURLRequestForURL:(NSURL *)url adConfiguration:(OGAAdConfiguration *)adConfiguration privacyConfiguration:(OGAAdPrivacyConfiguration *)privacyConfiguration;

- (NSDictionary<NSString *, NSString *> *)headersForAdSyncWithBundle:(NSBundle *)bundle orientation:(NSString *)orientation privacyConfiguration:(OGAAdPrivacyConfiguration *)privacyConfiguration;

@end

NS_ASSUME_NONNULL_END

//
// Copyright (c) 2020 Ogury Ltd. All rights reserved.
//

#import "OGAAdContentPreCacheManager.h"

#import <OguryCore/OguryError.h>

#import "OGAUserDefaultsStore.h"
#import "OGAMraidFileDownloader.h"
#import "OGAMetricsService.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^MraidDownloadCompletionHandler)(NSString *mraidDownloadUrl, OguryError *_Nullable error);

@interface OGAAdContentPreCacheManager (Testing)

- (instancetype)initWithUserDefaultsStore:(OGAUserDefaultsStore *)userDefaultsStore
                      mraidFileDownloader:(OGAMraidFileDownloader *)mraidFileDownloader
                     monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher
                           metricsService:(OGAMetricsService *)metricsService;

- (BOOL)hasAtLeastOneMraidDownload:(NSArray<OGAAd *> *)ads;

- (void)downloadMraidScripts:(NSArray<OGAAd *> *)ads completionHandler:(OGAPrepareAdContentsCompletionHandler)completionHandler;

- (void)downloadMraidScript:(OGAAd *)ad completionHandler:(MraidDownloadCompletionHandler)completionHandler;

- (void)sendLoadedErrorEventsAfterFailingToDownload:(NSString *)mraidDownloadUrl ads:(NSArray<OGAAd *> *)ads;

- (void)sendLoadedErrorEventForAd:(OGAAd *)ad;

@end

NS_ASSUME_NONNULL_END

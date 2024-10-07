//
// Copyright (c) 2020 Ogury Ltd. All rights reserved.
//

#import "OGAAdContentPreCacheManager.h"
#import "NSString+OGAUtility.h"
#import "OGAEXTScope.h"
#import "OGAMetricsService.h"
#import "OGAMonitoringDispatcher.h"
#import "OGAMraidFileDownloader.h"
#import "OGATrackEvent.h"
#import "OGAUserDefaultsStore.h"
#import "OguryAdError.h"
#import "OguryAdError+Internal.h"

@interface OGAAdContentPreCacheManager ()

@property(nonatomic, strong) OGAUserDefaultsStore *userDefaultsStore;
@property(nonatomic, strong) OGAMraidFileDownloader *mraidFileDownloader;
@property(nonatomic, strong) OGAMetricsService *metricsService;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;

@end

@implementation OGAAdContentPreCacheManager

#pragma mark - Initialization

- (instancetype)init {
    return [self initWithUserDefaultsStore:[OGAUserDefaultsStore shared]
                       mraidFileDownloader:[[OGAMraidFileDownloader alloc] init]
                      monitoringDispatcher:[OGAMonitoringDispatcher shared]
                            metricsService:[OGAMetricsService shared]];
}

- (instancetype)initWithUserDefaultsStore:(OGAUserDefaultsStore *)userDefaultsStore
                      mraidFileDownloader:(OGAMraidFileDownloader *)mraidFileDownloader
                     monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher
                           metricsService:(OGAMetricsService *)metricsService {
    if (self = [super init]) {
        _userDefaultsStore = userDefaultsStore;
        _mraidFileDownloader = mraidFileDownloader;
        _metricsService = metricsService;
        _monitoringDispatcher = monitoringDispatcher;
    }
    return self;
}

#pragma mark - Methods
- (void)prepareAdContents:(NSArray<OGAAd *> *)ads completionHandler:(OGAPrepareAdContentsCompletionHandler)completionHandler {
    // ad.identifier is not uniq due to the backend architecture.
    // Therefore we create our own local identifier to overcome the issue.
    // we also check the ad content
    NSUInteger htmlEmptyCount = 0;
    for (OGAAd *ad in ads) {
        ad.localIdentifier = [[NSUUID UUID] UUIDString];
        if (ad.html.length == 0) {
            htmlEmptyCount++;
            [self.monitoringDispatcher sendLoadErrorEventPrecacheFail:OGAMonitoringPrecacheErrorHtmlEmpty adConfiguration:ad.adConfiguration];
        }
    }

    // if all ads are empty
    if (htmlEmptyCount == ads.count) {
        completionHandler([OguryAdError adPrecachingFailedWithStackTrace:@"Ad Html is empty"]);
        return;
    }

    // As we only support MRAID ad for now, we just have the mraid to precache.
    if ([self hasAtLeastOneMraidDownload:ads]) {
        [self downloadMraidScripts:ads completionHandler:completionHandler];
    } else {
        completionHandler(nil);
    }
}

- (BOOL)hasAtLeastOneMraidDownload:(NSArray<OGAAd *> *)ads {
    for (OGAAd *ad in ads) {
        if (ad.mraidDownloadUrl) {
            return YES;
        }
    }
    return NO;
}

- (void)downloadMraidScripts:(NSArray<OGAAd *> *)ads completionHandler:(OGAPrepareAdContentsCompletionHandler)completionHandler {
    __block BOOL dispatched = NO;
    __block NSMutableSet<NSString *> *mraidUrlsToDownload = [NSMutableSet set];

    if (ads.count == 0) {
        return;  // normally this should never happens because its blocked in upper layer, but check again for crash-safety because we are accessing ads[0] below
    }

    [self.monitoringDispatcher sendLoadEvent:OGALoadEventLoadAdPrecache adConfiguration:ads[0].adConfiguration];

    for (OGAAd *ad in ads) {
        [mraidUrlsToDownload addObject:ad.mraidDownloadUrl];

        [self downloadMraidScript:ad
                completionHandler:^(NSString *mraidDownloadUrl, OguryAdError *error) {
                    @synchronized(mraidUrlsToDownload) {
                        [mraidUrlsToDownload removeObject:mraidDownloadUrl];
                        if (error) {
                            [self.monitoringDispatcher sendLoadErrorEventPrecacheFail:OGAMonitoringPrecacheErrorMraidDownloadFailed
                                                                      adConfiguration:ad.adConfiguration
                                                                            arguments:@[ mraidDownloadUrl, error.additionalInformation ]];
                            [self sendLoadedErrorEventsAfterFailingToDownload:mraidDownloadUrl ads:ads];
                        }
                        if ((error || mraidUrlsToDownload.count == 0) && !dispatched) {
                            dispatched = YES;
                            if (error) {
                                completionHandler(error ?: [OguryAdError adPrecachingFailedWithStackTrace:@"Mraid download error"]);
                            } else {
                                completionHandler(nil);
                            }
                        }
                    }
                }];
    }
}

- (void)downloadMraidScript:(OGAAd *)ad
          completionHandler:(void (^)(NSString *mraidDownloadUrl, OguryAdError *_Nullable error))completionHandler {
    if ([self.userDefaultsStore stringForKey:ad.mraidDownloadUrl]) {
        completionHandler(ad.mraidDownloadUrl, nil);
        return;
    }

    @weakify(self)[self.mraidFileDownloader downloadMraidJSFromURL:ad
                                                        completion:^(NSString *response, NSError *error) {
                                                            @strongify(self) if (error) {
                                                                OguryAdError *adError = (OguryAdError *)error;
                                                                if (adError == nil) {
                                                                    adError = [OguryAdError adPrecachingFailedWithStackTrace:[NSString stringWithFormat:@"Mraid download error (%ld)", error.code]];
                                                                }
                                                                completionHandler(ad.mraidDownloadUrl, adError);
                                                                return;
                                                            }

                                                            if (!response || [response isEqualToString:@""]) {
                                                                completionHandler(ad.mraidDownloadUrl, [OguryAdError adPrecachingFailedWithStackTrace:@"Mraid download error (response is empty)"]);
                                                                return;
                                                            }

                                                            [self.userDefaultsStore setObject:response forKey:ad.mraidDownloadUrl];
                                                            completionHandler(ad.mraidDownloadUrl, nil);
                                                        }];
}

- (void)sendLoadedErrorEventsAfterFailingToDownload:(NSString *)mraidDownloadUrl ads:(NSArray<OGAAd *> *)ads {
    for (OGAAd *ad in ads) {
        if ([NSString ogaString:ad.mraidDownloadUrl isEqualToString:mraidDownloadUrl]) {
            [self sendLoadedErrorEventForAd:ad];
        }
    }
}

- (void)sendLoadedErrorEventForAd:(OGAAd *)ad {
    [self.metricsService sendEvent:[[OGATrackEvent alloc] initWithAd:ad event:OGAMetricsEventLoadedError]];
}

@end

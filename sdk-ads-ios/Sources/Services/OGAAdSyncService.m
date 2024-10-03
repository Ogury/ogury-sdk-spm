//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAAdSyncService.h"
#import <OguryCore/OguryNetworkClient.h>
#import <OguryCore/OguryNetworkRequestBuilder.h>
#import "OGAAdConfiguration+AdSync.h"
#import "OGAAdConfiguration.h"
#import "OGAAdIdentifierService.h"
#import "OGAAdParser.h"
#import "OGADeviceService.h"
#import "OGAEnvironmentManager.h"
#import "OGALog.h"
#import "OGAMonitoringDispatcher.h"
#import "OGAOMIDService.h"
#import "OGAProfigDao.h"
#import "OGAProfigManager.h"
#import "OGAReachability.h"
#import "OGAWebViewUserAgentService.h"
#import "NSDictionary+OGABase64.h"
#import "OGAPreCacheEvent.h"
#import "OGAMetricsService.h"
#import "OguryAdError+Internal.h"

@interface OGAAdSyncService ()

#pragma mark - Properties

@property(nonatomic, strong) OguryNetworkClient *networkClient;
@property(nonatomic, strong) OGAAssetKeyManager *assetKeyManager;
@property(nonatomic, strong) OGAProfigManager *profigManager;
@property(nonatomic, strong) OGAWebViewUserAgentService *webViewUserAgentService;
@property(nonatomic, strong) OGAOMIDService *omidService;
@property(nonatomic, strong) OGAProfigDao *profigPersistence;
@property(nonatomic, strong) OGAEnvironmentManager *environment;
@property(nonatomic, strong) OGAReachability *reachability;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) OGAMetricsService *metricsService;

@end

@implementation OGAAdSyncService

#pragma mark - Constants

static NSString *const AdSyncServiceHeadersUserKey = @"User";
static NSString *const AdSyncServiceHeadersVendiorIdKey = @"Vendor";
static NSString *const AdSyncServiceHeadersInstanceTokenKey = @"Instance-Token";
static NSString *const AdSyncServiceHeadersUserAgentKey = @"User-Agent";
static NSString *const AdSyncServiceHeadersDeviceOSKey = @"Device-OS";
static NSString *const AdSyncServiceHeadersDeviceOSiOSKey = @"ios";
static NSString *const AdSyncServiceHeadersPackageNameKey = @"Package-Name";
static NSString *const AdSyncServiceHeadersWebviewUserAgentKey = @"WebView-User-Agent";
static NSString *const AdSyncServiceHeadersOrientationKey = @"Orientation";
static NSString *const AdSyncServiceHeadersIdentifierForVendorKey = @"vendor";
static NSString *const HeaderBiddingAdKey = @"ad";
static NSString *const OGAHeaderBiddingTrackingURLOverrides = @"ad_track_urls";
static NSString *const OGAHeaderBiddingTrackingPreCachingURLOverride = @"ad_precache_url";

#pragma mark - Initialization

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
                                  log:(OGALog *)log {
    if (self = [super init]) {
        _networkClient = networkClient;
        _assetKeyManager = assetKeyManager;
        _profigManager = profigManager;
        _webViewUserAgentService = webViewUserAgentService;
        _omidService = omidService;
        _profigPersistence = profigPersistence;
        _environment = environment;
        _reachability = reachability;
        _monitoringDispatcher = monitoringDispatcher;
        _metricsService = metricsService;
        _log = log;
    }
    return self;
}

- (instancetype)init {
    return [self initWithNetworkClient:[OguryNetworkClient shared]
                       assetKeyManager:[OGAAssetKeyManager shared]
                         profigManager:[OGAProfigManager shared]
               webViewUserAgentService:[OGAWebViewUserAgentService shared]
                           omidService:[OGAOMIDService shared]
                     profigPersistence:[OGAProfigDao shared]
                           environment:[OGAEnvironmentManager shared]
                          reachability:[OGAReachability reachabilityForInternetConnection]
                  monitoringDispatcher:[OGAMonitoringDispatcher shared]
                        metricsService:[OGAMetricsService shared]
                                   log:[OGALog shared]];
}

#pragma mark - Methods
- (void)postAdSyncForAdConfiguration:(OGAAdConfiguration *)configuration
                privacyConfiguration:(OGAAdPrivacyConfiguration *)privacyConfiguration
                   completionHandler:(void (^)(NSArray<OGAAd *> *ads, NSError *_Nullable error))completionHandler {
    if (self.profigPersistence.profigFullResponse.webviewLoadTimeout) {
        configuration.webviewLoadTimeout = self.profigPersistence.profigFullResponse.webviewLoadTimeout;
    }
    if (configuration.isHeaderBidding) {
        [self.monitoringDispatcher sendLoadEvent:OGALoadEventAdParseStarted adConfiguration:configuration];
        NSError *error = nil;
        NSDictionary *decodedAdMarkup = [NSDictionary ogaDecodeFromBase64:configuration.encodedAdMarkup error:&error];
        if (decodedAdMarkup) {
            NSArray *decodedAds = decodedAdMarkup[HeaderBiddingAdKey];
            if (decodedAds) {
                configuration.adMarkupSync = decodedAds;
                OGAPreCacheEvent *preCacheEvent = [[OGAPreCacheEvent alloc] initWithAdUnitId:configuration.adUnitId
                                                                        privacyConfiguration:privacyConfiguration
                                                                                   eventType:OGAMetricsEventLoad];
                preCacheEvent.trackURL = [self preCacheEventTrackingURLFromAdConfiguration:configuration];
                [self.metricsService sendEvent:preCacheEvent];
                NSMutableArray<OGAAd *> *ads = [[NSMutableArray alloc] init];
                for (NSDictionary *rawAd in configuration.adMarkupSync) {
                    OGAAd *ad = [OGAAdParser parseAdJSON:rawAd
                                         adConfiguration:configuration
                                    privacyConfiguration:privacyConfiguration
                                                   error:&error
                                    monitoringDispatcher:self.monitoringDispatcher];
                    if (ad) {
                        [ads addObject:ad];
                    }
                }
                completionHandler(ads, error);
                return;
            } else {
                completionHandler(nil, error);
                return;
            }
        } else {
            completionHandler(nil, error);
            return;
        }
    }
    NSURLRequest *urlRequest = [self adSyncURLRequestForURL:self.environment.adSyncURL adConfiguration:configuration privacyConfiguration:privacyConfiguration];
    if (!urlRequest) {
        completionHandler(nil, nil);
        return;
    }
    [self.monitoringDispatcher sendLoadEvent:OGALoadEventLoadSendAdSyncRequest adConfiguration:configuration];
    [self.networkClient performRequest:urlRequest
        completionHandlerWithUrlResponse:^(NSData *_Nullable result, NSURLResponse *_Nullable response, NSError *_Nullable error) {
            [self handleAdSyncRequestWithAdConfiguration:configuration
                                    privacyConfiguration:privacyConfiguration
                                                  result:result
                                                response:response
                                                   error:error
                                       completionHandler:completionHandler];
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

- (void)handleAdSyncRequestWithAdConfiguration:(OGAAdConfiguration *)adConfiguration
                          privacyConfiguration:(OGAAdPrivacyConfiguration *)privacyConfiguration
                                        result:(NSData *_Nullable)result
                                      response:(NSURLResponse *_Nullable)response
                                         error:(NSError *_Nullable)error
                             completionHandler:(void (^)(NSArray<OGAAd *> *ads, NSError *_Nullable error))completionHandler {
    if (((NSHTTPURLResponse *)response).statusCode == 204) {
        completionHandler(nil, [OguryAdError noFillFrom:adConfiguration.isHeaderBidding ? OguryAdIntegrationTypeHeaderBidding : OguryAdIntegrationTypeDirect]);
        return;
    }

    // these tracks are sent only if there is a parse (i.e. status 200, even if there is an error (i.e. parsing error in this case))
    if (((NSHTTPURLResponse *)response).statusCode == 200) {
        [self.monitoringDispatcher sendLoadEvent:OGALoadEventLoadAdSyncResponseReceived adConfiguration:adConfiguration details:nil];
        [self.monitoringDispatcher sendLoadEvent:OGALoadEventAdParseStarted adConfiguration:adConfiguration];
    }

    if (error) {
        NSUInteger code = ((NSHTTPURLResponse *)response).statusCode ?: 200;
        switch (code) {
            case 400 ... 499:
            case 500 ... 599:
                completionHandler(nil, [OguryAdError adRequestFailedWithCode:code]);
                break;

            default:
                completionHandler(nil, error);
                break;
        }
        return;
    }

    NSError *parseError;
    NSArray<OGAAd *> *ads = [self parseAdsFromData:result adConfiguration:adConfiguration privacyConfiguration:privacyConfiguration error:&parseError];
    if (parseError) {
        completionHandler(nil, [parseError isKindOfClass:[OguryError class]] ? parseError : [OguryAdError adParsingFailedWithStackTrace:parseError.localizedDescription]);
        return;
    }

    if (!ads) {
        completionHandler(nil, [OguryAdError adParsingFailedWithStackTrace:@"The ad's array is empty, that should not happen"]);
        return;
    }

    completionHandler(ads, nil);
}

- (NSArray<OGAAd *> *_Nullable)parseAdsFromData:(NSData *_Nullable)data
                                adConfiguration:(OGAAdConfiguration *)adConfiguration
                           privacyConfiguration:(OGAAdPrivacyConfiguration *)privacyConfiguration
                                          error:(NSError *_Nonnull *_Nonnull)error {
    NSArray<OGAAd *> *ads = [[NSArray alloc] init];

    if (data && data.length > 0) {
        NSError *parseError;

        NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];

        if (parseError) {
            *error = parseError;
            return nil;
        }

        ads = [OGAAdParser parseJSONResponse:responseJSON
                             adConfiguration:adConfiguration
                        privacyConfiguration:privacyConfiguration
                                       error:error
                        monitoringDispatcher:self.monitoringDispatcher];
    } else {
        *error = [OguryAdError adParsingFailedWithStackTrace:@"No ad received"];
        return nil;
    }

    return ads;
}

- (NSURLRequest *_Nullable)adSyncURLRequestForURL:(NSURL *)url adConfiguration:(OGAAdConfiguration *)adConfiguration privacyConfiguration:(OGAAdPrivacyConfiguration *)privacyConfiguration {
    OguryNetworkRequestBuilder *requestBuilder = [[OguryNetworkRequestBuilder alloc] initWithHTTPMethod:OguryNetworkRequestHTTPMethodPOST andURL:url];

    // Payload
    NSError *serializationError;
    NSDictionary *jsonPayload = [adConfiguration payloadForAdSyncWithAssetKeyManager:self.assetKeyManager
                                                                        reachability:self.reachability
                                                                   profigPersistence:self.profigPersistence
                                                              isOmidFrameworkPresent:self.omidService.isOMIDFrameworkPresent];
    NSData *payload = [NSJSONSerialization dataWithJSONObject:jsonPayload options:0 error:&serializationError];

    if (serializationError || payload == nil) {
        [self.log logAdError:serializationError ?: [OguryError createOguryErrorWithCode:OGAInternalUnknownError]
            forAdConfiguration:adConfiguration
                       message:@"Failed to serialize ad sync"];
        return nil;
    }

    [requestBuilder setPayload:payload];

    return [requestBuilder build];
}

- (void)fetchCustomCloseWithURL:(NSURL *)url {
    OguryNetworkRequestBuilder *requestBuilder = [[OguryNetworkRequestBuilder alloc] initWithHTTPMethod:OguryNetworkRequestHTTPMethodGET andURL:url];

    NSURLRequest *urlRequest = [requestBuilder build];

    if (!urlRequest) {
        return;
    }

    [self.networkClient performRequest:urlRequest
                     completionHandler:^(NSData *_Nullable result, NSError *_Nullable error){
                         // Not used
                     }];
}

@end

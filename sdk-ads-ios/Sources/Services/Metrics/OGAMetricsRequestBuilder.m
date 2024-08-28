//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import "OGAMetricsRequestBuilder.h"
#import <OguryCore/OguryNetworkRequestBuilder.h>
#import "OGALog.h"
#import "OGAAdHistoryEvent.h"
#import "OGAPreCacheEvent.h"
#import "OGATrackEvent.h"
#import "OGAEventHeaderBuilder.h"
#import "OGAEnvironmentManager.h"
#import "OGAEventHeaderBuilder.h"
#import "OGAAssetKeyManager.h"
#import "OGAProfigDao.h"
#import "NSDate+OGAFormatter.h"
#import "OGAConfigurationUtils.h"
#import "OguryAdsError.h"
#import "OguryError+Ads.h"

#warning FIXME - Implements unit tests

NSString *const OGAMetricsRequestBuilderConnectivityKey = @"connectivity";
NSString *const OGAMetricsRequestBuilderAtKey = @"at";
NSString *const OGAMetricsRequestBuilderCountryKey = @"country";
NSString *const OGAMetricsRequestBuilderAssetKeyKey = @"apps_publishers";
NSString *const OGAMetricsRequestBuilderVersionKey = @"version";
NSString *const OGAMetricsRequestBuilderBuildKey = @"build";

NSString *const OGAMetricsRequestBuilderContentKey = @"content";

@interface OGAMetricsRequestBuilder ()

@property(nonatomic, retain) OGAAssetKeyManager *assetKeyManager;
@property(nonatomic, retain) OGAEnvironmentManager *environment;
@property(nonatomic, strong) OGAProfigDao *profigDao;
@property(nonatomic, strong) OGALog *log;

@end

@implementation OGAMetricsRequestBuilder

#pragma mark - Initialization

- (instancetype)init {
    return [self initWithAssetKeyManager:[OGAAssetKeyManager shared]
                             environment:[OGAEnvironmentManager shared]
                                     log:[OGALog shared]
                               profigDao:[OGAProfigDao shared]];
}

- (instancetype)initWithAssetKeyManager:(OGAAssetKeyManager *)assetKeyManager
                            environment:(OGAEnvironmentManager *)environment
                                    log:(OGALog *)log
                              profigDao:(OGAProfigDao *)profigDao {
    if (self = [super init]) {
        _assetKeyManager = assetKeyManager;
        _environment = environment;
        _log = log;
        _profigDao = profigDao;
    }

    return self;
}

#pragma mark - Methods

- (NSURLRequest *)buildRequest:(OGAMetricEvent *)event {
    NSURL *adURL = [self buildUrl:event];
    if (!adURL) {
        return nil;
    }

    NSDictionary *bodyContent = [self buildBody:event];
    if (!bodyContent) {
        return nil;
    }

    OguryNetworkRequestBuilder *requestBuilder = [[OguryNetworkRequestBuilder alloc] initWithHTTPMethod:OguryNetworkRequestHTTPMethodPOST andURL:adURL];
    [requestBuilder addHeaders:[OGAEventHeaderBuilder buildFor:event]];

    NSError *serializationError;
    NSData *payload = [NSJSONSerialization dataWithJSONObject:bodyContent options:0 error:&serializationError];
    if (serializationError || payload == nil) {
        [self.log logError:serializationError ?: [OguryError createOguryErrorWithCode:OGAInternalUnknownError]
                   message:@"Failed to serialize metrics"];
        return nil;
    }

    [requestBuilder setPayload:payload];

    return [requestBuilder build];
}

- (NSURL *)buildUrl:(OGAMetricEvent *)event {
    if ([event isKindOfClass:[OGAAdHistoryEvent class]]) {
        return event.trackURL ?: self.environment.adHistoryURL;
    } else if ([event isKindOfClass:[OGAPreCacheEvent class]]) {
        return event.trackURL ?: self.environment.preCacheURL;
    } else if ([event isKindOfClass:[OGATrackEvent class]]) {
        return event.trackURL ?: self.environment.trackURL;
    }

    return nil;
}

- (NSDictionary<NSString *, id> *)buildBody:(OGAMetricEvent *)event {
    if ([event isKindOfClass:[OGAAdHistoryEvent class]]) {
        return [self buildBodyForAdHistoryEvent:(OGAAdHistoryEvent *)event];
    } else if ([event isKindOfClass:[OGAPreCacheEvent class]]) {
        return [self buildBodyForPreCacheEvent:(OGAPreCacheEvent *)event];
    } else if ([event isKindOfClass:[OGATrackEvent class]]) {
        return [self buildBodyForTrackEvent:(OGATrackEvent *)event];
    }

    return nil;
}

- (NSDictionary<NSString *, id> *)buildBodyForAdHistoryEvent:(OGAAdHistoryEvent *)event {
    NSMutableDictionary<NSString *, id> *body = [self trackAndAdHistoryBody];
    body[OGAMetricsRequestBuilderContentKey] = [event toDictionary];
    return body;
}

- (NSDictionary<NSString *, id> *)buildBodyForPreCacheEvent:(OGAPreCacheEvent *)event {
    NSMutableDictionary<NSString *, id> *body = [NSMutableDictionary dictionary];
    body[OGAMetricsRequestBuilderContentKey] = @[ [event toDictionary] ];
    return body;
}

- (NSDictionary<NSString *, id> *)buildBodyForTrackEvent:(OGATrackEvent *)event {
    NSMutableDictionary<NSString *, id> *body = [self trackAndAdHistoryBody];
    body[OGAMetricsRequestBuilderContentKey] = [event toDictionary];
    return body;
}

- (NSMutableDictionary<NSString *, id> *)trackAndAdHistoryBody {
    NSMutableDictionary<NSString *, id> *body = [NSMutableDictionary dictionary];
    OGAAdPrivacyConfiguration *privacyConfiguration = [self.profigDao.profigFullResponse getPrivacyConfiguration];
    if ([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionConnectivity]) {
        body[OGAMetricsRequestBuilderConnectivityKey] = [OGAConfigurationUtils currentNetwork];
    }
    body[OGAMetricsRequestBuilderAtKey] = [[NSDate date] oguryAdsUtcFormattedString];
    body[OGAMetricsRequestBuilderAssetKeyKey] = @[ self.assetKeyManager.assetKey != nil ? self.assetKeyManager.assetKey : @"" ];
    body[OGAMetricsRequestBuilderVersionKey] = OGA_SDK_VERSION;
    NSString *buildVersionString = OGA_SDK_BUILD_VERSION;
    body[OGAMetricsRequestBuilderBuildKey] = [NSNumber numberWithInt:[buildVersionString intValue]];
    return body;
}

@end

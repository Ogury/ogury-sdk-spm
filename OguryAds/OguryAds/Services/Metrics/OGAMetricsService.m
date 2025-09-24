//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import "OGAMetricsService.h"
#import <OguryCore/OguryNetworkClient.h>
#import "OGAAd.h"
#import "OGAMetricsRequestBuilder.h"
#import "OGAMetricsServiceSendEventOperation.h"
#import "OGAMetricsServiceSendCustomEventOperation.h"
#import "OGAAdHistoryEvent.h"
#import "OGAPreCacheEvent.h"
#import "OGATrackEvent.h"

@interface OGAMetricsService ()

#pragma mark - Properties

@property(nonatomic, strong) OguryNetworkClient *networkClient;
@property(nonatomic, strong) OGAMetricsRequestBuilder *metricsRequestBuilder;
@property(nonatomic, strong) NSOperationQueue *operationQueue;
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<NSOperation *> *> *operationsPerAdvertId;
@property(nonatomic, assign) OGATrackingMask trackingMask;

@end

@implementation OGAMetricsService

#pragma mark - Initialization

- (instancetype)init {
    return [self initWithNetworkClient:[OguryNetworkClient shared] metricsRequestBuilder:[[OGAMetricsRequestBuilder alloc] init]];
}

- (instancetype)initWithNetworkClient:(OguryNetworkClient *)networkClient
                metricsRequestBuilder:(OGAMetricsRequestBuilder *)metricsRequestBuilder {
    if (self = [super init]) {
        _networkClient = networkClient;
        _metricsRequestBuilder = metricsRequestBuilder;
        _trackingMask = OGATrackingMaskNone;

        _operationsPerAdvertId = [[NSMutableDictionary alloc] init];

        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
        _operationQueue.qualityOfService = NSQualityOfServiceBackground;
        _operationQueue.name = NSStringFromClass([self class]);
    }
    return self;
}

#pragma mark - Public methods

+ (instancetype)shared {
    static dispatch_once_t token;
    static OGAMetricsService *instance;
    dispatch_once(&token, ^{
        instance = [[OGAMetricsService alloc] init];
    });
    return instance;
}

#pragma mark - Methods
- (void)setTrackingMask:(OGATrackingMask)trackingMask {
    _trackingMask = trackingMask;
}

- (BOOL)canSendEvent:(OGAMetricEvent *)event {
    if ([event isKindOfClass:[OGAAdHistoryEvent class]]) {
        return YES;
    }
    if ([event isKindOfClass:[OGAPreCacheEvent class]]) {
        return self.trackingMask & OGATrackingMaskPreCache;
    }
    if ([event isKindOfClass:[OGATrackEvent class]]) {
        return self.trackingMask & OGATrackingMaskCache;
    }
    return YES;
}

- (void)sendEvent:(OGAMetricEvent *)event {
    if (![self canSendEvent:event]) {
        return;
    }

    OGAMetricsServiceSendEventOperation *operation = [[OGAMetricsServiceSendEventOperation alloc] initWithEvent:event];
    [self.operationQueue addOperation:operation];
}

- (void)sendTrackEventForAd:(OGAAd *)ad withURL:(NSString *)url {
    if (!(self.trackingMask & OGATrackingMaskCache)) {
        return;
    }

    OGAMetricsServiceSendCustomEventOperation *operation = [[OGAMetricsServiceSendCustomEventOperation alloc] initWithEventURL:url];

    [self.operationQueue addOperation:operation];
}

- (void)enqueueEvent:(OGAMetricEvent *)event {
    if (![self canSendEvent:event]) {
        return;
    }

    OGAMetricsServiceSendEventOperation *operation = [[OGAMetricsServiceSendEventOperation alloc] initWithEvent:event];

    [self handleOperation:operation forAdvertId:event.advertId];
}

- (void)enqueueTrackEventForAd:(OGAAd *)ad withURL:(NSString *)url {
    if (!(self.trackingMask & OGATrackingMaskCache)) {
        return;
    }

    OGAMetricsServiceSendCustomEventOperation *operation = [[OGAMetricsServiceSendCustomEventOperation alloc] initWithEventURL:url];

    [self handleOperation:operation forAdvertId:ad.identifier];
}

- (void)handleOperation:(NSOperation *)operation forAdvertId:(NSString *)advertId {
    if (self.operationsPerAdvertId[advertId]) {
        [self.operationsPerAdvertId[advertId] addObject:operation];
    } else {
        [self.operationQueue addOperation:operation];
    }
}

- (void)holdEventsForAd:(OGAAd *)ad {
    self.operationsPerAdvertId[ad.identifier] = [[NSMutableArray alloc] init];
}

- (void)releaseEventsForAd:(OGAAd *)ad {
    NSArray *operationsForAd = self.operationsPerAdvertId[ad.identifier];

    if (operationsForAd) {
        [self.operationQueue addOperations:operationsForAd waitUntilFinished:NO];

        self.operationsPerAdvertId = nil;
    }
}

@end

//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGAMetricsServiceSendEventOperation.h"
#import "OGAMetricEvent.h"
#import "OGAMetricsRequestBuilder.h"
#import <OguryCore/OguryNetworkClient.h>
#import "OGALog.h"

@interface OGAMetricsServiceSendEventOperation ()

#pragma mark - Properties

@property(nonatomic, strong, readonly) OGAMetricEvent *event;
@property(nonatomic, strong) OGAMetricsRequestBuilder *metricsRequestBuilder;
@property(nonatomic, strong) OguryNetworkClient *networkClient;
@property(nonatomic, strong) OGALog *log;

@end

@implementation OGAMetricsServiceSendEventOperation

#pragma mark - Initialization

- (instancetype)initWithEvent:(OGAMetricEvent *)event {
    return [self initWithEvent:event metricsRequestBuilder:[[OGAMetricsRequestBuilder alloc] init] networkClient:OguryNetworkClient.shared log:[OGALog shared]];
}

- (instancetype)initWithEvent:(OGAMetricEvent *)event metricsRequestBuilder:(OGAMetricsRequestBuilder *)metricsRequestBuilder networkClient:(OguryNetworkClient *)networkClient log:(OGALog *)log {
    if (self = [super init]) {
        _event = event;
        _metricsRequestBuilder = metricsRequestBuilder;
        _networkClient = networkClient;
        _log = log;
    }

    return self;
}

#pragma mark - Methods

- (void)main {
    [super main];

    NSURLRequest *eventRequest = [self.metricsRequestBuilder buildRequest:self.event];
    if (!eventRequest) {
        return;
    }

    [self.networkClient performRequest:eventRequest
                     completionHandler:^(NSData *_Nullable result, NSError *_Nullable error) {
                         if (error) {
                             [self.log logErrorFormat:error format:@"An error occurred while sending track event [eventName: %@]", self.event.eventName];
                         }
                     }];
}

@end

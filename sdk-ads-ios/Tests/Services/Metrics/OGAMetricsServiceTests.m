//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OguryCore/OguryNetworkClient.h>

#import <OCMock/OCMock.h>
#import "OGAMetricsService.h"
#import "OGAMetricsRequestBuilder.h"

NSString *const OGAMetricsServiceTestsResult = @"OK";

@interface OGAMetricsService (Testing)

- (instancetype)initWithNetworkClient:(OguryNetworkClient *)networkClient
                metricsRequestBuilder:(OGAMetricsRequestBuilder *)metricsRequestBuilder;

@end

@interface OGAMetricsServiceTests : XCTestCase

@property(nonatomic, strong) OguryNetworkClient *networkClient;
@property(nonatomic, strong) OGAMetricsRequestBuilder *metricsRequestBuilder;
@property(nonatomic, strong) OGAMetricsService *metricsService;

@end

@implementation OGAMetricsServiceTests

- (void)setUp {
    self.networkClient = OCMClassMock([OguryNetworkClient class]);
    self.metricsRequestBuilder = OCMClassMock([OGAMetricsRequestBuilder class]);

    OGAMetricsService *metricsService = [[OGAMetricsService alloc] initWithNetworkClient:self.networkClient
                                                                   metricsRequestBuilder:self.metricsRequestBuilder];
    self.metricsService = OCMPartialMock(metricsService);
}

- (void)testSendEvent {
    OGAMetricEvent *event = OCMClassMock([OGAMetricEvent class]);
    OCMStub([self.metricsService sendEvent:[OCMArg any]]);

    [self.metricsService sendEvent:event];

    OCMVerify([self.metricsService sendEvent:event]);
}

- (void)testEnqueueEvent {
    OGAMetricEvent *event = OCMClassMock([OGAMetricEvent class]);
    OCMStub([self.metricsService enqueueEvent:[OCMArg any]]);

    [self.metricsService enqueueEvent:event];

    OCMVerify([self.metricsService enqueueEvent:event]);
}

@end

//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGAMetricsServiceSendEventOperation.h"
#import "OGAMetricEvent.h"
#import "OGAMetricsRequestBuilder.h"
#import <OguryCore/OguryNetworkClient.h>
#import <OguryCore/OguryNetworkRequestBuilder.h>

static NSString *const DefaultEventURL = @"https://www.google.com";

@interface OGAMetricsServiceSendEventOperation (Testing)

@property(nonatomic, strong) NSString *eventURL;
@property(nonatomic, strong) OGAMetricsRequestBuilder *metricsRequestBuilder;
@property(nonatomic, strong) OguryNetworkClient *networkClient;

@end

@interface OGAMetricsServiceSendEventOperationTests : XCTestCase

@end

@implementation OGAMetricsServiceSendEventOperationTests

#pragma mark - Tests

- (void)test_shouldSendCustomEvent {
    OGAMetricEvent *mockEvent = OCMClassMock([OGAMetricEvent class]);

    OGAMetricsRequestBuilder *mockMetricsRequestBuilder = OCMClassMock([OGAMetricsRequestBuilder class]);
    OCMStub([mockMetricsRequestBuilder buildRequest:[OCMArg any]]).andReturn([NSURLRequest new]);

    OGAMetricsServiceSendEventOperation *operation = OCMPartialMock([[OGAMetricsServiceSendEventOperation alloc] initWithEvent:mockEvent]);
    operation.metricsRequestBuilder = mockMetricsRequestBuilder;

    OguryNetworkClient *mockNetworkClient = OCMClassMock([OguryNetworkClient class]);
    operation.networkClient = mockNetworkClient;

    [operation start];

    OCMVerify([mockMetricsRequestBuilder buildRequest:mockEvent]);
    OCMVerify([mockNetworkClient performRequest:OCMOCK_ANY completionHandler:OCMOCK_ANY]);
}

@end

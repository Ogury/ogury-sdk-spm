//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGAMetricsServiceSendCustomEventOperation.h"
#import <OguryCore/OguryNetworkClient.h>
#import <OguryCore/OguryNetworkRequestBuilder.h>

static NSString *const DefaultEventURL = @"https://www.google.com";

@interface OGAMetricsServiceSendCustomEventOperation (Testing)

@property(nonatomic, strong) NSString *eventURL;
@property(nonatomic, strong) OguryNetworkClient *networkClient;

@end

@interface OGAMetricsServiceSendCustomEventOperationTests : XCTestCase

@end

@implementation OGAMetricsServiceSendCustomEventOperationTests

#pragma mark - Tests

- (void)test_shouldSendCustomEvent {
    OGAMetricsServiceSendCustomEventOperation *operation = OCMPartialMock([[OGAMetricsServiceSendCustomEventOperation alloc] initWithEventURL:DefaultEventURL]);

    OguryNetworkClient *mockNetworkClient = OCMClassMock([OguryNetworkClient class]);
    operation.networkClient = mockNetworkClient;

    [operation start];

    OCMVerify([mockNetworkClient performRequest:OCMOCK_ANY completionHandler:OCMOCK_ANY]);
}

@end

//
// Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <OguryCore/OguryNetworkClient.h>

#import "OGWMonitoringInfoSender.h"
#import "OGWMonitoringInfoHeadersBuilder.h"
#import "OGWMonitoringInfoSerializer.h"

NSString *const OGWMonitorInfoSenderTestsURL = @"https://example.com";

extern NSString * const OGWMonitoringInfoSenderProductionURL;
extern NSString * const OGWMonitoringInfoSenderStagingURL;
extern NSString * const OGWMonitoringInfoSenderDevcURL;

@interface OGWMonitoringInfoSender (Testing)

- (instancetype)initWithURL:(NSURL *)url
             headersBuilder:(OGWMonitoringInfoHeadersBuilder *)headersBuilder
                 serializer:(OGWMonitoringInfoSerializer *)serializer
              networkClient:(OguryNetworkClient *)networkClient;

+ (NSURL *)urlForEnvironment:(NSString *)env;

@end

@interface OGWMonitorInfoSenderTests : XCTestCase

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) OGWMonitoringInfoHeadersBuilder *headersBuilder;
@property (nonatomic, strong) OGWMonitoringInfoSerializer *serializer;
@property (nonatomic, strong) OguryNetworkClient *networkClient;

@property (nonatomic, strong) OGWMonitoringInfoSender *sender;

@end

@implementation OGWMonitorInfoSenderTests

- (void)setUp {
    self.url = [[NSURL alloc] initWithString:OGWMonitorInfoSenderTestsURL];
    self.headersBuilder = OCMClassMock([OGWMonitoringInfoHeadersBuilder class]);
    self.serializer = OCMClassMock([OGWMonitoringInfoSerializer class]);
    self.networkClient = OCMClassMock([OguryNetworkClient class]);

    OGWMonitoringInfoSender *sender = [[OGWMonitoringInfoSender alloc] initWithURL:self.url
                                                                    headersBuilder:self.headersBuilder
                                                                        serializer:self.serializer
                                                                     networkClient:self.networkClient];
    self.sender = OCMPartialMock(sender);
}

#pragma mark - Methods

- (void)testSend {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback called."];
    OGWMonitoringInfo *monitoringInfo = OCMClassMock([OGWMonitoringInfo class]);
    NSData *serializedMonitoringInfo = [OGWMonitorInfoSenderTestsURL dataUsingEncoding:NSUTF8StringEncoding];
    OCMStub([self.serializer serialize:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(serializedMonitoringInfo);
    OCMStub([self.networkClient performRequest:[OCMArg any] completionHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void (^completionHandler)(NSData *, NSError *);
        [invocation getArgument:&completionHandler atIndex:3];
        if (completionHandler) {
            completionHandler(nil, nil);
        }
    });

    [self.sender send:monitoringInfo completionHandler:^(NSError *error) {
        XCTAssertNil(error);
        [expectation fulfill];
    }];

    __block NSURLRequest *request;
    OCMVerify([self.networkClient performRequest:[OCMArg checkWithBlock:^BOOL(id obj) {
        request = obj;
        return YES;
    }] completionHandler:[OCMArg any]]);
    XCTAssertEqualObjects(request.URL, self.url);
    XCTAssertEqualObjects(request.HTTPMethod, @"POST");
    XCTAssertNotNil(request.HTTPBody);

    OCMVerify([self.headersBuilder build:monitoringInfo]);

    [self waitForExpectations:@[expectation] timeout:0.5];
}

- (void)testSend_failedToSerialize {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback called."];
    NSError *serializeError = OCMClassMock([NSError class]);
    OGWMonitoringInfo *monitoringInfo = OCMClassMock([OGWMonitoringInfo class]);
    OCMStub([self.serializer serialize:[OCMArg any] error:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
        NSError *__autoreleasing *errorPointer = nil;
        [invocation getArgument:&errorPointer atIndex:3];
        *errorPointer = serializeError;
    }).andReturn(nil);

    [self.sender send:monitoringInfo completionHandler:^(NSError *error) {
        XCTAssertEqual(error, serializeError);
        [expectation fulfill];
    }];

    [self waitForExpectations:@[expectation] timeout:0.5];
}

- (void)testSend_failedToSendNetworkRequest {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback called."];
    NSURL *url = [[NSURL alloc] initWithString:OGWMonitorInfoSenderTestsURL];
    OGWMonitoringInfo *monitoringInfo = OCMClassMock([OGWMonitoringInfo class]);
    NSData *serializedMonitoringInfo = [OGWMonitorInfoSenderTestsURL dataUsingEncoding:NSUTF8StringEncoding];
    __block NSError *networkError = OCMClassMock([NSError class]);
    OCMStub([self.serializer serialize:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(serializedMonitoringInfo);
    OCMStub([self.networkClient performRequest:[OCMArg any] completionHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void (^completionHandler)(NSData *, NSError *);
        [invocation getArgument:&completionHandler atIndex:3];
        if (completionHandler) {
            completionHandler(nil, networkError);
        }
    });

    [self.sender send:monitoringInfo completionHandler:^(NSError *error) {
        XCTAssertEqual(error, networkError);
        [expectation fulfill];
    }];

    [self waitForExpectations:@[expectation] timeout:0.5];
}

- (void)testUrlForEnvironment {
    XCTAssertEqualObjects([OGWMonitoringInfoSender urlForEnvironment:@"devc"], [[NSURL alloc] initWithString:OGWMonitoringInfoSenderDevcURL]);
    XCTAssertEqualObjects([OGWMonitoringInfoSender urlForEnvironment:@"staging"], [[NSURL alloc] initWithString:OGWMonitoringInfoSenderStagingURL]);
    XCTAssertEqualObjects([OGWMonitoringInfoSender urlForEnvironment:@"prod"], [[NSURL alloc] initWithString:OGWMonitoringInfoSenderProductionURL]);
    XCTAssertEqualObjects([OGWMonitoringInfoSender urlForEnvironment:@"beta"], [[NSURL alloc] initWithString:OGWMonitoringInfoSenderProductionURL]);
    XCTAssertEqualObjects([OGWMonitoringInfoSender urlForEnvironment:@"release"], [[NSURL alloc] initWithString:OGWMonitoringInfoSenderProductionURL]);

    XCTAssertNil([OGWMonitoringInfoSender urlForEnvironment:@""]);
}

@end

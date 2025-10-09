//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <OguryCore/OguryNetworkClient.h>
#import <XCTest/XCTest.h>
#import "OGAAdMonitorEvent.h"
#import "OGAAdServerMonitorRequestBuilder.h"
#import "OGAConfigurationUtils.h"
#import "OGALog.h"
#import "OGAMonitoringConstants.h"
#import "OGMPersistanceStore.h"
#import "OGMServerMonitor.h"
#import "OGAAdMonitorEvent+Tests.h"

@interface OGMServerMonitor ()

- (instancetype)initWithRequestBuilder:(id<OGMServerMonitorRequestBuildable>)requestBuilder
                         networkClient:(OguryNetworkClient *)networkClient
                      persistanceStore:(id<OGMPersistanceStore>)persistanceStore
                                   log:(OGALog *)log;
- (void)updateSavedEventsWith:(NSArray<id<OGMEventMonitorable>> *)events;
- (void)cleanEvents;
- (void)monitorEvents:(NSArray<id<OGMEventMonitorable>> *)events;

@property(nonatomic, strong) OguryNetworkClient *networkClient;
@property(nonatomic, strong) OGAAdServerMonitorRequestBuilder *requestBuilder;
@property(nonatomic, strong) NSMutableArray<id<OGMEventMonitorable>> *pendingEvents;
;

@end

@interface OGAServerMonitorTest : XCTestCase

@property(nonatomic, strong) OguryNetworkClient *networkClientMock;
@property(nonatomic, strong) OGAAdServerMonitorRequestBuilder *requestBuilderMock;
@property(nonatomic, strong) OGALog *logMock;
@property(nonatomic, strong) OGMServerMonitor *monitor;
@property(nonatomic, strong) id<OGMPersistanceStore> persistanceStoreMock;

@end

static NSInteger const TestTimestamp = 1000;
static NSString *const TestSessionId = @"1001";
static NSString *const TestEventCode = @"LT-100";
static NSString *const TestEventName = @"test";
static OGMDispatchType const TestDispatchType = OGMDispatchTypeImmediate;
static NSString *const TestAdUnitId = @"testAdunitId";
static NSString *const TestCampaignId = @"testCampaignId";
static NSString *const TestCreativeId = @"testCreativeId";
static NSString *const TestUrl = @"https://www.google.com/";
static NSString *const TestDetail = @"detailTest";
static NSString *const TestContent = @"detailContentTest";

static OGAAdMonitorEvent *event;

@implementation OGAServerMonitorTest

+ (void)setUp {
    NSDictionary *firstDictionnary = @{@"name" : @"dsp", @"value" : @"{\"creative_id\": \"123\", \"region\":\"east-us\"}", @"version" : @2};
    NSDictionary *secondDictionnary = @{@"name" : @"vast_version", @"value" : @"4.0", @"version" : @1};
    NSArray *extras = @[ firstDictionnary, secondDictionnary ];
    event = [[OGAAdMonitorEvent alloc] initWithTimestamp:[NSNumber numberWithInt:TestTimestamp]
                                               sessionId:TestSessionId
                                               eventCode:TestEventCode
                                               eventName:TestEventName
                                            dispatchType:TestDispatchType
                                                adUnitId:TestAdUnitId
                                               mediation:nil
                                              campaignId:TestCampaignId
                                              creativeId:TestCreativeId
                                                  extras:extras
                                       detailsDictionary:@{TestDetail : TestContent}
                                               errorType:nil
                                            errorContent:nil];
}
- (void)setUp {
    _networkClientMock = OCMClassMock([OguryNetworkClient class]);
    _persistanceStoreMock = OCMProtocolMock(@protocol(OGMPersistanceStore));

    _requestBuilderMock = OCMPartialMock([[OGAAdServerMonitorRequestBuilder alloc] initWithUrl:[NSURL URLWithString:TestUrl]]);

    _logMock = OCMClassMock([OGALog class]);

    _monitor = OCMPartialMock([[OGMServerMonitor alloc] initWithRequestBuilder:self.requestBuilderMock
                                                                 networkClient:self.networkClientMock
                                                              persistanceStore:self.persistanceStoreMock
                                                                           log:self.logMock]);
}

- (void)testWhenEventIsDispatchedToMonitor_ThenNetworkEngineIsCalled {
    OCMStub([self.requestBuilderMock buildRequestWithEvents:[OCMArg any]]).andReturn([NSURLRequest new]);
    id configurationUtils = OCMClassMock([OGAConfigurationUtils class]);
    OCMStub(OCMClassMethod([configurationUtils isConnectedToInternet])).andReturn(YES);
    [self.monitor monitor:event];
    OCMVerify([self.networkClientMock performRequest:[OCMArg any] completionHandler:[OCMArg any]]);
    OCMVerify([self.requestBuilderMock buildRequestWithEvents:[OCMArg any]]);
    [configurationUtils stopMocking];
}

- (void)testWhenEventsAreSaved_ThenPersistentStoreIsCalled {
    [self.monitor updateSavedEventsWith:@[ event ]];
    OCMVerify([self.persistanceStoreMock saveEvents:@[ event ]]);
}

- (void)testWhenEventsAreRemoved_ThenPersistentStoreIsCalled {
    [self.monitor cleanEvents];
    OCMVerify([self.persistanceStoreMock cleanEvents]);
}

- (void)testWhenEventIsSaved_ThenEventIsProperlyStored {
    [self.monitor cleanEvents];
    XCTAssertTrue(self.monitor.pendingEvents.count == 0);
    [self.monitor updateSavedEventsWith:@[ event ]];
    XCTAssertTrue(self.monitor.pendingEvents.count == 1);
    XCTAssertEqualObjects(self.monitor.pendingEvents, @[ event ]);
}

- (void)testWhenEventIsSaved_ThenDispatchTypeOnlyIsUpdated {
    [self.monitor cleanEvents];
    NSDictionary *firstDictionnary = @{@"name" : @"dsp", @"value" : @"{\"creative_id\": \"123\", \"region\":\"east-us\"}", @"version" : @2};
    NSDictionary *secondDictionnary = @{@"name" : @"vast_version", @"value" : @"4.0", @"version" : @1};
    NSArray *expectedArray = @[ firstDictionnary, secondDictionnary ];
    OGAAdMonitorEvent *event = [[OGAAdMonitorEvent alloc] initWithTimestamp:[NSNumber numberWithInt:TestTimestamp]
                                                                  sessionId:TestSessionId
                                                                  eventCode:TestEventCode
                                                                  eventName:TestEventName
                                                               dispatchType:TestDispatchType
                                                                   adUnitId:TestAdUnitId
                                                                  mediation:nil
                                                                 campaignId:TestCampaignId
                                                                 creativeId:TestCreativeId
                                                                     extras:expectedArray
                                                          detailsDictionary:@{TestDetail : TestContent}
                                                                  errorType:nil
                                                               errorContent:nil];
    [self.monitor updateSavedEventsWith:@[ event ]];
    XCTAssertTrue(self.monitor.pendingEvents.count == 1);
    XCTAssertTrue(((id<OGMEventServerMonitorable>)self.monitor.pendingEvents[0]).dispatchType == OGMDispatchTypeDeferred);
    ((id<OGMEventServerMonitorable>)self.monitor.pendingEvents[0]).dispatchType = OGMDispatchTypeImmediate;
    // only this property is updated
    XCTAssertEqualObjects(self.monitor.pendingEvents[0], event);
}

- (void)testWhenEventsAreSaved_ThenEventsAreProperlyStored {
    [self.monitor cleanEvents];
    NSArray *events = @[ event, event ];
    XCTAssertTrue(self.monitor.pendingEvents.count == 0);
    [self.monitor updateSavedEventsWith:events];
    XCTAssertTrue(self.monitor.pendingEvents.count == 2);
    XCTAssertEqualObjects(self.monitor.pendingEvents, events);
}

- (void)testWhenThereIsNoInternetConnection_ThenEvensAreSaved {
    id configurationUtils = OCMClassMock([OGAConfigurationUtils class]);
    OCMStub(OCMClassMethod([configurationUtils isConnectedToInternet])).andReturn(NO);
    [self.monitor monitorEvents:@[ event ]];
    OCMVerify([self.monitor updateSavedEventsWith:[OCMArg any]]);
    XCTAssertEqualObjects(self.monitor.pendingEvents, @[ event ]);
}

- (void)testWhenThereIsInternetConnection_ThenEvensAreNotSaved {
    id configurationUtils = OCMClassMock([OGAConfigurationUtils class]);
    OCMStub(OCMClassMethod([configurationUtils isConnectedToInternet])).andReturn(YES);
    [self.monitor monitorEvents:@[ event ]];
    OCMReject([self.monitor updateSavedEventsWith:[OCMArg any]]);
    XCTAssertTrue(self.monitor.pendingEvents.count == 0);
}

- (void)testWhenRequestFailsWithErrorUnknown_ThenEventsAreSaved {
    [self testEventsAreSavedWhenRequestFailsWith:NSURLErrorUnknown];
}

- (void)testWhenRequestFailsWithErrorCancelled_ThenEventsAreSaved {
    [self testEventsAreSavedWhenRequestFailsWith:NSURLErrorCancelled];
}

- (void)testWhenRequestFailsWithErrorTimedOut_ThenEventsAreSaved {
    [self testEventsAreSavedWhenRequestFailsWith:NSURLErrorTimedOut];
}

- (void)testWhenRequestFailsWithErrorCannotFindHost_ThenEventsAreSaved {
    [self testEventsAreSavedWhenRequestFailsWith:NSURLErrorCannotFindHost];
}

- (void)testWhenRequestFailsWithErrorCannotConnectToHost_ThenEventsAreSaved {
    [self testEventsAreSavedWhenRequestFailsWith:NSURLErrorCannotConnectToHost];
}

- (void)testWhenRequestFailsWithErrorNetworkConnectionLost_ThenEventsAreSaved {
    [self testEventsAreSavedWhenRequestFailsWith:NSURLErrorNetworkConnectionLost];
}

- (void)testWhenRequestFailsWithErrorNotConnectedToInternet_ThenEventsAreSaved {
    [self testEventsAreSavedWhenRequestFailsWith:NSURLErrorNotConnectedToInternet];
}

- (void)testWhenRequestFailsWithErrorZeroByteResource_ThenEventsAreSaved {
    [self testEventsAreSavedWhenRequestFailsWith:NSURLErrorZeroByteResource];
}

- (void)testWhenRequestFailsWithErrorDNSLookupFailed_ThenEventsAreSaved {
    [self testEventsAreSavedWhenRequestFailsWith:NSURLErrorDNSLookupFailed];
}

- (void)testWhenRequestFailsWithErrorHTTPTooManyRedirects_ThenEventsAreSaved {
    [self testEventsAreSavedWhenRequestFailsWith:NSURLErrorHTTPTooManyRedirects];
}

- (void)testWhenRequestFailsWithErrorResourceUnavailable_ThenEventsAreSaved {
    [self testEventsAreSavedWhenRequestFailsWith:NSURLErrorResourceUnavailable];
}

- (void)testWhenRequestFailsWithErrorBadServerResponse_ThenEventsAreSaved {
    [self testEventsAreSavedWhenRequestFailsWith:NSURLErrorBadServerResponse];
}

- (void)testEventsAreSavedWhenRequestFailsWith:(NSUInteger)errorCode {
    OCMStub([self.networkClientMock performRequest:[OCMArg any] completionHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        [invocation retainArguments];
        void (^completionHandler)(NSData *_Nullable result, NSError *_Nullable error);
        [invocation getArgument:&completionHandler atIndex:3];
        completionHandler(nil, [NSError errorWithDomain:@"" code:errorCode userInfo:nil]);
    });
    [self.monitor monitorEvents:@[ event ]];
    OCMVerify([self.monitor updateSavedEventsWith:[OCMArg any]]);
}

- (void)testWhenRequestFailsWithUnhandledError_ThenEventsAreNotSaved {
    OCMStub([self.networkClientMock performRequest:[OCMArg any] completionHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        [invocation retainArguments];
        void (^completionHandler)(NSData *_Nullable result, NSError *_Nullable error);
        [invocation getArgument:&completionHandler atIndex:3];
        completionHandler(nil, [NSError errorWithDomain:@"" code:NSURLErrorBadURL userInfo:nil]);
    });
    [self.monitor monitorEvents:@[ event ]];
    OCMReject([self.monitor updateSavedEventsWith:[OCMArg any]]);
}

@end

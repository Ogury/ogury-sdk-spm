//
// Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "OGWMonitoringInfoManager.h"
#import "OGWMonitoringInfoFetcher.h"
#import "OGWMonitoringInfoSender.h"
#import "OGWMonitoringInfoStore.h"

@interface OGWMonitoringInfoManager (Testing)

- (instancetype)initWithMonitoringInfoFetcher:(OGWMonitoringInfoFetcher *)monitoringInfoFetcher
                         monitoringInfoSender:(OGWMonitoringInfoSender *)monitoringInfoSender
                          monitoringInfoStore:(OGWMonitoringInfoStore *)monitoringInfoStore;

- (OGWMonitoringInfo *)createOrLoadMonitoringInfo;

- (void)sendAndStoreMonitoringInfo:(OGWMonitoringInfo *)monitoringInfo;

@end

@interface OGWMonitoringInfoManagerTests : XCTestCase

@property (nonatomic, strong) OGWMonitoringInfoFetcher *populator;
@property (nonatomic, strong) OGWMonitoringInfoSender *sender;
@property (nonatomic, strong) OGWMonitoringInfoStore *store;

@property (nonatomic, strong) OGWMonitoringInfo *populatorMonitoringInfo;

@property (nonatomic, strong) OGWMonitoringInfoManager *manager;

@end

@implementation OGWMonitoringInfoManagerTests

- (void)setUp {
    self.populator = OCMClassMock([OGWMonitoringInfoFetcher class]);
    self.sender = OCMClassMock([OGWMonitoringInfoSender class]);
    self.store = OCMClassMock([OGWMonitoringInfoStore class]);

    OGWMonitoringInfoManager *manager = [[OGWMonitoringInfoManager alloc] initWithMonitoringInfoFetcher:self.populator
                                                                                   monitoringInfoSender:self.sender
                                                                                    monitoringInfoStore:self.store];
    self.manager = OCMPartialMock(manager);
}

#pragma mark - Methods

- (void)testAppendMonitoringInfoAndSendIfNecessary_sendIfNewInfoAvailable {
    OguryConfiguration *configuration = OCMClassMock([OguryConfiguration class]);
    OGWMonitoringInfo *populatorMonitoringInfo = OCMClassMock([OGWMonitoringInfo class]);
    OGWMonitoringInfo *storedMonitoringInfo = OCMClassMock([OGWMonitoringInfo class]);
    OCMStub([self.populator populate:configuration]).andReturn(populatorMonitoringInfo);
    OCMStub([self.manager createOrLoadMonitoringInfo]).andReturn(storedMonitoringInfo);
    OCMStub([self.manager sendAndStoreMonitoringInfo:[OCMArg any]]);
    OCMStub([storedMonitoringInfo containsAll:populatorMonitoringInfo]).andReturn(NO);

    [self.manager appendMonitoringInfoAndSendIfNecessary:configuration];

    OCMVerify([self.manager sendAndStoreMonitoringInfo:storedMonitoringInfo]);
}

- (void)testAppendMonitoringInfoAndSendIfNecessary_doNotSendIfNoNewInfoAvailable {
    OguryConfiguration *configuration = OCMClassMock([OguryConfiguration class]);
    OGWMonitoringInfo *populatorMonitoringInfo = OCMClassMock([OGWMonitoringInfo class]);
    OGWMonitoringInfo *storedMonitoringInfo = OCMClassMock([OGWMonitoringInfo class]);
    OCMStub([self.populator populate:configuration]).andReturn(populatorMonitoringInfo);
    OCMStub([self.manager createOrLoadMonitoringInfo]).andReturn(storedMonitoringInfo);
    OCMStub([storedMonitoringInfo containsAll:populatorMonitoringInfo]).andReturn(YES);
    OCMReject([self.manager sendAndStoreMonitoringInfo:[OCMArg any]]);

    [self.manager appendMonitoringInfoAndSendIfNecessary:configuration];
}

- (void)testCreateOrLoadMonitoringInfo_existingMonitoringInfo {
    OGWMonitoringInfo *loadedMonitoringInfo = OCMClassMock([OGWMonitoringInfo class]);
    OCMStub([self.store load]).andReturn(loadedMonitoringInfo);

    OGWMonitoringInfo *monitoringInfo = [self.manager createOrLoadMonitoringInfo];

    XCTAssertEqual(monitoringInfo, loadedMonitoringInfo);
}

- (void)testCreateOrLoadMonitoringInfo_createEmptyMonitoringInfoIfNoInfoStored {
    OCMStub([self.store load]).andReturn(nil);

    OGWMonitoringInfo *monitoringInfo = [self.manager createOrLoadMonitoringInfo];

    XCTAssertEqual(monitoringInfo.monitoringInfoDict.count, 0);
}

- (void)testSendAndStoreMonitoringInfo {
    OGWMonitoringInfo *monitoringInfo = OCMClassMock([OGWMonitoringInfo class]);
    OCMStub([self.sender send:[OCMArg any] completionHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void (^completionHandler)(NSError *);
        [invocation getArgument:&completionHandler atIndex:3];
        completionHandler(nil);
    });
    OCMStub([self.store save:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(YES);

    [self.manager sendAndStoreMonitoringInfo:monitoringInfo];

    OCMVerify([self.store save:monitoringInfo error:[OCMArg anyObjectRef]]);
}

- (void)testSendAndStoreMonitoringInfo_failedToSend {
    OGWMonitoringInfo *monitoringInfo = OCMClassMock([OGWMonitoringInfo class]);
    __block NSError *sendError = OCMClassMock([NSError class]);
    OCMStub([self.sender send:[OCMArg any] completionHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void (^completionHandler)(NSError *);
        [invocation getArgument:&completionHandler atIndex:3];
        completionHandler(sendError);
    });
    OCMReject([self.store save:monitoringInfo error:[OCMArg anyObjectRef]]);

    [self.manager sendAndStoreMonitoringInfo:monitoringInfo];
}

@end

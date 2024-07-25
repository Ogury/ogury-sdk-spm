//
// Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "OGWMonitoringInfoStore.h"
#import "OGWMonitoringInfoSerializer.h"

extern NSString *const OGWMonitoringInfoStoreKey;

@interface OGWMonitoringInfoStore (Testing)

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults
                          serializer:(OGWMonitoringInfoSerializer *)serializer;

@end

@interface OGWMonitoringInfoStoreTests : XCTestCase

@property (nonatomic, strong) OGWMonitoringInfoStore *monitoringInfoStore;

@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, strong) OGWMonitoringInfoSerializer *serializer;

@end

@implementation OGWMonitoringInfoStoreTests

- (void)setUp {
    self.userDefaults = OCMClassMock([NSUserDefaults class]);
    self.serializer = OCMClassMock([OGWMonitoringInfoSerializer class]);

    self.monitoringInfoStore = [[OGWMonitoringInfoStore alloc] initWithUserDefaults:self.userDefaults
                                                                         serializer:self.serializer];
}

#pragma mark - Methods

- (void)testSave {
    NSError *error;
    NSData *data = [NSData data];
    OGWMonitoringInfo *monitoringInfo = OCMClassMock([OGWMonitoringInfo class]);
    OCMStub([self.serializer serialize:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(data);
    OCMStub([self.userDefaults setObject:[OCMArg any] forKey:OGWMonitoringInfoStoreKey]);
    XCTAssertTrue([self.monitoringInfoStore save:monitoringInfo error:&error]);
    OCMVerify([self.serializer serialize:monitoringInfo error:[OCMArg anyObjectRef]]);
    OCMVerify([self.userDefaults setObject:data forKey:OGWMonitoringInfoStoreKey]);
}

- (void)testSaveNoData {
    NSError *error;
    OGWMonitoringInfo *monitoringInfo = OCMClassMock([OGWMonitoringInfo class]);
    OCMStub([self.serializer serialize:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(nil);
    XCTAssertFalse([self.monitoringInfoStore save:monitoringInfo error:&error]);
}

- (void)testLoad {
    NSData *serializedMonitoringInfo = OCMClassMock([NSData class]);
    OGWMonitoringInfo *monitoringInfo = OCMClassMock([OGWMonitoringInfo class]);
    OCMStub([self.userDefaults dataForKey:OGWMonitoringInfoStoreKey]).andReturn(serializedMonitoringInfo);
    OCMStub([self.serializer deserialize:serializedMonitoringInfo]).andReturn(monitoringInfo);

    OGWMonitoringInfo *resultMonitoringInfo = [self.monitoringInfoStore load];

    XCTAssertEqual(resultMonitoringInfo, monitoringInfo);
}

- (void)testLoad_nothingToLoad {
    OCMStub([self.userDefaults objectForKey:OGWMonitoringInfoStoreKey]).andReturn(nil);
    OCMReject([self.serializer deserialize:[OCMArg any]]);

    XCTAssertNil([self.monitoringInfoStore load]);
}

@end

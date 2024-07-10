//
// Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "OGWMonitoringInfo.h"
#import "OGWMonitoringInfoFetcher.h"

NSString * const OGWMonitoringInfoTestsAsseyKey = @"asset-key";
NSString * const OGWMonitoringInfoTestsKey = @"key";
NSString * const OGWMonitoringInfoTestsSecondKey = @"second-key";
NSString * const OGWMonitoringInfoTestsThirdKey = @"third-key";
NSString * const OGWMonitoringInfoTestsValue = @"value";
NSString * const OGWMonitoringInfoTestsSecondValue = @"second-value";
NSString * const OGWMonitoringInfoTestsThirdValue = @"third-value";

@interface OGWMonitoringInfoTests : XCTestCase

@property (nonatomic, strong) OGWMonitoringInfo *monitoringInfo;

@end

@implementation OGWMonitoringInfoTests

- (void)setUp {
    self.monitoringInfo = [[OGWMonitoringInfo alloc] init];
}

#pragma mark - Methods

- (void)testAssetKey {
    [self.monitoringInfo putValue:OGWMonitoringInfoTestsAsseyKey key:OGWMonitoringInfoFetcherAssetKeyKey];

    XCTAssertEqualObjects(self.monitoringInfo.assetKey, OGWMonitoringInfoTestsAsseyKey);
}

- (void)testPutValue {
    [self.monitoringInfo putValue:OGWMonitoringInfoTestsValue key:OGWMonitoringInfoTestsKey];
    XCTAssertEqualObjects(self.monitoringInfo.monitoringInfoDict[OGWMonitoringInfoTestsKey], OGWMonitoringInfoTestsValue);
}

- (void)testPutValue_updatePreviousValue {
    [self.monitoringInfo putValue:OGWMonitoringInfoTestsValue key:OGWMonitoringInfoTestsKey];

    [self.monitoringInfo putValue:OGWMonitoringInfoTestsSecondValue key:OGWMonitoringInfoTestsKey];
    XCTAssertEqualObjects(self.monitoringInfo.monitoringInfoDict[OGWMonitoringInfoTestsKey], OGWMonitoringInfoTestsSecondValue);
}

- (void)testPutValue_removeKeyIfNilPassedAsValue {
    [self.monitoringInfo putValue:OGWMonitoringInfoTestsValue key:OGWMonitoringInfoTestsKey];

    [self.monitoringInfo putValue:nil key:OGWMonitoringInfoTestsKey];
    XCTAssertNil(self.monitoringInfo.monitoringInfoDict[OGWMonitoringInfoTestsKey]);
}

- (void)testPutAll {
    [self.monitoringInfo putValue:OGWMonitoringInfoTestsValue key:OGWMonitoringInfoTestsKey];
    [self.monitoringInfo putValue:OGWMonitoringInfoTestsSecondValue key:OGWMonitoringInfoTestsSecondKey];

    OGWMonitoringInfo *otherMonitoringInfo = [[OGWMonitoringInfo alloc] init];
    [otherMonitoringInfo putValue:OGWMonitoringInfoTestsSecondValue key:OGWMonitoringInfoTestsKey];
    [otherMonitoringInfo putValue:OGWMonitoringInfoTestsThirdKey key:OGWMonitoringInfoTestsThirdValue];

    [self.monitoringInfo putAll:otherMonitoringInfo];

    XCTAssertEqualObjects(self.monitoringInfo.monitoringInfoDict[OGWMonitoringInfoTestsKey], OGWMonitoringInfoTestsSecondValue);
    XCTAssertEqualObjects(self.monitoringInfo.monitoringInfoDict[OGWMonitoringInfoTestsSecondKey], OGWMonitoringInfoTestsSecondValue);
    XCTAssertEqualObjects(self.monitoringInfo.monitoringInfoDict[OGWMonitoringInfoTestsThirdValue], OGWMonitoringInfoTestsThirdKey);
}

- (void)testContainsAll_returnsYESIfContainsSomeKeysWithSameValues {
    [self.monitoringInfo putValue:OGWMonitoringInfoTestsValue key:OGWMonitoringInfoTestsKey];
    [self.monitoringInfo putValue:OGWMonitoringInfoTestsSecondValue key:OGWMonitoringInfoTestsSecondKey];
    [self.monitoringInfo putValue:OGWMonitoringInfoTestsThirdKey key:OGWMonitoringInfoTestsThirdValue];

    OGWMonitoringInfo *otherMonitoringInfo = [[OGWMonitoringInfo alloc] init];
    [otherMonitoringInfo putValue:OGWMonitoringInfoTestsValue key:OGWMonitoringInfoTestsKey];
    [otherMonitoringInfo putValue:OGWMonitoringInfoTestsThirdKey key:OGWMonitoringInfoTestsThirdValue];

    XCTAssertTrue([self.monitoringInfo containsAll:otherMonitoringInfo]);
}

- (void)testContainsAll_returnsNOIfContainsAtLeastOneKeyWithDifferentValue {
    [self.monitoringInfo putValue:OGWMonitoringInfoTestsValue key:OGWMonitoringInfoTestsKey];
    [self.monitoringInfo putValue:OGWMonitoringInfoTestsSecondValue key:OGWMonitoringInfoTestsSecondKey];
    [self.monitoringInfo putValue:OGWMonitoringInfoTestsThirdKey key:OGWMonitoringInfoTestsThirdValue];

    OGWMonitoringInfo *otherMonitoringInfo = [[OGWMonitoringInfo alloc] init];
    [otherMonitoringInfo putValue:OGWMonitoringInfoTestsSecondValue key:OGWMonitoringInfoTestsKey];

    XCTAssertFalse([self.monitoringInfo containsAll:otherMonitoringInfo]);
}

- (void)testContainsAll_returnsNOIfContainsAdditionalKey {
    [self.monitoringInfo putValue:OGWMonitoringInfoTestsValue key:OGWMonitoringInfoTestsKey];
    [self.monitoringInfo putValue:OGWMonitoringInfoTestsSecondValue key:OGWMonitoringInfoTestsSecondKey];

    OGWMonitoringInfo *otherMonitoringInfo = [[OGWMonitoringInfo alloc] init];
    [otherMonitoringInfo putValue:OGWMonitoringInfoTestsThirdValue key:OGWMonitoringInfoTestsThirdKey];

    XCTAssertFalse([self.monitoringInfo containsAll:otherMonitoringInfo]);
}

@end

//
// Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "OGWMonitoringInfoSerializer.h"

NSString * const OGWMonitoringInfoSerializerTestsInfoKey = @"info";
NSString * const OGWMonitoringInfoSerializerTestsInfoValue = @"value";
NSString * const OGWMonitoringInfoSerializerTestsInfoJson = @"{\"info\":\"value\"}";

@interface OGWMonitoringInfoSerializerTests : XCTestCase

@property (nonatomic, strong) OGWMonitoringInfoSerializer *serializer;

@end

@implementation OGWMonitoringInfoSerializerTests

- (void)setUp {
    self.serializer = [[OGWMonitoringInfoSerializer alloc] init];
}

#pragma mark - Methods

- (void)testSerialize {
    OGWMonitoringInfo *monitoringInfo = [[OGWMonitoringInfo alloc] init];
    [monitoringInfo putValue:OGWMonitoringInfoSerializerTestsInfoValue key:OGWMonitoringInfoSerializerTestsInfoKey];

    NSError *error;
    NSData *serializedMonitoringInfo = [self.serializer serialize:monitoringInfo error:&error];

    XCTAssertNil(error);
    XCTAssertEqualObjects(serializedMonitoringInfo, [OGWMonitoringInfoSerializerTestsInfoJson dataUsingEncoding:NSUTF8StringEncoding]);
}

- (void)testDeserialize {
    NSData *serializedMonitoringInfo = [OGWMonitoringInfoSerializerTestsInfoJson dataUsingEncoding:NSUTF8StringEncoding];

    OGWMonitoringInfo *monitoringInfo = [self.serializer deserialize:serializedMonitoringInfo];

    XCTAssertEqualObjects(monitoringInfo.monitoringInfoDict[OGWMonitoringInfoSerializerTestsInfoKey], OGWMonitoringInfoSerializerTestsInfoValue);
}

@end

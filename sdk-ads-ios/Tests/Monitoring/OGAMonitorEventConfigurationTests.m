//
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAMonitorEventConfiguration.h"

@interface OGAMonitorEventConfigurationTests : XCTestCase
@end

@implementation OGAMonitorEventConfigurationTests

- (void)setUp {
}

- (void)testWhenInitializedWithoutErrorThenAllFieldsAreProperlySaved {
    OGAMonitorEventConfiguration *eventConfiguration = [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"code"
                                                                                                     eventName:@"name"
                                                                                                permissionMask:OGAAdIdMaskNone];
    XCTAssertNil(eventConfiguration.errorDescription);
    XCTAssertNil(eventConfiguration.errorType);
    XCTAssertEqualObjects(eventConfiguration.eventCode, @"code");
    XCTAssertEqualObjects(eventConfiguration.eventName, @"name");
    XCTAssertEqual(eventConfiguration.permissionMask, OGAAdIdMaskNone);
}

- (void)testWhenInitializedWithErrorThenAllFieldsAreProperlySaved {
    OGAMonitorEventConfiguration *eventConfiguration = [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"code"
                                                                                                     eventName:@"name"
                                                                                                     errorType:@"errorType"
                                                                                              errorDescription:@"errorDescription"
                                                                                                permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId];
    XCTAssertEqualObjects(eventConfiguration.eventCode, @"code");
    XCTAssertEqualObjects(eventConfiguration.eventName, @"name");
    XCTAssertEqualObjects(eventConfiguration.errorDescription, @"errorDescription");
    XCTAssertEqualObjects(eventConfiguration.errorType, @"errorType");
    XCTAssertTrue(eventConfiguration.permissionMask & OGAAdIdMaskCampaignId);
    XCTAssertTrue(eventConfiguration.permissionMask & OGAAdIdMaskCreativeId);
    XCTAssertFalse(eventConfiguration.permissionMask & OGAAdIdMaskNone);
}

@end

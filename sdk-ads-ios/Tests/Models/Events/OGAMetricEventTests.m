//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "OGAMetricEvent.h"

@interface OGAMetricEvent (Testing)

+ (NSString *)nameForEventType:(OGAMetricEventType)eventType;

@end

@interface OGAMetricEventTests : XCTestCase

@end

@implementation OGAMetricEventTests

- (void)testNameForEvent {
    XCTAssertEqualObjects([OGAMetricEvent nameForEventType:OGAMetricsEventLoad], @"LOAD");
    XCTAssertEqualObjects([OGAMetricEvent nameForEventType:OGAMetricsEventShow], @"SHOW");
    XCTAssertEqualObjects([OGAMetricEvent nameForEventType:OGAMetricsEventLoaded], @"loaded");
    XCTAssertEqualObjects([OGAMetricEvent nameForEventType:OGAMetricsEventShown], @"shown");
    XCTAssertEqualObjects([OGAMetricEvent nameForEventType:OGAMetricsEventExpired], @"expired");
    XCTAssertEqualObjects([OGAMetricEvent nameForEventType:OGAMetricsEventLoadedError], @"loaded_error");
}

@end

//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAMonitoringConstants.h"
#import "OGAMonitoringEventTestsHelper.h"

@interface OGAMonitoringEventFormatterSKNetworkTests : XCTestCase

@property(nonatomic, strong) OGAMonitoringEventTestsHelper *monitoringEventFormatter;

@end

@implementation OGAMonitoringEventFormatterSKNetworkTests

- (void)setUp {
    self.monitoringEventFormatter = [[OGAMonitoringEventTestsHelper alloc] init];
}

- (void)testEventCodeFromSKNetworkLoadEvent_1 {
    XCTAssertEqualObjects([self.monitoringEventFormatter eventCodeFromEvent:OGASKNetworkLoadEventStoreViewControllerLoading], @"LUI-001");
}

- (void)testEventCodeFromSKNetworkLoadEvent_2 {
    XCTAssertEqualObjects([self.monitoringEventFormatter eventCodeFromEvent:OGASKNetworkLoadEventStoreViewControllerLoaded], @"LUI-002");
}

- (void)testEventCodeFromSKNetworkLoadEvent_3 {
    XCTAssertEqualObjects([self.monitoringEventFormatter eventCodeFromEvent:OGASKNetworkLoadEventStoreViewControllerIncompatibleIOSVersion], @"LUI-003");
}

- (void)testEventNameFromSKNetworkLoadEvent_1 {
    XCTAssertEqualObjects([self.monitoringEventFormatter eventNameFromEvent:OGASKNetworkLoadEventStoreViewControllerLoading], @"SDK_EVENT_UA_STORE_CONTROLLER_LOADING");
}

- (void)testEventNameFromSKNetworkLoadEvent_2 {
    XCTAssertEqualObjects([self.monitoringEventFormatter eventNameFromEvent:OGASKNetworkLoadEventStoreViewControllerLoaded], @"SDK_EVENT_UA_STORE_CONTROLLER_LOADED");
}

- (void)testEventNameFromSKNetworkLoadEvent_3 {
    XCTAssertEqualObjects([self.monitoringEventFormatter eventNameFromEvent:OGASKNetworkLoadEventStoreViewControllerIncompatibleIOSVersion],
                          @"SDK_EVENT_UA_INCOMPATIBLE_IOS_VERSION_FOR_STORE_CONTROLLER");
}

- (void)testEventCodeFromSKNetworkLoadErrorEvent {
    XCTAssertEqualObjects([self.monitoringEventFormatter eventCodeFromEvent:OGASKNetworkLoadErrorEventFailedLoadingStoreController], @"LUE-001");
}

- (void)testEventNameFromSKNetworkLoadErrorEvent {
    XCTAssertEqualObjects([self.monitoringEventFormatter eventNameFromEvent:OGASKNetworkLoadErrorEventFailedLoadingStoreController], @"SDK_EVENT_UA_LOAD_ERROR");
}

- (void)testErrorTypeFromSKNetworkLoadErrorEvent {
    XCTAssertEqualObjects([self.monitoringEventFormatter errorTypeFromEvent:OGASKNetworkLoadErrorEventFailedLoadingStoreController], @"FAILED_TO_LOAD_STORE_CONTROLLER");
}

- (void)testErrorDescriptionFromSKNetworkLoadErrorEvent {
    XCTAssertEqualObjects([self.monitoringEventFormatter errorDescriptionFromEvent:OGASKNetworkLoadErrorEventFailedLoadingStoreController], @"Error during presentation of StoreKit");
}

- (void)testEventCodeFromSKNetworkShowEvent_1 {
    XCTAssertEqualObjects([self.monitoringEventFormatter eventCodeFromEvent:OGASKNetworkShowEventStartingImpression], @"SUI-001");
}

- (void)testEventCodeFromSKNetworkShowEvent_2 {
    XCTAssertEqualObjects([self.monitoringEventFormatter eventCodeFromEvent:OGASKNetworkShowEventStartImpression], @"SUI-002");
}

- (void)testEventCodeFromSKNetworkShowEvent_3 {
    XCTAssertEqualObjects([self.monitoringEventFormatter eventCodeFromEvent:OGASKNetworkShowEventStoppingImpression], @"SUI-003");
}

- (void)testEventCodeFromSKNetworkShowEvent_4 {
    XCTAssertEqualObjects([self.monitoringEventFormatter eventCodeFromEvent:OGASKNetworkShowEventStopImpression], @"SUI-004");
}
- (void)testEventCodeFromSKNetworkShowEvent_5 {
    XCTAssertEqualObjects([self.monitoringEventFormatter eventCodeFromEvent:OGASKNetworkShowEventIncompatibleIOSVersionToStartImpression], @"SUI-005");
}

- (void)testEventCodeFromSKNetworkShowEvent_6 {
    XCTAssertEqualObjects([self.monitoringEventFormatter eventCodeFromEvent:OGASKNetworkShowEventIncompatibleIOSVersionToStopImpression], @"SUI-006");
}

- (void)testEventNameFromSKNetworkShowEvent_1 {
    XCTAssertEqualObjects([self.monitoringEventFormatter eventNameFromEvent:OGASKNetworkShowEventStartingImpression], @"SDK_EVENT_UA_STARTING_IMPRESSION");
}

- (void)testEventNameFromSKNetworkShowEvent_2 {
    XCTAssertEqualObjects([self.monitoringEventFormatter eventNameFromEvent:OGASKNetworkShowEventStartImpression], @"SDK_EVENT_UA_START_IMPRESSION");
}

- (void)testEventNameFromSKNetworkShowEvent_3 {
    XCTAssertEqualObjects([self.monitoringEventFormatter eventNameFromEvent:OGASKNetworkShowEventStoppingImpression], @"SDK_EVENT_UA_STOPPING_IMPRESSION");
}

- (void)testEventNameFromSKNetworkShowEvent_4 {
    XCTAssertEqualObjects([self.monitoringEventFormatter eventNameFromEvent:OGASKNetworkShowEventStopImpression], @"SDK_EVENT_UA_STOP_IMPRESSION");
}

- (void)testEventNameFromSKNetworkShowEvent_5 {
    XCTAssertEqualObjects([self.monitoringEventFormatter eventNameFromEvent:OGASKNetworkShowEventIncompatibleIOSVersionToStartImpression], @"SDK_EVENT_UA_INCOMPATIBLE_IOS_VERSION_TO_START_IMPRESSION");
}

- (void)testEventNameFromSKNetworkShowEvent_6 {
    XCTAssertEqualObjects([self.monitoringEventFormatter eventNameFromEvent:OGASKNetworkShowEventIncompatibleIOSVersionToStopImpression], @"SDK_EVENT_UA_INCOMPATIBLE_IOS_VERSION_TO_STOP_IMPRESSION");
}

- (void)testEventCodeFromSKNetworkShowErrorEvent_1 {
    XCTAssertEqualObjects([self.monitoringEventFormatter eventCodeFromEvent:OGASKNetworkShowErrorEventFailedToStartImpression], @"SUE-001");
}

- (void)testEventCodeFromSKNetworkShowErrorEvent_2 {
    XCTAssertEqualObjects([self.monitoringEventFormatter eventCodeFromEvent:OGASKNetworkShowErrorEventFailedToStopImpression], @"SUE-002");
}

- (void)testEventNameFromSKNetworkShowErrorEvent_1 {
    XCTAssertEqualObjects([self.monitoringEventFormatter eventNameFromEvent:OGASKNetworkShowErrorEventFailedToStartImpression], @"SDK_EVENT_UA_SHOW_ERROR");
}

- (void)testEventNameFromSKNetworkShowErrorEvent_2 {
    XCTAssertEqualObjects([self.monitoringEventFormatter eventNameFromEvent:OGASKNetworkShowErrorEventFailedToStopImpression], @"SDK_EVENT_UA_SHOW_ERROR");
}

- (void)testErrorTypeFromSKNetworkShowErrorEvent_1 {
    XCTAssertEqualObjects([self.monitoringEventFormatter errorTypeFromEvent:OGASKNetworkShowErrorEventFailedToStartImpression], @"UA_FAILED_TO_START_IMPRESSION");
}

- (void)testErrorTypeFromSKNetworkShowErrorEvent_2 {
    XCTAssertEqualObjects([self.monitoringEventFormatter errorTypeFromEvent:OGASKNetworkShowErrorEventFailedToStopImpression], @"UA_FAILED_TO_STOP_IMPRESSION");
}

- (void)testErrorDescriptionFromSKNetworkShowErrorEvent_1 {
    XCTAssertEqualObjects([self.monitoringEventFormatter errorDescriptionFromEvent:OGASKNetworkShowErrorEventFailedToStartImpression], @"Failed to notify StoreKit of starting the impression");
}

- (void)testErrorDescriptionFromSKNetworkShowErrorEvent_2 {
    XCTAssertEqualObjects([self.monitoringEventFormatter errorDescriptionFromEvent:OGASKNetworkShowErrorEventFailedToStopImpression], @"Failed to notify StoreKit of ending the impression");
}

@end

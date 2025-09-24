//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAEventHeaderBuilder.h"
#import "OGAAdIdentifierService.h"
#import "OGAAdPrivacyConfiguration.h"
#import "OGAPreCacheEvent.h"
#import "OGATrackEvent.h"
#import "OGAAdHistoryEvent.h"
#import <OCMock/OCMock.h>

@interface OGAEventHeaderBuilderTests : XCTestCase
@property(nonatomic, retain) OGAEventHeaderBuilder *builder;
@end

@implementation OGAEventHeaderBuilderTests

- (void)testBuildingHeaderForTrackEventWithIDFAPermissionAndAuthorizedIntanceTokenThenTokenAndDeviceIdAreReturned {
    id service = OCMClassMock([OGAAdIdentifierService class]);
    OCMStub(OCMClassMethod([service getAdIdentifier])).andReturn(@"DeviceId");
    OCMStub(OCMClassMethod([service getInstanceToken])).andReturn(@"InstanceToken");
    OGATrackEvent *event = OCMClassMock([OGATrackEvent class]);
    OGAAdPrivacyConfiguration *privacyConfiguration = OCMClassMock([OGAAdPrivacyConfiguration class]);
    OCMStub(event.privacyConfiguration).andReturn(privacyConfiguration);
    OCMStub([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionIDFA]).andReturn(YES);
    OCMStub([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionInstanceToken]).andReturn(YES);
    NSDictionary *headers = [OGAEventHeaderBuilder buildFor:event];
    XCTAssertEqualObjects(headers[@"User"], @"DeviceId");
    XCTAssertEqualObjects(headers[@"Instance-Token"], @"InstanceToken");
}

- (void)testBuildingHeaderForTrackEventWithIDFAPermissionAndBlockedIntanceTokenThenTokenAndDeviceIdAreReturned {
    id service = OCMClassMock([OGAAdIdentifierService class]);
    OCMStub(OCMClassMethod([service getAdIdentifier])).andReturn(@"DeviceId");
    OCMStub(OCMClassMethod([service getInstanceToken])).andReturn(@"InstanceToken");
    OGATrackEvent *event = OCMClassMock([OGATrackEvent class]);
    OGAAdPrivacyConfiguration *privacyConfiguration = OCMClassMock([OGAAdPrivacyConfiguration class]);
    OCMStub(event.privacyConfiguration).andReturn(privacyConfiguration);
    OCMStub([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionIDFA]).andReturn(YES);
    OCMStub([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionInstanceToken]).andReturn(NO);
    NSDictionary *headers = [OGAEventHeaderBuilder buildFor:event];
    XCTAssertEqualObjects(headers[@"User"], @"DeviceId");
    XCTAssertNil(headers[@"Instance-Token"]);
}

- (void)testBuildingHeaderForTrackEventWithNoIDFAPermissionAndBlockedIntanceTokenThenTokenAndDefaultDeviceIdAreReturned {
    id service = OCMClassMock([OGAAdIdentifierService class]);
    OCMStub(OCMClassMethod([service getAdIdentifier])).andReturn(@"DeviceId");
    OCMStub(OCMClassMethod([service getInstanceToken])).andReturn(@"InstanceToken");
    OGATrackEvent *event = OCMClassMock([OGATrackEvent class]);
    OGAAdPrivacyConfiguration *privacyConfiguration = OCMClassMock([OGAAdPrivacyConfiguration class]);
    OCMStub(event.privacyConfiguration).andReturn(privacyConfiguration);
    OCMStub([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionIDFA]).andReturn(NO);
    OCMStub([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionInstanceToken]).andReturn(NO);
    NSDictionary *headers = [OGAEventHeaderBuilder buildFor:event];
    XCTAssertEqualObjects(headers[@"User"], @"00000000-0000-0000-0000-000000000000");
    XCTAssertNil(headers[@"Instance-Token"]);
}

- (void)testBuildingHeaderForTrackEventWithNoIDFAPermissionAndAuthorizedIntanceTokenThenTokenAndDefaultDeviceIdAreReturned {
    id service = OCMClassMock([OGAAdIdentifierService class]);
    OCMStub(OCMClassMethod([service getAdIdentifier])).andReturn(@"DeviceId");
    OCMStub(OCMClassMethod([service getInstanceToken])).andReturn(@"InstanceToken");
    OGATrackEvent *event = OCMClassMock([OGATrackEvent class]);
    OGAAdPrivacyConfiguration *privacyConfiguration = OCMClassMock([OGAAdPrivacyConfiguration class]);
    OCMStub(event.privacyConfiguration).andReturn(privacyConfiguration);
    OCMStub([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionIDFA]).andReturn(NO);
    OCMStub([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionInstanceToken]).andReturn(YES);
    NSDictionary *headers = [OGAEventHeaderBuilder buildFor:event];
    XCTAssertEqualObjects(headers[@"User"], @"00000000-0000-0000-0000-000000000000");
    XCTAssertEqualObjects(headers[@"Instance-Token"], @"InstanceToken");
}

- (void)testBuildingHeaderForAdHistoryEventWithIDFAPermissionAndBlockedIntanceTokenThenTokenAndDeviceIdAreReturned {
    id service = OCMClassMock([OGAAdIdentifierService class]);
    OCMStub(OCMClassMethod([service getAdIdentifier])).andReturn(@"DeviceId");
    OCMStub(OCMClassMethod([service getInstanceToken])).andReturn(@"InstanceToken");
    OGAAdHistoryEvent *event = OCMClassMock([OGAAdHistoryEvent class]);
    OGAAdPrivacyConfiguration *privacyConfiguration = OCMClassMock([OGAAdPrivacyConfiguration class]);
    OCMStub(event.privacyConfiguration).andReturn(privacyConfiguration);
    OCMStub([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionIDFA]).andReturn(YES);
    OCMStub([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionInstanceToken]).andReturn(NO);
    NSDictionary *headers = [OGAEventHeaderBuilder buildFor:event];
    XCTAssertEqualObjects(headers[@"User"], @"DeviceId");
    XCTAssertNil(headers[@"Instance-Token"]);
}

- (void)testBuildingHeaderForAdHistoryEventWithIDFAPermissionAndAuthorizedIntanceTokenThenTokenAndDeviceIdAreReturned {
    id service = OCMClassMock([OGAAdIdentifierService class]);
    OCMStub(OCMClassMethod([service getAdIdentifier])).andReturn(@"DeviceId");
    OCMStub(OCMClassMethod([service getInstanceToken])).andReturn(@"InstanceToken");
    OGAAdHistoryEvent *event = OCMClassMock([OGAAdHistoryEvent class]);
    OGAAdPrivacyConfiguration *privacyConfiguration = OCMClassMock([OGAAdPrivacyConfiguration class]);
    OCMStub(event.privacyConfiguration).andReturn(privacyConfiguration);
    OCMStub([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionIDFA]).andReturn(YES);
    OCMStub([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionInstanceToken]).andReturn(YES);
    NSDictionary *headers = [OGAEventHeaderBuilder buildFor:event];
    XCTAssertEqualObjects(headers[@"User"], @"DeviceId");
    XCTAssertEqualObjects(headers[@"Instance-Token"], @"InstanceToken");
}

- (void)testBuildingHeaderForAdHistoryEventWithNoIDFAPermissionAndBlockedIntanceTokenThenTokenAndDefaultDeviceIdAreReturned {
    id service = OCMClassMock([OGAAdIdentifierService class]);
    OCMStub(OCMClassMethod([service getAdIdentifier])).andReturn(@"DeviceId");
    OCMStub(OCMClassMethod([service getInstanceToken])).andReturn(@"InstanceToken");
    OGAAdHistoryEvent *event = OCMClassMock([OGAAdHistoryEvent class]);
    OGAAdPrivacyConfiguration *privacyConfiguration = OCMClassMock([OGAAdPrivacyConfiguration class]);
    OCMStub(event.privacyConfiguration).andReturn(privacyConfiguration);
    OCMStub([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionIDFA]).andReturn(NO);
    OCMStub([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionInstanceToken]).andReturn(NO);
    NSDictionary *headers = [OGAEventHeaderBuilder buildFor:event];
    XCTAssertEqualObjects(headers[@"User"], @"00000000-0000-0000-0000-000000000000");
    XCTAssertNil(headers[@"Instance-Token"]);
}

- (void)testBuildingHeaderForAdHistoryEventWithNoIDFAPermissionAndAutorizedIntanceTokenThenTokenAndDefaultDeviceIdAreReturned {
    id service = OCMClassMock([OGAAdIdentifierService class]);
    OCMStub(OCMClassMethod([service getAdIdentifier])).andReturn(@"DeviceId");
    OCMStub(OCMClassMethod([service getInstanceToken])).andReturn(@"InstanceToken");
    OGAAdHistoryEvent *event = OCMClassMock([OGAAdHistoryEvent class]);
    OGAAdPrivacyConfiguration *privacyConfiguration = OCMClassMock([OGAAdPrivacyConfiguration class]);
    OCMStub(event.privacyConfiguration).andReturn(privacyConfiguration);
    OCMStub([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionIDFA]).andReturn(NO);
    OCMStub([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionInstanceToken]).andReturn(YES);
    NSDictionary *headers = [OGAEventHeaderBuilder buildFor:event];
    XCTAssertEqualObjects(headers[@"User"], @"00000000-0000-0000-0000-000000000000");
    XCTAssertEqualObjects(headers[@"Instance-Token"], @"InstanceToken");
}

- (void)testBuildingHeaderForPreCacheEventWithIDFAPermissionThenNeitherTokenNorDeviceIrAreReturned {
    id service = OCMClassMock([OGAAdIdentifierService class]);
    OCMStub(OCMClassMethod([service getAdIdentifier])).andReturn(@"DeviceId");
    OCMStub(OCMClassMethod([service getInstanceToken])).andReturn(@"InstanceToken");
    OGAPreCacheEvent *event = OCMClassMock([OGAPreCacheEvent class]);
    OGAAdPrivacyConfiguration *privacyConfiguration = OCMClassMock([OGAAdPrivacyConfiguration class]);
    OCMStub(event.privacyConfiguration).andReturn(privacyConfiguration);
    OCMStub([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionIDFA]).andReturn(YES);
    OCMStub([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionInstanceToken]).andReturn(YES);
    NSDictionary *headers = [OGAEventHeaderBuilder buildFor:event];
    XCTAssertNil(headers[@"User"]);
    XCTAssertNil(headers[@"Instance-Token"]);
}

- (void)testBuildingHeaderForPreCacheEventWithNoIDFAPermissionThenNeitherTokenNorDeviceIrAreReturned {
    id service = OCMClassMock([OGAAdIdentifierService class]);
    OCMStub(OCMClassMethod([service getAdIdentifier])).andReturn(@"DeviceId");
    OCMStub(OCMClassMethod([service getInstanceToken])).andReturn(@"InstanceToken");
    OGAPreCacheEvent *event = OCMClassMock([OGAPreCacheEvent class]);
    OGAAdPrivacyConfiguration *privacyConfiguration = OCMClassMock([OGAAdPrivacyConfiguration class]);
    OCMStub(event.privacyConfiguration).andReturn(privacyConfiguration);
    OCMStub([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionIDFA]).andReturn(NO);
    OCMStub([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionInstanceToken]).andReturn(YES);
    NSDictionary *headers = [OGAEventHeaderBuilder buildFor:event];
    XCTAssertNil(headers[@"User"]);
    XCTAssertNil(headers[@"Instance-Token"]);
}

@end

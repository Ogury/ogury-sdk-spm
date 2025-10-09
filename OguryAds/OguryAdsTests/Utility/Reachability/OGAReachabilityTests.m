//
//  Copyright © 2025 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAReachability.h"
#import <OCMock/OCMock.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@interface OGAReachabilityTests : XCTestCase

@property(strong) CTTelephonyNetworkInfo *telephonyNetworkInfo;
@property(strong) OGAReachability *reachability;

@end

@implementation OGAReachabilityTests

- (void)setUp {
    self.telephonyNetworkInfo = OCMClassMock([CTTelephonyNetworkInfo class]);
    self.reachability = [[OGAReachability alloc] init];
}

- (void)testCurrentReachabilityCellularNetwork_2G {
    if (@available(iOS 13.0, *)) {
        NSDictionary<NSString *, NSString *> *mockedRadioAccessTechnologies = @{@"dataServiceIdentifier1" : CTRadioAccessTechnologyGPRS, @"dataServiceIdentifier2" : CTRadioAccessTechnologyEdge};
        NSString *dataServiceIdentifierPrimary = @"dataServiceIdentifier1";
        OCMStub(self.telephonyNetworkInfo.dataServiceIdentifier).andReturn(dataServiceIdentifierPrimary);
        OCMStub(self.telephonyNetworkInfo.serviceCurrentRadioAccessTechnology).andReturn(mockedRadioAccessTechnologies);
        NSString *cellularType = [self.reachability currentReachabilityCellularNetwork:self.telephonyNetworkInfo];
        XCTAssertEqualObjects(cellularType, @"2G");
    }
}

- (void)testCurrentReachabilityCellularNetwork_3G {
    if (@available(iOS 13.0, *)) {
        NSDictionary<NSString *, NSString *> *mockedRadioAccessTechnologies = @{@"dataServiceIdentifier1" : CTRadioAccessTechnologyHSUPA, @"dataServiceIdentifier2" : CTRadioAccessTechnologyEdge};
        NSString *dataServiceIdentifierPrimary = @"dataServiceIdentifier1";
        OCMStub(self.telephonyNetworkInfo.dataServiceIdentifier).andReturn(dataServiceIdentifierPrimary);
        OCMStub(self.telephonyNetworkInfo.serviceCurrentRadioAccessTechnology).andReturn(mockedRadioAccessTechnologies);
        NSString *cellularType = [self.reachability currentReachabilityCellularNetwork:self.telephonyNetworkInfo];
        XCTAssertEqualObjects(cellularType, @"3G");
    }
}

- (void)testCurrentReachabilityCellularNetwork_4G {
    if (@available(iOS 13.0, *)) {
        NSDictionary<NSString *, NSString *> *mockedRadioAccessTechnologies = @{@"dataServiceIdentifier1" : CTRadioAccessTechnologyLTE, @"dataServiceIdentifier2" : CTRadioAccessTechnologyEdge};
        NSString *dataServiceIdentifierPrimary = @"dataServiceIdentifier1";
        OCMStub(self.telephonyNetworkInfo.dataServiceIdentifier).andReturn(dataServiceIdentifierPrimary);
        OCMStub(self.telephonyNetworkInfo.serviceCurrentRadioAccessTechnology).andReturn(mockedRadioAccessTechnologies);
        NSString *cellularType = [self.reachability currentReachabilityCellularNetwork:self.telephonyNetworkInfo];
        XCTAssertEqualObjects(cellularType, @"4G");
    }
}

- (void)testCurrentReachabilityCellularNetwork_5G {
    if (@available(iOS 14.1, *)) {
        NSDictionary<NSString *, NSString *> *mockedRadioAccessTechnologies = @{@"dataServiceIdentifier1" : CTRadioAccessTechnologyNR, @"dataServiceIdentifier2" : CTRadioAccessTechnologyEdge};
        NSString *dataServiceIdentifierPrimary = @"dataServiceIdentifier1";
        OCMStub(self.telephonyNetworkInfo.dataServiceIdentifier).andReturn(dataServiceIdentifierPrimary);
        OCMStub(self.telephonyNetworkInfo.serviceCurrentRadioAccessTechnology).andReturn(mockedRadioAccessTechnologies);
        NSString *cellularType = [self.reachability currentReachabilityCellularNetwork:self.telephonyNetworkInfo];
        XCTAssertEqualObjects(cellularType, @"5G");
    }
}

- (void)testCurrentReachabilityCellularNetwork_Unknown {
    if (@available(iOS 14.1, *)) {
        NSDictionary<NSString *, NSString *> *mockedRadioAccessTechnologies = @{};
        NSString *dataServiceIdentifierPrimary = @"dataServiceIdentifier1";
        OCMStub(self.telephonyNetworkInfo.dataServiceIdentifier).andReturn(dataServiceIdentifierPrimary);
        OCMStub(self.telephonyNetworkInfo.serviceCurrentRadioAccessTechnology).andReturn(mockedRadioAccessTechnologies);
        NSString *cellularType = [self.reachability currentReachabilityCellularNetwork:self.telephonyNetworkInfo];
        XCTAssertEqualObjects(cellularType, @"Unknown");
    }
}

@end

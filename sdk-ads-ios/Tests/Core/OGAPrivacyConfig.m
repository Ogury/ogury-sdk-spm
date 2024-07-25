//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAAdPrivacyConfiguration.h"

@interface OGAPrivacyConfigTests : XCTestCase

@end

@interface OGAAdPrivacyConfiguration ()
+ (OGAAdPrivacyPermission)allPermissions;
+ (NSArray<NSNumber *> *)allPermissionsArray;
@end

@implementation OGAPrivacyConfigTests

- (void)testPermissionEnabled:(NSUInteger)permissionToTest {
    OGAAdPrivacyConfiguration *privacyConfig = [[OGAAdPrivacyConfiguration alloc] initWithAdSyncPermissionMask:permissionToTest monitoringMask:permissionToTest];
    //    OGAAdPrivacyPermission allPermission = [OGAAdPrivacyConfiguration allPermissions];
    NSArray<NSNumber *> *allPermissions = [OGAAdPrivacyConfiguration allPermissionsArray];
    for (int index = 0; index < allPermissions.count; index++) {
        NSUInteger permission = allPermissions[index].intValue;
        if (permission & permissionToTest) {
            XCTAssertTrue([privacyConfig adSyncPermissionIsEnabledFor:permission]);
        } else {
            XCTAssertFalse([privacyConfig adSyncPermissionIsEnabledFor:permission], @"False test failed for %d (test %d)", permission, permissionToTest);
        }
    }
}

- (void)testPermissionEnabled {
    NSArray<NSNumber *> *allPermissions = [OGAAdPrivacyConfiguration allPermissionsArray];
    for (int index = 0; index < allPermissions.count; index++) {
        NSUInteger permission = allPermissions[index].intValue;
        XCTAssertEqual(pow(2, index), permission);
        [self testPermission:permission];
    }
}

- (void)testPermission:(NSUInteger)permission {
    [self testPermissionEnabled:permission];
    [self testPermissionEnabled:[self permissionFor:permission]];
}

- (OGAAdPrivacyPermission)permissionFor:(NSUInteger)integer {
    if (integer == OGAAdPrivacyPermissionIDFA) {
        return OGAAdPrivacyPermissionIDFA;
    } else if (integer == OGAAdPrivacyPermissionAdTracking) {
        return OGAAdPrivacyPermissionAdTracking;
    } else if (integer == OGAAdPrivacyPermissionInstanceToken) {
        return OGAAdPrivacyPermissionInstanceToken;
    } else if (integer == OGAAdPrivacyPermissionDeviceIds) {
        return OGAAdPrivacyPermissionDeviceIds;
    } else if (integer == OGAAdPrivacyPermissionDeviceDimensions) {
        return OGAAdPrivacyPermissionDeviceDimensions;
    } else if (integer == OGAAdPrivacyPermissionDeviceOrientation) {
        return OGAAdPrivacyPermissionDeviceOrientation;
    } else if (integer == OGAAdPrivacyPermissionLayoutSize) {
        return OGAAdPrivacyPermissionLayoutSize;
    } else if (integer == OGAAdPrivacyPermissionUIMode) {
        return OGAAdPrivacyPermissionUIMode;
    } else if (integer == OGAAdPrivacyPermissionTimezone) {
        return OGAAdPrivacyPermissionTimezone;
    } else if (integer == OGAAdPrivacyPermissionLocaleLanguage) {
        return OGAAdPrivacyPermissionLocaleLanguage;
    } else if (integer == OGAAdPrivacyPermissionLocaleCountry) {
        return OGAAdPrivacyPermissionLocaleCountry;
    } else if (integer == OGAAdPrivacyPermissionMobileCountry) {
        return OGAAdPrivacyPermissionMobileCountry;
    } else if (integer == OGAAdPrivacyPermissionConnectivity) {
        return OGAAdPrivacyPermissionConnectivity;
    } else if (integer == OGAAdPrivacyPermissionWebviewUserAgent) {
        return OGAAdPrivacyPermissionWebviewUserAgent;
    } else if (integer == OGAAdPrivacyPermissionIDFV) {
        return OGAAdPrivacyPermissionIDFV;
    } else {
        return OGAAdPrivacyPermissionNone;
    }
}

@end

//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdPrivacyConfiguration : NSObject

typedef NS_OPTIONS(NSUInteger, OGAAdPrivacyPermission) {
    OGAAdPrivacyPermissionNone = (0),
    OGAAdPrivacyPermissionIDFA = (1 << 0),
    OGAAdPrivacyPermissionAdTracking = (1 << 1),
    OGAAdPrivacyPermissionInstanceToken = (1 << 2),
    OGAAdPrivacyPermissionDeviceIds = (1 << 3),
    OGAAdPrivacyPermissionDeviceDimensions = (1 << 4),
    OGAAdPrivacyPermissionDeviceOrientation = (1 << 5),
    OGAAdPrivacyPermissionLayoutSize = (1 << 6),
    OGAAdPrivacyPermissionUIMode = (1 << 7),
    OGAAdPrivacyPermissionTimezone = (1 << 8),
    OGAAdPrivacyPermissionLocaleLanguage = (1 << 9),
    OGAAdPrivacyPermissionLocaleCountry = (1 << 10),
    OGAAdPrivacyPermissionMobileCountry = (1 << 11),
    OGAAdPrivacyPermissionConnectivity = (1 << 12),
    OGAAdPrivacyPermissionWebviewUserAgent = (1 << 13),
    OGAAdPrivacyPermissionIDFV = (1 << 14),
    OGAAdPrivacyPermissionLowPowerMode = (1 << 15)
};

- (id)initWithAdSyncPermissionMask:(NSUInteger)permission monitoringMask:(NSUInteger)trackingPermissions;
- (BOOL)adSyncPermissionIsEnabledFor:(OGAAdPrivacyPermission)permission;
- (BOOL)monitoringPermissionIsEnabledFor:(OGAAdPrivacyPermission)permission;

@end

NS_ASSUME_NONNULL_END

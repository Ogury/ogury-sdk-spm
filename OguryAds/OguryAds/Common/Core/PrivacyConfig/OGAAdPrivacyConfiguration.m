//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdPrivacyConfiguration.h"

@interface OGAAdPrivacyConfiguration ()

@property NSUInteger adSyncPermissions;
@property NSUInteger monitoringPermissions;

@end

@implementation OGAAdPrivacyConfiguration

- (id)initWithAdSyncPermissionMask:(NSUInteger)permission monitoringMask:(NSUInteger)trackingPermissions {
    if (self = [super init]) {
        _adSyncPermissions = permission;
        _monitoringPermissions = trackingPermissions;
    }
    return self;
}

- (BOOL)adSyncPermissionIsEnabledFor:(OGAAdPrivacyPermission)permission {
    return self.adSyncPermissions & permission;
}

- (BOOL)monitoringPermissionIsEnabledFor:(OGAAdPrivacyPermission)permission {
    return self.monitoringPermissions & permission;
}

+ (OGAAdPrivacyPermission)allPermissions {
    return OGAAdPrivacyPermissionIDFA &
        OGAAdPrivacyPermissionAdTracking &
        OGAAdPrivacyPermissionInstanceToken &
        OGAAdPrivacyPermissionDeviceIds &
        OGAAdPrivacyPermissionDeviceDimensions &
        OGAAdPrivacyPermissionDeviceOrientation &
        OGAAdPrivacyPermissionLayoutSize &
        OGAAdPrivacyPermissionUIMode &
        OGAAdPrivacyPermissionTimezone &
        OGAAdPrivacyPermissionLocaleLanguage &
        OGAAdPrivacyPermissionLocaleCountry &
        OGAAdPrivacyPermissionMobileCountry &
        OGAAdPrivacyPermissionConnectivity &
        OGAAdPrivacyPermissionWebviewUserAgent &
        OGAAdPrivacyPermissionIDFV;
}

+ (NSArray<NSNumber *> *)allPermissionsArray {
    return @[ @(OGAAdPrivacyPermissionIDFA),
              @(OGAAdPrivacyPermissionAdTracking),
              @(OGAAdPrivacyPermissionInstanceToken),
              @(OGAAdPrivacyPermissionDeviceIds),
              @(OGAAdPrivacyPermissionDeviceDimensions),
              @(OGAAdPrivacyPermissionDeviceOrientation),
              @(OGAAdPrivacyPermissionLayoutSize),
              @(OGAAdPrivacyPermissionUIMode),
              @(OGAAdPrivacyPermissionTimezone),
              @(OGAAdPrivacyPermissionLocaleLanguage),
              @(OGAAdPrivacyPermissionLocaleCountry),
              @(OGAAdPrivacyPermissionMobileCountry),
              @(OGAAdPrivacyPermissionConnectivity),
              @(OGAAdPrivacyPermissionWebviewUserAgent),
              @(OGAAdPrivacyPermissionIDFV) ];
}

@end

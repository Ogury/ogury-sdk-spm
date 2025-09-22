//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAProfigFullResponse.h"
#import "OGAAdPrivacyConfiguration.h"

NSString *const OGAAdConfigurationDisablingReasonConsentDenied = @"CONSENT_DENIED";
NSString *const OGAAdConfigurationDisablingReasonConsentMissing = @"CONSENT_MISSING";
NSString *const OGAAdConfigurationDisablingReasonCountryUnopened = @"COUNTRY_NOT_OPEN";
NSString *const OGAAdConfigurationDisablingReasonUnkown = @"UNKNOWN_REASON";

@interface OGAProfigFullResponse ()
@property(nonatomic) NSUInteger rawBidTokenMode;
@end

@implementation OGAProfigFullResponse

+ (OGAJSONKeyMapper *)keyMapper {
    return [[OGAJSONKeyMapper alloc] initWithModelToJSONDictionary:@{
        @"requestTimeout" : @"response.global.request_timeout",
        @"childrenRequestPermissionsFilter" : @"response.global.children_request_permissions_filter",
        @"maxProfigApiCallsPerDay" : @"response.config_pull.limit_per_day",
        @"adsEnabled" : @"response.ad_serving.enabled",
        @"rawBidTokenMode" : @"response.ad_serving.bid_token_mode",
        @"adsyncPermissions" : @"response.ad_serving.request_permissions",
        @"adExpirationTime" : @"response.ad_serving.ad_expiration_time",
        @"backButtonEnabled" : @"response.ad_serving.webview.back_button_enabled",
        @"closeAdWhenLeavingApp" : @"response.ad_serving.webview.close_ad_when_leaving_app",
        @"webviewLoadTimeout" : @"response.ad_serving.webview.webview_load_timeout",
        @"showCloseButtonDelay" : @"response.ad_serving.webview.show_close_button_delay",
        @"disablingReason" : @"response.ad_serving.disabling_reason",
        @"monitoringPermissions" : @"response.monitoring.request_permissions",
        @"cacheLogsEnabled" : @"response.monitoring.tracks.enabled",
        @"precachingLogsEnabled" : @"response.monitoring.precaching_logs.enabled",
        @"adLifeCycleLogsEnabled" : @"response.monitoring.ad_life_cycle.enabled",
        @"blacklistedTracks" : @"response.monitoring.ad_life_cycle.blacklist",
        @"omidEnabled" : @"response.omid.enabled",
        @"errorType" : @"error.type",
        @"errorMessage" : @"error.message",
        @"adQualityConfiguration" : @"response.ad_quality"
    }];
}

+ (NSArray<NSString *> *)defaultBlackList {
    return @[
        @"LI-002",
        @"LI-003",
        @"LI-004",
        @"LI-005",
        @"LI-006",
        @"LI-007",
        @"LI-008",
        @"LI-010",
        @"LI-011",
        @"LI-012",
        @"LI-013",
        @"LI-014",
        @"SI-002",
        @"SI-003",
        @"SI-004",
        @"SI-005",
        @"SI-006",
        @"SI-008",
        @"SI-009",
        @"SI-010",
        @"SI-011",
        @"SI-012",
        @"SI-013",
        @"SI-014",
        @"SI-015"
    ];
}

- (OGABidTokenMode)bidTokenMode {
    return (_rawBidTokenMode >= OGABidTokenModeAllowNilToken && _rawBidTokenMode <= OGABidTokenModeAlwaysReturnToken)
    ? (OGABidTokenMode)_rawBidTokenMode
    : OGABidTokenModeAllowNilToken;
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return true;
}

#pragma mark - Public methods

- (OGAAdPrivacyPermission)adSyncPermissionsMask {
    return self.adsyncPermissions == nil ? OGAAdPrivacyPermissionNone : self.adsyncPermissions.intValue;
}

- (OGAAdPrivacyPermission)monitoringPermissionsMask {
    return self.monitoringPermissions == nil ? OGAAdPrivacyPermissionNone : self.monitoringPermissions.intValue;
}

- (OGAAdPrivacyConfiguration *)getPrivacyConfiguration {
    return [[OGAAdPrivacyConfiguration alloc] initWithAdSyncPermissionMask:self.adSyncPermissionsMask
                                                            monitoringMask:self.monitoringPermissionsMask];
}

- (BOOL)isAdsEnabled {
    return self.adsEnabled;
}

- (BOOL)isOmidEnabled {
    return self.omidEnabled;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[OGAProfigFullResponse class]] == NO) {
        return NO;
    }
    OGAProfigFullResponse *profig = (OGAProfigFullResponse *)object;
    return
        [self.requestTimeout isEqual:profig.requestTimeout] &&
        [self.childrenRequestPermissionsFilter isEqual:profig.childrenRequestPermissionsFilter] &&
        [self.maxProfigApiCallsPerDay isEqual:profig.maxProfigApiCallsPerDay] &&
        [self.adsyncPermissions isEqual:profig.adsyncPermissions] &&
        [self.monitoringPermissions isEqual:profig.monitoringPermissions] &&
        [self.adExpirationTime isEqual:profig.adExpirationTime] &&
        [self.webviewLoadTimeout isEqual:profig.webviewLoadTimeout] &&
        [self.thumbnailDefaultXMargin isEqual:profig.thumbnailDefaultXMargin] &&
        [self.thumbnailDefaultYMargin isEqual:profig.thumbnailDefaultYMargin] &&
        [self.thumbnailDefaultMaxWidth isEqual:profig.thumbnailDefaultMaxWidth] &&
        [self.thumbnailDefaultMaxHeight isEqual:profig.thumbnailDefaultMaxHeight] &&
        [self.monitoringPermissions isEqual:profig.monitoringPermissions] &&
        [self.blacklistedTracks isEqual:profig.blacklistedTracks] &&
        [self is:self.disablingReason equalTo:profig.disablingReason] &&
        self.cacheLogsEnabled == profig.cacheLogsEnabled &&
        self.precachingLogsEnabled == profig.precachingLogsEnabled &&
        self.adLifeCycleLogsEnabled == profig.adLifeCycleLogsEnabled &&
        self.adsEnabled == profig.adsEnabled &&
        self.backButtonEnabled == profig.backButtonEnabled &&
        self.closeAdWhenLeavingApp == profig.closeAdWhenLeavingApp &&
        self.bidTokenMode == profig.bidTokenMode &&
        [self.adQualityConfiguration isEqual:profig.adQualityConfiguration ] &&
        self.omidEnabled == profig.omidEnabled;
}

- (BOOL)is:(NSString *)firstString equalTo:(NSString *)secondString {
    if (firstString == secondString) {
        return YES;
    }
    return [firstString isEqualToString:secondString];
}

@end

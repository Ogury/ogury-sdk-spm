//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAJSONModel.h"
#import "OGAProfigResponseError.h"
#import "OGAAdPrivacyConfiguration.h"
#import "OGAAdQualityConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, OGABidTokenMode) {
    OGABidTokenModeAllowNilToken = 0,
    OGABidTokenModeAlwaysReturnToken
};

extern NSString *const OGAAdConfigurationDisablingReasonConsentDenied;
extern NSString *const OGAAdConfigurationDisablingReasonConsentMissing;
extern NSString *const OGAAdConfigurationDisablingReasonCountryUnopened;
extern NSString *const OGAAdConfigurationDisablingReasonUnkown;

@interface OGAProfigFullResponse : OGAJSONModel

+ (NSArray<NSString *> *)defaultBlackList;

@property(nonatomic, strong) NSNumber *requestTimeout;
@property(nonatomic, strong) NSNumber *childrenRequestPermissionsFilter;
@property(nonatomic) OGABidTokenMode bidTokenMode;

// Config_pull
@property(nonatomic, strong) NSNumber *retryInterval;  // max-age from header
@property(nonatomic, strong, nullable) NSNumber *maxProfigApiCallsPerDay;
@property(nonatomic) BOOL adsEnabled;
@property(nonatomic, strong, nullable) NSString *disablingReason;
@property(nonatomic, strong) NSNumber *adsyncPermissions;
@property(nonatomic, strong) NSNumber *adExpirationTime;

// Webview
@property(nonatomic) BOOL backButtonEnabled;
@property(nonatomic) BOOL closeAdWhenLeavingApp;
@property(nonatomic, strong) NSNumber *webviewLoadTimeout;
@property(nonatomic, strong) NSNumber *showCloseButtonDelay;

// Thumbnail
@property(nonatomic, strong) NSNumber *thumbnailDefaultXMargin;
@property(nonatomic, strong) NSNumber *thumbnailDefaultYMargin;
@property(nonatomic, strong) NSNumber *thumbnailDefaultMaxWidth;
@property(nonatomic, strong) NSNumber *thumbnailDefaultMaxHeight;

// Monitoring
@property(nonatomic, strong) NSNumber *monitoringPermissions;
@property(nonatomic) BOOL cacheLogsEnabled;
@property(nonatomic, strong) NSArray<NSString *> *blacklistedTracks;
@property(nonatomic) BOOL precachingLogsEnabled;
@property(nonatomic) BOOL adLifeCycleLogsEnabled;

// third Patry
@property(nonatomic) BOOL omidEnabled;

// Error
@property(nonatomic, strong) NSString *errorType;
@property(nonatomic, strong) NSString *errorMessage;

@property(nonatomic, strong) OGAAdQualityConfiguration *adQualityConfiguration;

- (OGAAdPrivacyConfiguration *)getPrivacyConfiguration;
- (BOOL)isAdsEnabled;
- (BOOL)isOmidEnabled;

@end

NS_ASSUME_NONNULL_END

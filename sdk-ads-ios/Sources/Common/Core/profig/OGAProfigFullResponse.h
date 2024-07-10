//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAJSONModel.h"
#import "OGAProfigResponseError.h"
#import "OGAAdPrivacyConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAProfigFullResponse : OGAJSONModel

+ (NSArray<NSString *> *)defaultBlackList;

@property(nonatomic, strong) NSNumber *requestTimeout;
@property(nonatomic, strong) NSNumber *childrenRequestPermissionsFilter;

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

- (OGAAdPrivacyConfiguration *)getPrivacyConfiguration;
- (BOOL)isAdsEnabled;
- (BOOL)isOmidEnabled;

@end

NS_ASSUME_NONNULL_END

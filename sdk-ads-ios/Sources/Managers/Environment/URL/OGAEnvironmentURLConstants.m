//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import "OGAEnvironmentURLConstants.h"

#pragma mark - Services
NSString *const OGAServiceProfig = @"sac";
NSString *const OGAServiceAdSync = @"ms-bidder-adsync";
NSString *const OGAServiceAdSyncProd = @"sy";
NSString *const OGAServiceMonitoringDevcStaging = @"ms-ads-monitoring-events";
NSString *const OGAServiceMonitoringProd = @"am-V1";
#pragma mark ↓ Legacy Constants ↓
NSString *const OGAServiceLaunch = @"launch";
NSString *const OGAServicePreCache = @"pl";
NSString *const OGAServiceTrack = @"track";
NSString *const OGAServiceAdHistory = @"ad_history";

#pragma mark - API Versions
NSString *const OGAApiV1 = @"v1";
NSString *const OGAApiV2 = @"v2";
#pragma mark ↓ Legacy Constants ↓
NSString *const OGAApiV3 = @"v3";

#pragma mark - URL Patterns
NSString *const OGAURLPattern = @"https://%@.%@/%@/%@";
#pragma mark ↓ Legacy Constants ↓
NSString *const OGAProductionURL = @"https://%@-%@.presage.io/%@/%@";
NSString *const OGAStagingURL = @"https://%@-%@.staging.presage.io/%@/%@";
NSString *const OGADevCURL = @"https://%@-%@.devc.cloud.ogury.io/%@/%@";

#pragma mark - Domains
NSString *const OGADomainDevc = @"devc.cloud.ogury.io";
NSString *const OGADomainStaging = @"staging.cloud.ogury.io";
NSString *const OGADomainProd = @"presage.io";

#pragma mark - Paths
NSString *const OGAPathProfig = @"inapp/config";
NSString *const OGAPathMonitoring = @"sdk-ads-monitoring";
NSString *const OGAPathAdSync = @"ad_sync";

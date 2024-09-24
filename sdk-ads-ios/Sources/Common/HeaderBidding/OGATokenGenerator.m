//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGATokenGenerator.h"
#import "NSDictionary+OGABase64.h"
#import "OGAInternal.h"
#import "OGAAssetKeyManager.h"
#import "OGAAdIdentifierService.h"
#import "OGAConfigurationUtils.h"
#import "UIApplication+Orientation.h"
#import "OGADeviceService.h"
#import "OGATokenConstants.h"
#import "OGAAdConfiguration.h"
#import "OGAConstants.h"
#import "OGAProfigManager.h"
#import "OGAAdPrivacyConfiguration.h"
#import "OGASKAdNetworkService.h"
#import "OGAProfigManager.h"
#import "OGAAdPrivacyConfiguration.h"
#import "OGAOMIDService.h"
#import "OGAProfigDao.h"
#import "OGADevice.h"
#import "OguryAdError+Internal.h"

@interface OGATokenGenerator ()

@property(nonatomic, strong) OGAAssetKeyManager *assetKeyManager;
@property(nonatomic, strong) OGAInternal *internal;
@property(nonatomic, strong) OGADeviceService *deviceService;
@property(nonatomic, strong) OGAProfigManager *profigManager;
@property(nonatomic, strong) OGAOMIDService *omidService;
@property(nonatomic, strong) OGAProfigDao *profigDao;

@end

@implementation OGATokenGenerator

- (instancetype)init {
    return [self init:[OGAAssetKeyManager shared]
             internal:[OGAInternal shared]
        deviceService:[[OGADeviceService alloc] init]
        profigManager:[OGAProfigManager shared]
            profigDao:[OGAProfigDao shared]
          omidService:[OGAOMIDService shared]];
}

- (instancetype)init:(OGAAssetKeyManager *)assetKeyManager
            internal:(OGAInternal *)internal
       deviceService:(OGADeviceService *)deviceService
       profigManager:(OGAProfigManager *)profigManager
           profigDao:(OGAProfigDao *)profigDao
         omidService:(OGAOMIDService *)omidService {
    if (self = [super init]) {
        _assetKeyManager = assetKeyManager;
        _internal = internal;
        _deviceService = deviceService;
        _profigManager = profigManager;
        _omidService = omidService;
        _profigDao = profigDao;
    }
    return self;
}

- (OguryError *_Nullable)tokenGenerationDenied {
    OguryError *error = nil;
    if (![self.assetKeyManager checkAssetKeyIsValid:&error type:OguryAdErrorTypeLoad]) {
        return [OguryAdError headerBiddingWithStacktrace:error.localizedDescription ?: @"Invalid Assetkey"];
    }

    if (!self.profigDao.profigFullResponse.adsEnabled) {
        return [OguryAdError headerBiddingWithStacktrace:[NSString stringWithFormat:@"Ads are disabled (%@)", self.profigDao.profigFullResponse.disablingReason ?: @"Unknown reason"]];
    }

    return nil;
}

- (OGADevice *)currentDevice {
    return [[OGADevice alloc] init];
}

- (void)bidderToken:(HeaderBiddingCompletionBlock)completion {
    [self bidderTokenWithCampaignId:nil creativeId:nil dspCreativeId:nil dspRegion:nil completion:completion];
}

- (void)bidderTokenWithCampaignId:(NSString *)campaignId
                       completion:(HeaderBiddingCompletionBlock)completion {
    [self bidderTokenWithCampaignId:campaignId creativeId:nil dspCreativeId:nil dspRegion:nil completion:completion];
}

- (void)bidderTokenWithCampaignId:(nonnull NSString *)campaignId
                       creativeId:(NSString *_Nullable)creativeId
                       completion:(HeaderBiddingCompletionBlock)completion {
    [self bidderTokenWithCampaignId:campaignId creativeId:creativeId dspCreativeId:nil dspRegion:nil completion:completion];
}

- (void)bidderTokenWithCampaignId:(NSString *_Nullable)campaignId
                       creativeId:(NSString *_Nullable)creativeId
                    dspCreativeId:(NSString *_Nullable)dspCreativeId
                        dspRegion:(NSString *_Nullable)dspRegion
                       completion:(HeaderBiddingCompletionBlock)completion {
    if ([[self profigManager] shouldSync]) {
        [[self profigManager] syncProfigWithCompletion:^(OGAProfigFullResponse *response, NSError *error) {
            [self collectBidderTokenDataWithCampaignId:campaignId
                                            creativeId:creativeId
                                         dspCreativeId:dspCreativeId
                                             dspRegion:dspRegion
                                            completion:completion];
        }];
    } else {
        [self collectBidderTokenDataWithCampaignId:campaignId
                                        creativeId:creativeId
                                     dspCreativeId:dspCreativeId
                                         dspRegion:dspRegion
                                        completion:completion];
    }
}

- (void)collectBidderTokenDataWithCampaignId:(NSString *_Nullable)campaignId
                                  creativeId:(NSString *_Nullable)creativeId
                               dspCreativeId:(NSString *_Nullable)dspCreativeId
                                   dspRegion:(NSString *_Nullable)dspRegion
                                  completion:(HeaderBiddingCompletionBlock)completion {
    OguryError *deniedError = [self tokenGenerationDenied];
    if (deniedError != nil) {
        completion(nil, deniedError);
        return;
    }
    completion([[self computeBidderTokenDataWithCampaignId:campaignId
                                                creativeId:creativeId
                                             dspCreativeId:dspCreativeId
                                                 dspRegion:dspRegion] ogaEncodeToBase64],
               nil);
}

- (NSDictionary *)computeBidderTokenDataWithCampaignId:(NSString *_Nullable)campaignId
                                            creativeId:(NSString *_Nullable)creativeId
                                         dspCreativeId:(NSString *_Nullable)dspCreativeId
                                             dspRegion:(NSString *_Nullable)dspRegion {
    OGAAdPrivacyConfiguration *privacyConfiguration = [self.profigManager currentPrivacyConfiguration];
    NSMutableDictionary *token = [NSMutableDictionary dictionary];
    [token addEntriesFromDictionary:@{
        OGATokenSDK : @{
            OGATokenModuleVersion : [self.internal getVersion],
            OGATokenBuildVersion : [self.internal getBuildVersion]
        }
    }];
    NSMutableDictionary *privacy = [NSMutableDictionary dictionary];
    privacy[OGARequestBodyPrivacyTCFKey] = [self tcfConsentString];
    privacy[OGARequestBodyPrivacyGPPKey] = [self gppConsentString];
    privacy[OGARequestBodyPrivacyGPPSIDKey] = [self gppSidConsentString];
    NSDictionary *privacyDatas = [self privacyDatas];
    if ([privacyDatas count] > 0) {
        privacy[OGARequestBodyPrivacyPublisherDataKey] = privacyDatas;
    }
    token[OGARequestBodyPrivacyComplianceKey] = privacy;

    /// device
    NSMutableDictionary *device = [@{} mutableCopy];
    if ([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionDeviceOrientation]) {
        device[OGATokenScreen] = @{OGATokenOrientation : [self.deviceService interfaceOrientation]};
    }
    if ([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionDeviceIds]) {
        device[OGATokenManufacturerKey] = [OGAConfigurationUtils getManufacturer];
        device[OGATokenModelKey] = [[self currentDevice] name];
    }
    device[OGATokenisiOSAppOnMac] = @([OGAConfigurationUtils isiOSAppOnMac]);

    /// settings
    NSMutableDictionary *settings = [@{} mutableCopy];
    if ([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionLowPowerMode]) {
        settings[OGALowBatteryMode] = [NSNumber numberWithBool:[OGAAdConfiguration isOnLowPowerMode]];
    }
    if ([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionTimezone]) {
        settings[OGATokenTimeZone] = [OGAConfigurationUtils timeZone];
    }
    if ([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionIDFV]) {
        settings[OGAIdentifierForVendor] = [OGAConfigurationUtils getVendorId];
    }
    if ([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionIDFA]) {
        settings[OGAAdvertisingIdentifier] = [OGAAdIdentifierService getAdIdentifier];
    }
    if (settings.count > 0) {
        device[OGATokenSettings] = settings;
    }
    [token setValue:device forKey:OGATokenDevice];

    /// app
    NSMutableDictionary *app = [@{
        OGARequestBodyAppVersionKey : [OGAConfigurationUtils getAppMarketingVersion],
        OGATokenAssetType : [OGAConfigurationUtils getDeviceOS],
        OGATokenBundleIdentifier : [OGAConfigurationUtils getAppBundleIdentifer]
    } mutableCopy];
    if (self.assetKeyManager.assetKey) {
        [app setObject:self.assetKeyManager.assetKey forKey:OGATokenAssetKey];
    }
    if ([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionInstanceToken] && [OGAAdIdentifierService getInstanceToken]) {
        [app setObject:[OGAAdIdentifierService getInstanceToken] forKey:OGATokenInstanceToken];
    }
    if (app.count > 0) {
        [token setObject:app forKey:OGATokenApplication];
    }

    // ad_sync
    NSMutableDictionary *adSync = [NSMutableDictionary new];
    NSMutableDictionary *ad = [NSMutableDictionary new];
    if ((campaignId ?: @"").length > 0) {
        [ad setObject:campaignId forKey:OGATokenCampaignId];
    }
    if ((creativeId ?: @"").length > 0) {
        [ad setObject:creativeId forKey:OGATokenCreativeId];
    }
    // programmatic
    if (creativeId && ![creativeId isEqualToString:@""] && dspRegion && ![dspRegion isEqualToString:@""]) {
        NSMutableDictionary *dsp = [[NSMutableDictionary alloc] init];
        [dsp setObject:dspCreativeId forKey:OGATokenCreativeId];
        [dsp setObject:dspRegion forKey:OGATokenRegion];
        [ad setObject:dsp forKey:OGATokenDsp];
    }
    if (ad.allKeys.count > 0) {
        [adSync setObject:ad forKey:OGATokenAd];
    }
    // sknetwork
    if ([OGASKAdNetworkService sdkIsCompatibleWithSKAdNetwork]) {
        NSMutableDictionary *skanToken = [NSMutableDictionary dictionary];
        [skanToken setObject:[OGASKAdNetworkService getSKAdNetworkVersion] ?: @"" forKey:OGATokenSKANVersion];
        NSArray<NSString *> *adNetworkItems = [OGASKAdNetworkService getInfoAdNetworkItems];
        if (adNetworkItems.count > 0) {
            [skanToken setObject:adNetworkItems forKey:OGATokenSKANetworkIdentifierList];
        }
        [adSync setObject:skanToken forKey:OGATokenSKAN];
    }
    // omid
    BOOL isOMIDCompliant = (self.profigDao.profigFullResponse.isOmidEnabled && self.omidService.isOMIDFrameworkPresent);
    adSync[OGATokenOmidKey] = @{
        OGATokenOmidIntegrationIsCompliantKey : isOMIDCompliant ? @(YES) : @(NO),
        OGATokenOmidIntegrationVersionKey : @([OGAOMIDService omidVersion])
    };
    if (adSync.allKeys.count > 0) {
        [token setObject:adSync forKey:OGATokenAdSync];
    }

    return token;
}

- (NSString *)gppConsentString {
    return [OGAAdIdentifierService gppConsentString];
}

- (NSString *)gppSidConsentString {
    return [OGAAdIdentifierService gppSID];
}

- (NSString *)tcfConsentString {
    return [OGAAdIdentifierService tcfConsentString];
}

- (NSDictionary<NSString *, id> *)privacyDatas {
    return [OGAAdIdentifierService privacyDatas];
}

@end

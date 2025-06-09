//
//  Copyright © 2019 Ogury Ltd. All rights reserved.
//

#import "OGAAdConfiguration.h"
#import "OguryBannerAdSize.h"
#import <Foundation/NSProcessInfo.h>

NSString *const OGAAdConfigurationAdTypeStandardBanners = @"standard_banners";
NSString *const OGAAdConfigurationAdTypeThumbnailAd = @"overlay_thumbnail";
NSString *const OGAAdConfigurationAdTypeRewarded = @"optin_video";
NSString *const OGAAdConfigurationAdTypeInterstitial = @"interstitial";

@interface OGAAdConfiguration ()

@property(nonatomic, assign, readwrite) OguryAdsADType adType;
@property(nonatomic, strong, readwrite) OGADelegateDispatcher *delegateDispatcher;
@property(nonatomic, copy, readwrite) UIViewController * (^viewControllerProvider)(void);
@property(nonatomic, copy, readwrite) UIView * (^viewProvider)(void);

@end

@implementation OGAAdConfiguration

- (instancetype)init {
    if (self = [super init]) {
        _viewControllerProvider = ^UIViewController * {
            return nil;
        };

        _viewProvider = ^UIView * {
            return nil;
        };
    }
    return self;
}

- (instancetype)initWithType:(OguryAdsADType)type
                    adUnitId:(NSString *)adUnitId
          delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher
      viewControllerProvider:(OGAViewControllerProvider)viewControllerProvider {
    return [self initWithType:type
                      adUnitId:adUnitId
            delegateDispatcher:delegateDispatcher
        viewControllerProvider:viewControllerProvider
                  viewProvider:nil];
}

- (instancetype)initWithType:(OguryAdsADType)type
                    adUnitId:(NSString *)adUnitId
          delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher
      viewControllerProvider:(OGAViewControllerProvider)viewControllerProvider
                viewProvider:(OGAViewProvider _Nullable)viewProvider {
    return [self initWithType:type
                      adUnitId:adUnitId
            delegateDispatcher:delegateDispatcher
        viewControllerProvider:viewControllerProvider
                  viewProvider:viewProvider
                        locale:[NSLocale currentLocale]];
}

- (instancetype)initWithType:(OguryAdsADType)type
                    adUnitId:(NSString *)adUnitId
          delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher
      viewControllerProvider:(OGAViewControllerProvider)viewControllerProvider
                viewProvider:(OGAViewProvider _Nullable)viewProvider
                      locale:(NSLocale *)locale {
    if (self = [self init]) {
        _adType = type;
        _adUnitId = adUnitId;
        _delegateDispatcher = delegateDispatcher;
        _viewProvider = viewProvider;
        _viewControllerProvider = viewControllerProvider;
        _lowBatteryMode = [OGAAdConfiguration isOnLowPowerMode];
        _webviewLoadTimeout = [[NSNumber alloc] initWithInt:80];
        _locale = locale;
        _monitoringDetails = [OGAMonitoringDetails new];
        _isHeaderBidding = false;
        _numberOfWebviewTerminatedReloadAttempts = 0;
        _logDetails = [OGALogDetail new];
    }
    return self;
}

- (void)setMediation:(OguryMediation *)mediation {
    self.monitoringDetails.mediation = mediation;
}

- (OguryMediation *)mediation {
    return self.monitoringDetails.mediation ?: nil;
}

+ (BOOL)isOnLowPowerMode {
    NSProcessInfo *processInfo = NSProcessInfo.processInfo;
    if (processInfo != nil) {
        return processInfo.isLowPowerModeEnabled;
    } else {
        return NO;
    }
}

- (instancetype)copyWithZone:(NSZone *)zone {
    OGAAdConfiguration *configuration = [[OGAAdConfiguration alloc] initWithType:self.adType
                                                                        adUnitId:self.adUnitId
                                                              delegateDispatcher:self.delegateDispatcher
                                                          viewControllerProvider:self.viewControllerProvider
                                                                    viewProvider:self.viewProvider];
    configuration.campaignId = self.campaignId;
    configuration.creativeId = self.creativeId;
    configuration.adDsp = [self.adDsp copy];
    configuration.size = self.size;
    configuration.requestedSize = self.requestedSize;
    configuration.creativeSize = self.creativeSize;
    configuration.corner = self.corner;
    configuration.offset = self.offset;
    configuration.blackListViewControllers = [self.blackListViewControllers copy];
    configuration.whitelistBundleIdentifiers = [self.whitelistBundleIdentifiers copy];
    configuration.adMarkupSync = self.adMarkupSync;
    configuration.lowBatteryMode = self.lowBatteryMode;
    configuration.monitoringDetails = self.monitoringDetails;
    configuration.expirationContext = self.expirationContext;
    configuration.locale = self.locale;
    configuration.logDetails = self.logDetails;
    configuration.isHeaderBidding = self.isHeaderBidding;
    configuration.encodedAdMarkup = self.encodedAdMarkup;
    configuration.numberOfWebviewTerminatedReloadAttempts = self.numberOfWebviewTerminatedReloadAttempts;
    if (@available(iOS 13.0, *)) {
        configuration.scene = self.scene;
    }

    return configuration;
}

- (NSString *)getAdTypeString {
    switch (self.adType) {
        case OguryAdsTypeBanner:
            return OGAAdConfigurationAdTypeStandardBanners;
        case OguryAdsTypeThumbnailAd:
            return OGAAdConfigurationAdTypeThumbnailAd;
        case OguryAdsTypeRewardedAd:
            return OGAAdConfigurationAdTypeRewarded;
        case OguryAdsTypeInterstitial:
            return OGAAdConfigurationAdTypeInterstitial;
        default:
            return @"";
    }
}

- (NSInteger)getWidthForAdType {
    switch (self.adType) {
        case OguryAdsTypeBanner: {
            if (CGSizeEqualToSize(self.size, [[OguryBannerAdSize small_banner_320x50] getSize])) {
                return 320;
            }
            if (CGSizeEqualToSize(self.size, [[OguryBannerAdSize mrec_300x250] getSize])) {
                return 300;
            }
            return 0;
        }
        default:
            return 0;
    }
}

- (NSInteger)getHeightForAdType {
    switch (self.adType) {
        case OguryAdsTypeBanner: {
            if (CGSizeEqualToSize(self.size, [[OguryBannerAdSize small_banner_320x50] getSize])) {
                return 50;
            }
            if (CGSizeEqualToSize(self.size, [[OguryBannerAdSize mrec_300x250] getSize])) {
                return 250;
            }
            return 0;
        }
        default:
            return 0;
    }
}

- (void)startNewMonitoringSession {
    [self.monitoringDetails startNewMonitoringSession];
}

- (void)reset {
    self.monitoringDetails = [OGAMonitoringDetails new];
    self.numberOfWebviewTerminatedReloadAttempts = 0;
}

- (BOOL)configurationHasChanged:(NSString *_Nullable)newCampaignId
                     creativeId:(NSString *_Nullable)newCreativeId
                  dspCreativeId:(NSString *_Nullable)newDspCreativeId
                      dspRegion:(NSString *_Nullable)newDspRegion {
    return (newCampaignId != nil && self.campaignId != newCampaignId) || (newCreativeId != nil && self.creativeId != newCreativeId) || (newDspCreativeId != nil && self.adDsp.creativeId != newDspCreativeId) || (newDspRegion != nil && self.adDsp.region != newDspRegion);
}

- (void)setLogOrigin:(NSString *)origin {
    self.logDetails.origin = origin;
}

@end

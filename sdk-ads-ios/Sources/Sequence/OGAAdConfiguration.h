//
//  Copyright © 2019 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGADelegateDispatcher.h"
#import "OguryAdsADType.h"
#import "OGAExpirationContext.h"
#import "OGAMonitoringDetails.h"
#import "OGAAdDsp.h"
#import "OguryMediation.h"
#import "OGAThumbnailAdConstants.h"
#import "OguryOffset.h"
#import "OguryRectCorner.h"

NS_ASSUME_NONNULL_BEGIN

typedef UIViewController *_Nonnull (^OGAViewControllerProvider)(void);
typedef UIView *_Nonnull (^OGAViewProvider)(void);

extern NSString *const OGAAdConfigurationAdTypeSmallBanner;
extern NSString *const OGAAdConfigurationAdTypeMPU;
extern NSString *const OGAAdConfigurationAdTypeThumbnailAd;
extern NSString *const OGAAdConfigurationAdTypeRewarded;
extern NSString *const OGAAdConfigurationAdTypeInterstitial;

@interface OGAAdConfiguration : NSObject <NSCopying>

@property(nonatomic, assign, readonly) OguryAdsADType adType;
@property(nonatomic, assign) BOOL isImpression;
@property(nonatomic, assign) BOOL lowBatteryMode;
@property(nonatomic, copy, readonly) NSString *adUnitId;
@property(nonatomic, strong, readonly) OGADelegateDispatcher *delegateDispatcher;
@property(nonatomic, copy, nullable, readonly) UIViewController * (^viewControllerProvider)(void);
@property(nonatomic, copy, nullable, readonly) UIView * (^viewProvider)(void);
@property(nonatomic, strong, readwrite) NSLocale *locale;
@property(nonatomic, copy, nullable) NSString *campaignId;
@property(nonatomic, copy, nullable) NSString *creativeId;
@property(nonatomic, copy, nullable) OGAAdDsp *adDsp;

@property(nonatomic, copy, nullable) NSString *userId;
@property(nonatomic, assign) CGSize size;
@property(nonatomic, strong) OGAExpirationContext *expirationContext;
@property(nonatomic, strong, nullable) NSArray *adMarkupSync;
@property(nonatomic, strong, nullable) NSString *encodedAdMarkup;
@property(nonatomic, assign) BOOL isHeaderBidding;
@property(nonatomic, strong) NSNumber *webviewLoadTimeout;
@property(nonatomic, assign) NSUInteger numberOfWebviewTerminatedReloadAttempts;
@property(nonatomic, strong) OGAMonitoringDetails *monitoringDetails;
@property(nonatomic, assign) OguryMediation *mediation;
@property(nonatomic, strong) NSArray *extras;

// Thumbnail Ad specific
@property(nonatomic, assign) OguryRectCorner corner;
@property(nonatomic, assign) OguryOffset offset;
@property(nonatomic, strong, nullable) NSArray<NSString *> *blackListViewControllers;
@property(nonatomic, strong, nullable) NSArray<NSString *> *whitelistBundleIdentifiers;
@property(nonatomic, weak, nullable) UIWindowScene *scene API_AVAILABLE(ios(13.0));

- (NSString *)getAdTypeString;
+ (BOOL)isOnLowPowerMode;

#pragma mark - Initialization

- (instancetype)initWithType:(OguryAdsADType)type
                    adUnitId:(NSString *)adUnitId
          delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher
      viewControllerProvider:(OGAViewControllerProvider)viewControllerProvider;

- (instancetype)initWithType:(OguryAdsADType)type
                    adUnitId:(NSString *)adUnitId
          delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher
      viewControllerProvider:(OGAViewControllerProvider _Nullable)viewControllerProvider
                viewProvider:(OGAViewProvider _Nullable)viewProvider;

- (void)startNewMonitoringSession;
- (void)reset;

- (BOOL)configurationHasChanged:(NSString *_Nullable)newCampaignId
                     creativeId:(NSString *_Nullable)newCreativeId
                  dspCreativeId:(NSString *_Nullable)newDspCreativeId
                      dspRegion:(NSString *_Nullable)newDspRegion;
@end

NS_ASSUME_NONNULL_END

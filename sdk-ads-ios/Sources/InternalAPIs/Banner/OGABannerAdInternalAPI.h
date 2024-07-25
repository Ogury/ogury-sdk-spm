//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OGAAdInternalAPI.h"
#import "OGADelegateDispatcher.h"
#import "OguryAdsBannerSize.h"
#import "OguryMediation.h"

@class OGAAdManager;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Constants

extern NSString *const OGABannerAdInternalAPIBannerDidMoveToWindowNotificationName;

@interface OGABannerAdInternalAPI : NSObject <OGAAdInternalAPI>

#pragma mark - properties

@property(nonatomic, strong, readonly) OGADelegateDispatcher *delegateDispatcher;
@property(nonatomic, weak, readonly) UIView *bannerView;
@property(nonatomic, assign, readonly) BOOL isExpanded;

#pragma mark - Initialization

- (instancetype)initWithAdUnitId:(NSString *)adUnitId
                      bannerView:(UIView *_Nullable)bannerView
              delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher
                       mediation:(OguryMediation *_Nullable)mediation;

#pragma mark - Methods

- (void)loadWithSize:(OguryAdsBannerSize *)size;

- (void)loadWithAdMarkup:(NSString *)adMarkup size:(OguryAdsBannerSize *)size;

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId size:(OguryAdsBannerSize *)size;

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId creativeId:(NSString *_Nullable)creativeId size:(OguryAdsBannerSize *)size;

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId creativeId:(NSString *_Nullable)creativeId dspCreativeId:(NSString *_Nullable)dspCreativeId dspRegion:(NSString *_Nullable)dspRegion size:(OguryAdsBannerSize *)size;

- (void)destroy;

- (BOOL)isLoaded;

- (void)didMoveToSuperview;

- (void)didMoveToWindow;

@end

NS_ASSUME_NONNULL_END

//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OGAAdInternalAPI.h"
#import "OGADelegateDispatcher.h"
#import "OguryBannerAdSize.h"
#import "OguryMediation.h"

@class OGAAdManager;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Constants

@class OGAAdConfiguration;

extern NSString *const OGABannerAdInternalAPIBannerDidMoveToWindowNotificationName;

@interface OGABannerAdViewInternalAPI : NSObject <OGAAdInternalAPI>

#pragma mark - properties

@property(nonatomic, strong, readonly) OGADelegateDispatcher *delegateDispatcher;
@property(nonatomic, weak, readonly) UIView *bannerView;
@property(nonatomic, assign, readonly) BOOL isExpanded;
@property(nonatomic, assign, readonly) BOOL isLoaded;

#pragma mark - Initialization

- (instancetype)initWithAdUnitId:(NSString *)adUnitId
                      bannerView:(UIView *_Nullable)bannerView
                            size:(OguryBannerAdSize *)size
              delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher
                       mediation:(OguryMediation *_Nullable)mediation;

#pragma mark - Methods

- (void)load;

- (void)loadWithAdMarkup:(NSString *)adMarkup;

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId;

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId creativeId:(NSString *_Nullable)creativeId;

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId
                creativeId:(NSString *_Nullable)creativeId
             dspCreativeId:(NSString *_Nullable)dspCreativeId
                 dspRegion:(NSString *_Nullable)dspRegion;

- (void)destroy;

- (void)didMoveToSuperview;

- (void)didMoveToWindow;

- (void)setLogOrigin:(NSString *)origin;
- (OGAAdConfiguration *)adConfiguration;
- (void)killWebview;

@end

NS_ASSUME_NONNULL_END

//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OguryBannerAdView.h"
#import "OguryBannerAdViewDelegateDispatcher.h"
#import "OGABannerAdViewInternalAPI.h"
#import "OGAAdConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface OguryBannerAdView (Testing)

@property(nonatomic, strong) OguryBannerAdViewDelegateDispatcher *delegateDispatcher;
@property(nonatomic, strong) OGABannerAdViewInternalAPI *internalAPI;

- (instancetype)initWithInternalAPI:(OGABannerAdViewInternalAPI *_Nonnull)internalAPI;

- (void)loadWithCampaignId:(NSString *)campaignId;

- (void)loadWithCampaignId:(NSString *)campaignId
                creativeId:(NSString *)creativeId
             dspCreativeId:(NSString *)dspCreativeId
                 dspRegion:(NSString *)dspRegion;

- (void)loadWithCampaignId:(NSString *)campaignId creativeId:(NSString *)creativeId;

@end

@interface OGABannerAdViewInternalAPI (Test)

@property(nonatomic, strong) OGAAdConfiguration *configuration;

@end

NS_ASSUME_NONNULL_END

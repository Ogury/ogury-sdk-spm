//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OguryBannerAd.h"
#import "OguryBannerAdDelegateDispatcher.h"
#import "OGABannerAdInternalAPI.h"
#import "OGAAdConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface OguryBannerAd (Testing)

@property(nonatomic, strong) OguryBannerAdDelegateDispatcher *delegateDispatcher;
@property(nonatomic, strong) OGABannerAdInternalAPI *internalAPI;

- (instancetype)initWithInternalAPI:(OGABannerAdInternalAPI *_Nonnull)internalAPI;

- (void)loadWithCampaignId:(NSString *)campaignId;

- (void)loadWithCampaignId:(NSString *)campaignId
                creativeId:(NSString *)creativeId
             dspCreativeId:(NSString *)dspCreativeId
                 dspRegion:(NSString *)dspRegion;

- (void)loadWithCampaignId:(NSString *)campaignId creativeId:(NSString *)creativeId;

@end

@interface OGABannerAdInternalAPI (Test)

@property(nonatomic, strong) OGAAdConfiguration *configuration;

@end

NS_ASSUME_NONNULL_END

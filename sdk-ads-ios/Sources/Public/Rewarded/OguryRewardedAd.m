//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OguryRewardedAd.h"

#import "OGARewardedAdInternalAPI.h"
#import "OguryRewardedAdDelegateDispatcher.h"

@interface OguryRewardedAd ()

@property(nonatomic, strong) OguryRewardedAdDelegateDispatcher *delegateDispatcher;
@property(nonatomic, strong) OGARewardedAdInternalAPI *internalAPI;

@end

@implementation OguryRewardedAd

#pragma mark - Initialization

- (instancetype)initWithAdUnitId:(NSString *_Nonnull)adUnitId mediation:(OguryMediation *_Nonnull)mediation {
    return [self initWithInternalAPI:[[OGARewardedAdInternalAPI alloc] initWithAdUnitId:adUnitId
                                                                     delegateDispatcher:[[OguryRewardedAdDelegateDispatcher alloc] init]
                                                                              mediation:mediation]];
}

- (instancetype)initWithAdUnitId:(NSString *_Nonnull)adUnitId {
    return [self initWithInternalAPI:[[OGARewardedAdInternalAPI alloc] initWithAdUnitId:adUnitId
                                                                     delegateDispatcher:[[OguryRewardedAdDelegateDispatcher alloc] init]
                                                                              mediation:nil]];
}

- (instancetype)initWithInternalAPI:(OGARewardedAdInternalAPI *_Nonnull)internalAPI {
    if (self = [super init]) {
        _internalAPI = internalAPI;
        _delegateDispatcher = (OguryRewardedAdDelegateDispatcher *)internalAPI.delegateDispatcher;
        _delegateDispatcher.rewardedAd = self;
    }
    return self;
}

#pragma mark - Properties

- (NSString *)adUnitId {
    return self.internalAPI.adUnitId;
}

- (id<OguryRewardedAdDelegate>)delegate {
    return self.delegateDispatcher.delegate;
}

- (void)setDelegate:(id<OguryRewardedAdDelegate>)delegate {
    self.delegateDispatcher.delegate = delegate;
}

#pragma mark - Public Methods

- (void)load {
    [self.internalAPI load];
}

- (void)loadWithAdMarkup:(NSString *)adMarkup {
    [self.internalAPI loadWithAdMarkup:adMarkup];
}

- (void)loadWithCampaignId:(NSString *)campaignId {
    [self.internalAPI loadWithCampaignId:campaignId];
}

- (void)loadWithCampaignId:(NSString *)campaignId creativeId:(NSString *)creativeId {
    [self.internalAPI loadWithCampaignId:campaignId creativeId:creativeId];
}

- (void)loadWithCampaignId:(NSString *)campaignId creativeId:(NSString *)creativeId dspCreativeId:(NSString *)dspCreativeId dspRegion:(NSString *)dspRegion {
    [self.internalAPI loadWithCampaignId:campaignId
                              creativeId:creativeId
                           dspCreativeId:dspCreativeId
                               dspRegion:dspRegion];
}

- (BOOL)isLoaded {
    return self.internalAPI.isLoaded;
}

- (void)showAdInViewController:(UIViewController *)viewController {
    [self.internalAPI showAdInViewController:viewController];
}

@end

//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import "OguryBannerAd.h"
#import "OguryBannerAdDelegateDispatcher.h"
#import "OGABannerAdInternalAPI.h"

@interface OguryBannerAd ()

@property(nonatomic, strong) OguryBannerAdDelegateDispatcher *delegateDispatcher;
@property(nonatomic, strong) OGABannerAdInternalAPI *internalAPI;

@end

@implementation OguryBannerAd

#pragma mark - Initialization

- (instancetype)initWithAdUnitId:(NSString *)adUnitId mediation:(OguryMediation *_Nonnull)mediation {
    return [self initWithInternalAPI:[[OGABannerAdInternalAPI alloc] initWithAdUnitId:adUnitId
                                                                           bannerView:self
                                                                   delegateDispatcher:[[OguryBannerAdDelegateDispatcher alloc] init]
                                                                            mediation:mediation]];
}

- (instancetype)initWithAdUnitId:(NSString *_Nonnull)adUnitId {
    return [self initWithInternalAPI:[[OGABannerAdInternalAPI alloc] initWithAdUnitId:adUnitId
                                                                           bannerView:self
                                                                   delegateDispatcher:[[OguryBannerAdDelegateDispatcher alloc] init]
                                                                            mediation:nil]];
}

- (instancetype)initWithInternalAPI:(OGABannerAdInternalAPI *_Nonnull)internalAPI {
    if (self = [super init]) {
        _internalAPI = internalAPI;
        _delegateDispatcher = (OguryBannerAdDelegateDispatcher *)internalAPI.delegateDispatcher;
        _delegateDispatcher.banner = self;
    }

    return self;
}

#pragma mark - Properties

- (NSString *)adUnitId {
    return self.internalAPI.adUnitId;
}

- (id<OguryBannerAdDelegate>)delegate {
    return self.delegateDispatcher.delegate;
}

- (void)setDelegate:(id<OguryBannerAdDelegate>)delegate {
    self.delegateDispatcher.delegate = delegate;
}

- (BOOL)isExpanded {
    return self.internalAPI.isExpanded;
}

#pragma mark - Public Methods

- (void)loadWithSize:(OguryAdsBannerSize *)size {
    [self.internalAPI loadWithSize:size];
}

- (void)loadWithAdMarkup:(NSString *)adMarkup size:(OguryAdsBannerSize *)size {
    [self.internalAPI loadWithAdMarkup:adMarkup size:size];
}

- (void)loadWithCampaignId:(NSString *)campaignId size:(OguryAdsBannerSize *)size {
    [self.internalAPI loadWithCampaignId:campaignId size:size];
}

- (void)loadWithCampaignId:(NSString *)campaignId creativeId:(NSString *)creativeId size:(OguryAdsBannerSize *)size {
    [self.internalAPI loadWithCampaignId:campaignId creativeId:creativeId size:size];
}

- (void)loadWithCampaignId:(NSString *)campaignId creativeId:(NSString *)creativeId dspCreativeId:(NSString *)dspCreativeId dspRegion:(NSString *)dspRegion size:(OguryAdsBannerSize *)size {
    [self.internalAPI loadWithCampaignId:campaignId creativeId:creativeId dspCreativeId:dspCreativeId dspRegion:dspRegion size:size];
}

- (void)destroy {
    [self.internalAPI destroy];
}

- (BOOL)isLoaded {
    return [self.internalAPI isLoaded];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];

    [self.internalAPI didMoveToSuperview];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];

    [self.internalAPI didMoveToWindow];
}

@end

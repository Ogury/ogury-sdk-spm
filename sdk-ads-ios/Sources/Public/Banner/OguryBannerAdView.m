//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import "OguryBannerAdView.h"
#import "OGAAdConfiguration.h"
#import "OguryBannerAdViewDelegateDispatcher.h"
#import "OGABannerAdViewInternalAPI.h"

@interface OguryBannerAdView ()

@property(nonatomic, strong) OguryBannerAdViewDelegateDispatcher *delegateDispatcher;
@property(nonatomic, strong) OGABannerAdViewInternalAPI *internalAPI;
- (void)setLogOrigin:(NSString *)origin;
- (OGAAdConfiguration *)adConfiguration;

@end

@implementation OguryBannerAdView

#pragma mark - Initialization

- (instancetype)initWithAdUnitId:(NSString *)adUnitId size:(OguryBannerAdSize *)size mediation:(OguryMediation *_Nonnull)mediation {
    return [self initWithInternalAPI:[[OGABannerAdViewInternalAPI alloc] initWithAdUnitId:adUnitId
                                                                               bannerView:self
                                                                                     size:size
                                                                       delegateDispatcher:[[OguryBannerAdViewDelegateDispatcher alloc] init]
                                                                                mediation:mediation]];
}

- (instancetype)initWithAdUnitId:(NSString *_Nonnull)adUnitId size:(OguryBannerAdSize *)size {
    return [self initWithInternalAPI:[[OGABannerAdViewInternalAPI alloc] initWithAdUnitId:adUnitId
                                                                               bannerView:self
                                                                                     size:size
                                                                       delegateDispatcher:[[OguryBannerAdViewDelegateDispatcher alloc] init]
                                                                                mediation:nil]];
}

- (instancetype)initWithInternalAPI:(OGABannerAdViewInternalAPI *_Nonnull)internalAPI {
    if (self = [super init]) {
        _internalAPI = internalAPI;
        _delegateDispatcher = (OguryBannerAdViewDelegateDispatcher *)internalAPI.delegateDispatcher;
        _delegateDispatcher.banner = self;
    }

    return self;
}

#pragma mark - Properties

- (NSString *)adUnitId {
    return self.internalAPI.adUnitId;
}

- (id<OguryBannerAdViewDelegate>)delegate {
    return self.delegateDispatcher.delegate;
}

- (void)setDelegate:(id<OguryBannerAdViewDelegate>)delegate {
    self.delegateDispatcher.delegate = delegate;
}

- (BOOL)isExpanded {
    return self.internalAPI.isExpanded;
}

- (BOOL)isLoaded {
    return self.internalAPI.isLoaded;
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

- (void)loadWithCampaignId:(NSString *)campaignId
                creativeId:(NSString *)creativeId
             dspCreativeId:(NSString *)dspCreativeId
                 dspRegion:(NSString *)dspRegion {
    [self.internalAPI loadWithCampaignId:campaignId creativeId:creativeId dspCreativeId:dspCreativeId dspRegion:dspRegion];
}

- (void)destroy {
    [self.internalAPI destroy];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];

    [self.internalAPI didMoveToSuperview];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];

    [self.internalAPI didMoveToWindow];
}

- (void)setLogOrigin:(NSString *)origin {
    [self.internalAPI setLogOrigin:origin];
}

- (OGAAdConfiguration *)adConfiguration {
    return self.internalAPI.adConfiguration;
}

@end

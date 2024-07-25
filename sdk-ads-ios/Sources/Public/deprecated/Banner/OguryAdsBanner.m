//
//  Copyright © 2019 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryAdsBanner.h"
#import "OGABannerAdInternalAPI.h"
#import "OguryAdsBannerDelegateDispatcher.h"
#import "OGAMraidCommand.h"
#import "OGAAssetKeyManager.h"

@interface OguryAdsBanner ()

@property(nonatomic, strong) OguryAdsBannerDelegateDispatcher *delegateDispatcher;
@property(nonatomic, strong, nullable) OGABannerAdInternalAPI *internalAPI;

@end

@implementation OguryAdsBanner

#pragma mark - Initialization

- (instancetype _Nullable)initWithAdUnitID:(NSString *_Nullable)adUnitID {
    if (self = [super init]) {
        _adUnitID = adUnitID;
        _delegateDispatcher = [[OguryAdsBannerDelegateDispatcher alloc] init];
        _delegateDispatcher.banner = self;
        _internalAPI = [[OGABannerAdInternalAPI alloc] initWithAdUnitId:adUnitID
                                                             bannerView:self
                                                     delegateDispatcher:_delegateDispatcher
                                                              mediation:nil];

        [self setClipsToBounds:YES];
    }

    return self;
}

#pragma mark - Properties

- (id<OguryAdsBannerDelegate>)bannerDelegate {
    return self.delegateDispatcher.delegate;
}

- (void)setBannerDelegate:(id<OguryAdsBannerDelegate>)bannerDelegate {
    self.delegateDispatcher.delegate = bannerDelegate;
}

#pragma mark - Methods

- (void)close {
    [self.internalAPI destroy];
}

#pragma mark - Public

- (void)loadWithSize:(OguryAdsBannerSize *)size {
    [self loadCampaignID:nil maxSize:size];
}

- (void)loadCampaignID:(NSString *)campaignID adUnitID:(NSString *)adUnitID maxSize:(OguryAdsBannerSize *)maxSize {
    self.adUnitID = adUnitID;

    [self loadCampaignID:campaignID maxSize:maxSize];
}

- (void)loadCampaignID:(NSString *)campaignID maxSize:(OguryAdsBannerSize *)maxSize {
    if (!self.adUnitID || [self.adUnitID isEqualToString:@""]) {
        self.adUnitID = [NSString stringWithFormat:@"%@_default", OGAAssetKeyManager.shared.assetKey];
    }

    // Handle the case where we can mutate the ad unit id after the creation of the instance.
    if (self.internalAPI.adUnitId != self.adUnitID) {
        self.internalAPI = [[OGABannerAdInternalAPI alloc] initWithAdUnitId:self.adUnitID
                                                         delegateDispatcher:self.delegateDispatcher
                                                                  mediation:nil];
    }

    if (campaignID) {
        [self.internalAPI loadWithCampaignId:campaignID size:maxSize];
    } else {
        [self.internalAPI loadWithSize:maxSize];
    }
}

- (BOOL)isLoaded {
    return [self.internalAPI isLoaded];
}

- (BOOL)isExpanded {
    return [self.internalAPI isExpanded];
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

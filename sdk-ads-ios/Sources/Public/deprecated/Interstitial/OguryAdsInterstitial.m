//
//  Copyright © 2018 Ogury. All rights reserved.
//

#import "OguryAdsInterstitial.h"
#import "OGAAdConfiguration.h"
#import "OGAInterstitialAdInternalAPI.h"
#import "OguryAdsInterstitialDelegateDispatcher.h"
#import "OGAAssetKeyManager.h"

@interface OguryAdsInterstitial ()

#pragma mark - Properties

@property(nonatomic, strong) OguryAdsInterstitialDelegateDispatcher *delegateDispatcher;
@property(nonatomic, strong, nullable) OGAInterstitialAdInternalAPI *internalAPI;

@end

@implementation OguryAdsInterstitial

#pragma mark - Initialization

- (instancetype)init {
    return [self initWithAdUnitID:nil];
}

- (instancetype)initWithAdUnitID:(NSString *_Nullable)adUnitID {
    if (self = [super init]) {
        _delegateDispatcher = [[OguryAdsInterstitialDelegateDispatcher alloc] init];
        if (adUnitID) {
            _adUnitID = adUnitID;
        } else {
            _adUnitID = [NSString stringWithFormat:@"%@_default", OGAAssetKeyManager.shared.assetKey];
        }
        _internalAPI = [[OGAInterstitialAdInternalAPI alloc] initWithAdUnitId:adUnitID
                                                           delegateDispatcher:_delegateDispatcher
                                                                    mediation:nil];
    }

    return self;
}

#pragma mark - Properties

- (id<OguryAdsInterstitialDelegate>)interstitialDelegate {
    return self.delegateDispatcher.delegate;
}

- (void)setInterstitialDelegate:(id<OguryAdsInterstitialDelegate>)interstitialDelegate {
    self.delegateDispatcher.delegate = interstitialDelegate;
}

#pragma mark - Methods

- (void)showAdInViewController:(UIViewController *)viewController {
    [self.internalAPI showAdInViewController:viewController];
}

- (void)showInViewController:(UIViewController *)controller {
    [self showAdInViewController:controller];
}

- (void)load {
    [self loadWithCampaignId:nil];
}

// Private method to load with a specific campaign.
- (void)load:(OguryAdsADType)adType campaignID:(NSString *)campaignID adUnitID:(NSString *)adUnitID userID:(NSString *)userID {
    self.adUnitID = adUnitID;
    [self loadWithCampaignId:campaignID];
}

- (void)loadWithCampaignId:(NSString *)campaignId {
    if (!self.adUnitID || [self.adUnitID isEqualToString:@""]) {
        self.adUnitID = [NSString stringWithFormat:@"%@_default", OGAAssetKeyManager.shared.assetKey];
    }
    // Handle the case where we can mutate the ad unit id after the creation of the instance.
    if (self.internalAPI.adUnitId != self.adUnitID) {
        self.internalAPI = [[OGAInterstitialAdInternalAPI alloc] initWithAdUnitId:self.adUnitID
                                                               delegateDispatcher:self.delegateDispatcher
                                                                        mediation:nil];
    }
    if (campaignId) {
        [self.internalAPI loadWithCampaignId:campaignId];
    } else {
        [self.internalAPI load];
    }
}

- (BOOL)isLoaded {
    return [self.internalAPI isLoaded];
}

@end

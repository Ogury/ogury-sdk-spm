//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OguryInterstitialAd.h"

#import "OGAInterstitialAdInternalAPI.h"
#import "OguryInterstitialAdDelegateDispatcher.h"

@interface OguryInterstitialAd ()

@property(nonatomic, strong) OguryInterstitialAdDelegateDispatcher *delegateDispatcher;
@property(nonatomic, strong) OGAInterstitialAdInternalAPI *internalAPI;
- (void)setLogOrigin:(NSString *)origin;
- (OGAAdConfiguration *)adConfiguration;

@end

@implementation OguryInterstitialAd

#pragma mark - Initialization

- (instancetype)initWithAdUnitId:(NSString *_Nonnull)adUnitId mediation:(OguryMediation *_Nonnull)mediation {
    return [self initWithInternalAPI:[[OGAInterstitialAdInternalAPI alloc] initWithAdUnitId:adUnitId
                                                                         delegateDispatcher:[[OguryInterstitialAdDelegateDispatcher alloc] init]
                                                                                  mediation:mediation]];
}

- (instancetype)initWithAdUnitId:(NSString *_Nonnull)adUnitId {
    return [self initWithInternalAPI:[[OGAInterstitialAdInternalAPI alloc] initWithAdUnitId:adUnitId
                                                                         delegateDispatcher:[[OguryInterstitialAdDelegateDispatcher alloc] init]
                                                                                  mediation:nil]];
}

- (instancetype)initWithInternalAPI:(OGAInterstitialAdInternalAPI *_Nonnull)internalAPI {
    if (self = [super init]) {
        _internalAPI = internalAPI;
        _delegateDispatcher = (OguryInterstitialAdDelegateDispatcher *)internalAPI.delegateDispatcher;
        _delegateDispatcher.interstitial = self;
    }
    return self;
}

#pragma mark - Properties

- (NSString *)adUnitId {
    return self.internalAPI.adUnitId;
}

- (id<OguryInterstitialAdDelegate>)delegate {
    return self.delegateDispatcher.delegate;
}

- (void)setDelegate:(id<OguryInterstitialAdDelegate>)delegate {
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

- (void)setLogOrigin:(NSString *)origin {
    [self.internalAPI setLogOrigin:origin];
}

- (OGAAdConfiguration *)adConfiguration {
    return self.internalAPI.adConfiguration;
}

- (void)simulateWebviewTerminated {
#if defined(DEBUG) || defined(KILL_MODE_ENABLED)
    [self.internalAPI simulateWebviewTerminated];
#endif
}

- (WKWebView *)adWebview {
#if defined(DEBUG) || defined(KILL_MODE_ENABLED)
    return [self.internalAPI adWebview];
#else
    return nil;
#endif
}

@end

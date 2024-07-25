//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OguryOptinVideoAd.h"

#import "OGAOptinVideoAdInternalAPI.h"
#import "OguryOptinVideoAdDelegateDispatcher.h"

@interface OguryOptinVideoAd ()

@property(nonatomic, strong) OguryOptinVideoAdDelegateDispatcher *delegateDispatcher;
@property(nonatomic, strong) OGAOptinVideoAdInternalAPI *internalAPI;

@end

@implementation OguryOptinVideoAd

#pragma mark - Initialization

- (instancetype)initWithAdUnitId:(NSString *_Nonnull)adUnitId mediation:(OguryMediation *_Nonnull)mediation {
    return [self initWithInternalAPI:[[OGAOptinVideoAdInternalAPI alloc] initWithAdUnitId:adUnitId
                                                                       delegateDispatcher:[[OguryOptinVideoAdDelegateDispatcher alloc] init]
                                                                                mediation:mediation]];
}

- (instancetype)initWithAdUnitId:(NSString *_Nonnull)adUnitId {
    return [self initWithInternalAPI:[[OGAOptinVideoAdInternalAPI alloc] initWithAdUnitId:adUnitId
                                                                       delegateDispatcher:[[OguryOptinVideoAdDelegateDispatcher alloc] init]
                                                                                mediation:nil]];
}

- (instancetype)initWithInternalAPI:(OGAOptinVideoAdInternalAPI *_Nonnull)internalAPI {
    if (self = [super init]) {
        _internalAPI = internalAPI;
        _delegateDispatcher = (OguryOptinVideoAdDelegateDispatcher *)internalAPI.delegateDispatcher;
        _delegateDispatcher.optinVideo = self;
    }
    return self;
}

#pragma mark - Properties

- (NSString *)adUnitId {
    return self.internalAPI.adUnitId;
}

- (id<OguryOptinVideoAdDelegate>)delegate {
    return self.delegateDispatcher.delegate;
}

- (void)setDelegate:(id<OguryOptinVideoAdDelegate>)delegate {
    self.delegateDispatcher.delegate = delegate;
}

- (NSString *)userId {
    return self.internalAPI.userId;
}

- (void)setUserId:(NSString *)userId {
    self.internalAPI.userId = userId;
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
    return [self.internalAPI isLoaded];
}

- (void)showAdInViewController:(UIViewController *)viewController {
    [self.internalAPI showAdInViewController:viewController];
}

@end

//
//  Copyright © 2019 Ogury. All rights reserved.
//

#import "OguryAdsOptinVideo.h"

#import "OGAAdConfiguration.h"
#import "OguryAdsOptinVideoDelegateDispatcher.h"
#import "OGAOptinVideoAdInternalAPI.h"
#import "OGAAssetKeyManager.h"

@interface OguryAdsOptinVideo ()

#pragma mark - Properties

@property(nonatomic, strong) OguryAdsOptinVideoDelegateDispatcher *delegateDispatcher;
@property(nonatomic, strong) OGAOptinVideoAdInternalAPI *internalAPI;

@end

@implementation OguryAdsOptinVideo

#pragma mark - Initialization

- (instancetype)init {
    return [self initWithAdUnitID:nil];
}

- (instancetype)initWithAdUnitID:(NSString *)adUnitID {
    if (self = [super initWithAdUnitID:adUnitID]) {
        _delegateDispatcher = [[OguryAdsOptinVideoDelegateDispatcher alloc] init];
        _internalAPI = [[OGAOptinVideoAdInternalAPI alloc] initWithAdUnitId:adUnitID
                                                         delegateDispatcher:_delegateDispatcher
                                                                  mediation:nil];
    }

    return self;
}

#pragma mark - Properties

- (id<OguryAdsOptinVideoDelegate>)optInVideoDelegate {
    return self.delegateDispatcher.delegate;
}

- (void)setOptInVideoDelegate:(id<OguryAdsOptinVideoDelegate>)optInVideoDelegate {
    self.delegateDispatcher.delegate = optInVideoDelegate;
}

- (NSString *)userId {
    return self.internalAPI.userId;
}

- (void)setUserId:(NSString *)userId {
    self.internalAPI.userId = userId;
}

#pragma mark - Methods

- (void)load {
    [self loadWithCampaignId:nil];
}

// Private method to load with a specific campaign.
- (void)load:(OguryAdsADType)adType campaignID:(NSString *)campaignID adUnitID:(NSString *)adUnitID userID:(NSString *)userID {
    self.adUnitID = adUnitID;
    self.userId = userID;
    [self loadWithCampaignId:campaignID];
}

- (void)loadWithCampaignId:(NSString *)campaignId {
    if (!self.adUnitID || [self.adUnitID isEqualToString:@""]) {
        self.adUnitID = [NSString stringWithFormat:@"%@_default", OGAAssetKeyManager.shared.assetKey];
    }
    // Handle the case where we can mutate the ad unit id after the creation of the instance.
    if (self.internalAPI.adUnitId != self.adUnitID) {
        self.internalAPI = [[OGAOptinVideoAdInternalAPI alloc] initWithAdUnitId:self.adUnitID
                                                             delegateDispatcher:self.delegateDispatcher
                                                                      mediation:nil];
    }
    if (campaignId) {
        [self.internalAPI loadWithCampaignId:campaignId];
    } else {
        [self.internalAPI load];
    }
}

@end

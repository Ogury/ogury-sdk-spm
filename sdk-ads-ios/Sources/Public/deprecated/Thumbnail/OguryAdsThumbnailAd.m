//
//  Copyright © 2019 Ogury Ltd. All rights reserved.
//

#import "OguryAdsThumbnailAd.h"

#import "OGAAdConfiguration.h"
#import "OguryAdsThumbnailAdDelegateDispatcher.h"
#import "OGAThumbnailAdInternalAPI.h"
#import "OGAAssetKeyManager.h"
#import "OGAThumbnailAdConstants.h"

@interface OguryAdsThumbnailAd ()

@property(nonatomic, strong) OguryAdsThumbnailAdDelegateDispatcher *delegateDispatcher;
@property(nonatomic, strong, nullable) OGAThumbnailAdInternalAPI *internalAPI;

@property(nonatomic, assign) CGSize thumbnailSize;

@end

@implementation OguryAdsThumbnailAd

#pragma mark - Initialization

- (instancetype)init {
    return [self initWithAdUnitID:nil];
}

- (instancetype)initWithAdUnitID:(NSString *_Nullable)adUnitID {
    OguryAdsThumbnailAdDelegateDispatcher *delegateDispatcher = [[OguryAdsThumbnailAdDelegateDispatcher alloc] init];
    return [self initWithAdUnitID:adUnitID
                      internalAPI:[[OGAThumbnailAdInternalAPI alloc] initWithAdUnitId:adUnitID
                                                                   delegateDispatcher:delegateDispatcher
                                                                            mediation:nil]
               delegateDispatcher:delegateDispatcher];
}

- (instancetype)initWithAdUnitID:(NSString *_Nullable)adUnitID
                     internalAPI:(OGAThumbnailAdInternalAPI *)internalAPI
              delegateDispatcher:(OguryAdsThumbnailAdDelegateDispatcher *)delegateDispatcher {
    if (self = [super init]) {
        _delegateDispatcher = delegateDispatcher;
        _adUnitID = adUnitID;
        _internalAPI = internalAPI;
    }
    return self;
}

#pragma mark - Properties

- (id<OguryAdsThumbnailAdDelegate>)thumbnailAdDelegate {
    return self.delegateDispatcher.delegate;
}

- (void)setThumbnailAdDelegate:(id<OguryAdsThumbnailAdDelegate>)thumbnailAdDelegate {
    self.delegateDispatcher.delegate = thumbnailAdDelegate;
}

#pragma mark - Public

// Private method to load with a specific campaign.
- (void)load:(OguryAdsADType)adType campaignID:(NSString *)campaignID adUnitID:(NSString *)adUnitID thumbnailSize:(CGSize)thumbnailSize {
    self.adUnitID = adUnitID;
    [self loadWithCampaignId:campaignID thumbnailSize:thumbnailSize];
}

// Private method to load with a specific campaign.
- (void)load:(OguryAdsADType)adType campaignID:(NSString *)campaignID adUnitID:(NSString *)adUnitID {
    self.adUnitID = adUnitID;
    [self loadWithCampaignId:campaignID thumbnailSize:[self defaultThumbnailSize]];
}

- (void)loadWithCampaignId:(NSString *)campaignId thumbnailSize:(CGSize)thumbnailSize {
    if (!self.adUnitID || [self.adUnitID isEqualToString:@""]) {
        self.adUnitID = [NSString stringWithFormat:@"%@_default", OGAAssetKeyManager.shared.assetKey];
    }
    // Handle the case where we can mutate the ad unit id after the creation of the instance.
    if (self.internalAPI.adUnitId != self.adUnitID) {
        self.internalAPI = [[OGAThumbnailAdInternalAPI alloc] initWithAdUnitId:self.adUnitID
                                                            delegateDispatcher:self.delegateDispatcher
                                                                     mediation:nil];
    }
    if (campaignId) {
        [self.internalAPI loadWithCampaignId:campaignId];
    } else {
        [self.internalAPI load];
    }
}

- (void)load:(CGSize)thumbnailSize {
    [self loadWithCampaignId:nil thumbnailSize:thumbnailSize];
}

- (void)load {
    [self load:[self defaultThumbnailSize]];
}

- (CGSize)defaultThumbnailSize {
    return CGSizeMake(OGAThumbnailDefaultWidth, OGAThumbnailDefaultHeight);
}

- (void)show:(CGPoint)position {
    [self showWithOguryRectCorner:OguryTopLeft margin:OguryOffsetMake(position.x, position.y)];
}

- (void)showWithOguryRectCorner:(OguryRectCorner)rectCorner margin:(OguryOffset)offset {
    [self.internalAPI showWithOguryRectCorner:rectCorner margin:offset];
}

- (void)show {
    OguryOffset offset = OguryOffsetMake(OGAThumbnailDefaultXOffset, OGAThumbnailDefaultYOffset);
    [self showWithOguryRectCorner:OguryBottomRight margin:offset];
}

#pragma clang diagnostic push
#pragma ide diagnostic ignored "UnavailableInDeploymentTarget"

- (void)showInScene:(UIWindowScene *)scene atPosition:(CGPoint)position {
    [self showInScene:scene withOguryRectCorner:OguryTopLeft margin:OguryOffsetMake(position.x, position.y)];
}

- (void)showInScene:(UIWindowScene *)scene {
    OguryOffset offset = OguryOffsetMake(OGAThumbnailDefaultXOffset, OGAThumbnailDefaultYOffset);
    [self showInScene:scene withOguryRectCorner:OguryTopLeft margin:offset];
}

- (void)showInScene:(UIWindowScene *)scene withOguryRectCorner:(OguryRectCorner)rectCorner margin:(OguryOffset)offset {
    [self.internalAPI showInScene:scene withOguryRectCorner:rectCorner margin:offset];
}

#pragma clang diagnostic pop

- (void)setBlacklistViewControllers:(NSArray<NSString *> *)viewControllers {
    [self.internalAPI setBlacklistViewControllers:viewControllers];
}

- (void)setWhitelistBundleIdentifiers:(NSArray<NSString *> *)bundleIdentifiers {
    [self.internalAPI setWhitelistBundleIdentifiers:bundleIdentifiers];
}

- (BOOL)isLoaded {
    return [self.internalAPI isLoaded];
}

- (BOOL)isExpanded {
    return [self.internalAPI isExpanded];
}

@end

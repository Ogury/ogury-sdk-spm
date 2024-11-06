//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OguryThumbnailAd.h"
#import "OGAAdConfiguration.h"
#import "OGAThumbnailAdInternalAPI.h"
#import "OguryThumbnailAdDelegateDispatcher.h"
#import "UIViewController+OGAThumbnailAdRestrictions.h"

@interface OguryThumbnailAd ()

#pragma mark - Properties

@property(nonatomic, strong) OguryThumbnailAdDelegateDispatcher *delegateDispatcher;
@property(nonatomic, strong) OGAThumbnailAdInternalAPI *internalAPI;
- (void)setLogOrigin:(NSString *)origin;
- (OGAAdConfiguration *)adConfiguration;

@end

@implementation OguryThumbnailAd

#pragma mark - Initialization

- (instancetype)initWithAdUnitId:(NSString *_Nonnull)adUnitId mediation:(OguryMediation *_Nonnull)mediation {
    return [self initWithInternalAPI:[[OGAThumbnailAdInternalAPI alloc] initWithAdUnitId:adUnitId
                                                                      delegateDispatcher:[[OguryThumbnailAdDelegateDispatcher alloc] init]
                                                                               mediation:mediation]];
}

- (instancetype)initWithAdUnitId:(NSString *_Nonnull)adUnitId {
    return [self initWithInternalAPI:[[OGAThumbnailAdInternalAPI alloc] initWithAdUnitId:adUnitId
                                                                      delegateDispatcher:[[OguryThumbnailAdDelegateDispatcher alloc] init]
                                                                               mediation:nil]];
}

- (instancetype)initWithInternalAPI:(OGAThumbnailAdInternalAPI *_Nonnull)internalAPI {
    [UIViewController doThumbnailSwizzling];
    if (self = [super init]) {
        _internalAPI = internalAPI;
        _delegateDispatcher = (OguryThumbnailAdDelegateDispatcher *)internalAPI.delegateDispatcher;
        _delegateDispatcher.thumbnail = self;
    }
    return self;
}

#pragma mark - Properties

- (NSString *)adUnitId {
    return self.internalAPI.adUnitId;
}

- (id<OguryThumbnailAdDelegate>)delegate {
    return self.delegateDispatcher.delegate;
}

- (void)setDelegate:(id<OguryThumbnailAdDelegate>)delegate {
    self.delegateDispatcher.delegate = delegate;
}

- (BOOL)isExpanded {
    return self.internalAPI.isExpanded;
}

- (void)setScene:(UIWindowScene *)scene {
    self.internalAPI.scene = scene;
}

#pragma mark - Public Methods

- (void)load {
    [self.internalAPI load];
}

- (void)loadWithMaxSize:(CGSize)thumbnailSize {
    [self.internalAPI loadWithMaxSize:thumbnailSize];
}

- (BOOL)isLoaded {
    return [self.internalAPI isLoaded];
}

- (void)loadWithCampaignId:(NSString *)campaignId {
    [self.internalAPI loadWithCampaignId:campaignId];
}

- (void)loadWithCampaignId:(NSString *)campaignId creativeId:(NSString *)creativeId {
    [self.internalAPI loadWithCampaignId:campaignId creativeId:creativeId];
}

- (void)loadWithCampaignId:(NSString *)campaignId creativeId:(NSString *)creativeId dspCreativeId:(NSString *)dspCreativeId dspRegion:(NSString *)dspRegion {
    [self.internalAPI loadWithCampaignId:campaignId creativeId:creativeId dspCreativeId:dspCreativeId dspRegion:dspRegion];
}

- (void)loadWithCampaignId:(NSString *)campaignId thumbnailSize:(CGSize)thumbnailSize {
    [self.internalAPI loadWithCampaignId:campaignId thumbnailSize:thumbnailSize];
}

- (void)loadWithCampaignId:(NSString *)campaignId creativeId:(NSString *)creativeId thumbnailSize:(CGSize)thumbnailSize {
    [self.internalAPI loadWithCampaignId:campaignId creativeId:creativeId thumbnailSize:thumbnailSize];
}

- (void)loadWithCampaignId:(NSString *)campaignId creativeId:(NSString *)creativeId dspCreativeId:(NSString *)dspCreativeId dspRegion:(NSString *)dspRegion thumbnailSize:(CGSize)thumbnailSize {
    [self.internalAPI loadWithCampaignId:campaignId creativeId:creativeId dspCreativeId:dspCreativeId dspRegion:dspRegion thumbnailSize:thumbnailSize];
}

- (void)show {
    [self.internalAPI show];
}

- (void)showAt:(CGPoint)position {
    [self.internalAPI show:position];
}

- (void)showWithOguryRectCorner:(OguryRectCorner)rectCorner offset:(OguryOffset)offset {
    [self.internalAPI showWithOguryRectCorner:rectCorner margin:offset];
}

- (void)setBlacklistViewControllers:(NSArray<NSString *> *_Nullable)viewControllers {
    [self.internalAPI setBlacklistViewControllers:viewControllers];
}

- (void)setWhitelistBundleIdentifiers:(NSArray<NSString *> *_Nullable)bundleIdentifiers {
    [self.internalAPI setWhitelistBundleIdentifiers:bundleIdentifiers];
}

- (void)setLogOrigin:(NSString *)origin {
    [self.internalAPI setLogOrigin:origin];
}

- (OGAAdConfiguration *)adConfiguration {
    return self.internalAPI.adConfiguration;
}

@end

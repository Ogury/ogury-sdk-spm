//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OGAAdInternalAPI.h"
#import "OGADelegateDispatcher.h"
#import "OguryRectCorner.h"
#import "OguryOffset.h"
#import "OguryMediation.h"

NS_ASSUME_NONNULL_BEGIN

@class OGAAdConfiguration;

@interface OGAThumbnailAdInternalAPI : NSObject <OGAAdInternalAPI>

#pragma mark - properties

@property(nonatomic, strong) OGADelegateDispatcher *delegateDispatcher;

@property(nonatomic, assign, readonly) BOOL isExpanded;
@property(nonatomic, assign, readonly) BOOL isLoaded;
@property(nonatomic, assign) UIWindowScene *scene API_AVAILABLE(ios(13.0));

#pragma mark - Initialization

- (instancetype)initWithAdUnitId:(NSString *)adUnitId
              delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher
                       mediation:(OguryMediation *_Nullable)mediation;

#pragma mark - Methods

- (void)load;

- (void)loadWithMaxSize:(CGSize)thumbnailSize;

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId;

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId creativeId:(NSString *_Nullable)creativeId;

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId creativeId:(NSString *_Nullable)creativeId dspCreativeId:(NSString *_Nullable)dspCreativeId dspRegion:(NSString *_Nullable)dspRegion;

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId thumbnailSize:(CGSize)thumbnailSize;

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId creativeId:(NSString *_Nullable)creativeId thumbnailSize:(CGSize)thumbnailSize;

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId creativeId:(NSString *_Nullable)creativeId dspCreativeId:(NSString *_Nullable)dspCreativeId dspRegion:(NSString *_Nullable)dspRegion thumbnailSize:(CGSize)thumbnailSize;

- (void)show;

- (void)show:(CGPoint)position;

- (void)showWithOguryRectCorner:(OguryRectCorner)rectCorner margin:(OguryOffset)offset;

- (void)setBlacklistViewControllers:(NSArray<NSString *> *_Nullable)viewControllers;

- (void)setWhitelistBundleIdentifiers:(NSArray<NSString *> *_Nullable)bundleIdentifiers;

- (void)setLogOrigin:(NSString *)origin;
- (OGAAdConfiguration *)adConfiguration;

@end

NS_ASSUME_NONNULL_END

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

@interface OGAThumbnailAdInternalAPI : NSObject <OGAAdInternalAPI>

#pragma mark - properties

@property(nonatomic, strong) OGADelegateDispatcher *delegateDispatcher;

@property(nonatomic, assign, readonly) BOOL isExpanded;

#pragma mark - Initialization

- (instancetype)initWithAdUnitId:(NSString *)adUnitId
              delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher
                       mediation:(OguryMediation *_Nullable)mediation;

#pragma mark - Methods

- (void)load;

- (void)load:(CGSize)thumbnailSize;

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId;

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId creativeId:(NSString *_Nullable)creativeId;

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId creativeId:(NSString *_Nullable)creativeId dspCreativeId:(NSString *_Nullable)dspCreativeId dspRegion:(NSString *_Nullable)dspRegion;

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId thumbnailSize:(CGSize)thumbnailSize;

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId creativeId:(NSString *_Nullable)creativeId thumbnailSize:(CGSize)thumbnailSize;

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId creativeId:(NSString *_Nullable)creativeId dspCreativeId:(NSString *_Nullable)dspCreativeId dspRegion:(NSString *_Nullable)dspRegion thumbnailSize:(CGSize)thumbnailSize;

- (BOOL)isLoaded;

- (void)show;

- (void)show:(CGPoint)position;

- (void)showWithOguryRectCorner:(OguryRectCorner)rectCorner margin:(OguryOffset)offset;

- (void)showInScene:(UIWindowScene *)scene atPosition:(CGPoint)position API_AVAILABLE(ios(13.0));

- (void)showInScene:(UIWindowScene *)scene API_AVAILABLE(ios(13.0));

- (void)showInScene:(UIWindowScene *)scene withOguryRectCorner:(OguryRectCorner)rectCorner margin:(OguryOffset)offset API_AVAILABLE(ios(13.0));

- (void)setBlacklistViewControllers:(NSArray<NSString *> *_Nullable)viewControllers;

- (void)setWhitelistBundleIdentifiers:(NSArray<NSString *> *_Nullable)bundleIdentifiers;

@end

NS_ASSUME_NONNULL_END

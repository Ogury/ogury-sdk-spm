//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OguryThumbnailAdDelegate.h"
#import <UIKit/UIKit.h>
#import "OguryRectCorner.h"
#import "OguryOffset.h"
#import "OguryMediation.h"

NS_ASSUME_NONNULL_BEGIN

@interface OguryThumbnailAd : NSObject

@property(nonatomic, strong, readonly) NSString *adUnitId;
@property(nonatomic, weak, nullable) id<OguryThumbnailAdDelegate> delegate;
@property(nonatomic, assign, readonly) BOOL isExpanded;
@property(nonatomic, assign, readonly) BOOL isLoaded;
@property(nonatomic, assign) UIWindowScene *scene API_AVAILABLE(ios(13.0));

- (instancetype)initWithAdUnitId:(NSString *_Nonnull)adUnitId;
- (instancetype)initWithAdUnitId:(NSString *)adUnitId mediation:(OguryMediation *_Nonnull)mediation;

#pragma mark - Methods

- (void)load;

- (void)loadWithMaxSize:(CGSize)thumbnailSize;

- (void)show;

- (void)showAt:(CGPoint)position;

- (void)showWithOguryRectCorner:(OguryRectCorner)rectCorner offset:(OguryOffset)offset;

- (void)setBlacklistViewControllers:(NSArray<NSString *> *_Nullable)viewControllers;

- (void)setWhitelistBundleIdentifiers:(NSArray<NSString *> *_Nullable)bundleIdentifiers;

@end

NS_ASSUME_NONNULL_END

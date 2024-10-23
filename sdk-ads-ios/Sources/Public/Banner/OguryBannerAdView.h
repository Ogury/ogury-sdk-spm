//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OguryBannerAdViewDelegate.h"
#import "OguryBannerAdSize.h"
#import "OguryMediation.h"

NS_ASSUME_NONNULL_BEGIN

@interface OguryBannerAdView : UIView

#pragma mark - Properties

@property(nonatomic, strong, readonly) NSString *adUnitId;
@property(nonatomic, weak, nullable) id<OguryBannerAdViewDelegate> delegate;
@property(nonatomic, assign, readonly) BOOL isExpanded;
@property(nonatomic, assign, readonly) BOOL isLoaded;

#pragma mark - Initialization

- (instancetype)initWithAdUnitId:(NSString *)adUnitId size:(OguryBannerAdSize *)size;
- (instancetype)initWithAdUnitId:(NSString *)adUnitId size:(OguryBannerAdSize *)size mediation:(OguryMediation *_Nonnull)mediation;

#pragma mark - Methods

- (void)load;

- (void)loadWithAdMarkup:(NSString *)adMarkup;

- (void)destroy;

@end

NS_ASSUME_NONNULL_END

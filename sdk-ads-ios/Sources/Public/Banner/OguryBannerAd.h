//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OguryBannerAdDelegate.h"
#import "OguryAdsBannerSize.h"
#import "OguryMediation.h"

NS_ASSUME_NONNULL_BEGIN

@interface OguryBannerAd : UIView

#pragma mark - Properties

@property(nonatomic, strong, readonly) NSString *adUnitId;
@property(nonatomic, weak, nullable) id<OguryBannerAdDelegate> delegate;
@property(nonatomic, assign, readonly) BOOL isExpanded;

#pragma mark - Initialization

- (instancetype)initWithAdUnitId:(NSString *)adUnitId size:(OguryAdsBannerSize *)size;
- (instancetype)initWithAdUnitId:(NSString *)adUnitId size:(OguryAdsBannerSize *)size mediation:(OguryMediation *_Nonnull)mediation;

#pragma mark - Methods

- (void)load;

- (void)loadWithAdMarkup:(NSString *)adMarkup;

- (void)destroy;

- (BOOL)isLoaded;

@end

NS_ASSUME_NONNULL_END

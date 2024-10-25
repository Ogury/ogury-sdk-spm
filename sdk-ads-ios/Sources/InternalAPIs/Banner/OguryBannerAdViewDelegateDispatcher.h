//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import "OGADelegateDispatcher.h"
#import "OguryBannerAdViewDelegate.h"
#import "OGAAdDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface OguryBannerAdViewDelegateDispatcher : OGADelegateDispatcher <id <OguryBannerAdViewDelegate>>

#pragma mark - Properties

@property(nonatomic, weak, nullable) OguryBannerAdView *banner;

@end

NS_ASSUME_NONNULL_END

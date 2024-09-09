//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import "OGADelegateDispatcher.h"
#import "OguryBannerAdDelegate.h"
#import "OGAAdDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface OguryBannerAdDelegateDispatcher : OGADelegateDispatcher <id <OguryBannerAdDelegate>>

#pragma mark - Properties

@property(nonatomic, weak, nullable) OguryBannerAd *banner;

@end

NS_ASSUME_NONNULL_END

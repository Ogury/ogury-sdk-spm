//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import "OguryAdsDelegate.h"
#import "OGADelegateDispatcher.h"
#import "OguryAdsBanner.h"

NS_ASSUME_NONNULL_BEGIN

@interface OguryAdsBannerDelegateDispatcher : OGADelegateDispatcher <id <OguryAdsBannerDelegate>>

#pragma mark - Properties

@property(nonatomic, weak, nullable) OguryAdsBanner *banner;

@end

NS_ASSUME_NONNULL_END

//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGADelegateDispatcher.h"
#import "OguryAds/OguryRewardedAdDelegate.h"
#import "OGAAdDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface OguryRewardedAdDelegateDispatcher : OGADelegateDispatcher <id <OguryRewardedAdDelegate>>

@property(nonatomic, strong, nullable) OguryRewardedAd *optinVideo;

@end

NS_ASSUME_NONNULL_END

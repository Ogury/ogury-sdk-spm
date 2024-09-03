//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import "OGADelegateDispatcher.h"
#import "OguryAds/OguryInterstitialAdDelegate.h"
#import "OGAAdDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface OguryInterstitialAdDelegateDispatcher : OGADelegateDispatcher <id <OguryInterstitialAdDelegate>>

@property(nonatomic, weak, nullable) OguryInterstitialAd *interstitial;

@end

NS_ASSUME_NONNULL_END

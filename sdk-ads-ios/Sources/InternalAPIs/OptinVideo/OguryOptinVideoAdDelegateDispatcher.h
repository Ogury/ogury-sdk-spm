//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGADelegateDispatcher.h"
#import "OguryAds/OguryOptinVideoAdDelegate.h"
#import "OGAAdDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface OguryOptinVideoAdDelegateDispatcher : OGADelegateDispatcher <id <OguryOptinVideoAdDelegate>>

@property(nonatomic, strong, nullable) OguryOptinVideoAd *optinVideo;

@end

NS_ASSUME_NONNULL_END

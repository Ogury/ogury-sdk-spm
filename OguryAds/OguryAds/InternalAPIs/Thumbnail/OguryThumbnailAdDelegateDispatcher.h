//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryThumbnailAd.h"
#import "OGADelegateDispatcher.h"

NS_ASSUME_NONNULL_BEGIN

@interface OguryThumbnailAdDelegateDispatcher : OGADelegateDispatcher <id <OguryThumbnailAdDelegate>>

@property(nonatomic, strong) OguryThumbnailAd *_Nullable thumbnail;

@end

NS_ASSUME_NONNULL_END

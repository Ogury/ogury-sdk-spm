//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "OguryAdError.h"

NS_ASSUME_NONNULL_BEGIN

@class OguryThumbnailAd;

@protocol OguryThumbnailAdDelegate <NSObject>
@optional
- (void)thumbnailAdDidLoad:(OguryThumbnailAd *)thumbnailAd NS_SWIFT_NAME(thumbnailAdDidLoad(_:));
- (void)thumbnailAdDidClick:(OguryThumbnailAd *)thumbnailAd NS_SWIFT_NAME(thumbnailAdDidClick(_:));
- (void)thumbnailAdDidClose:(OguryThumbnailAd *)thumbnailAd NS_SWIFT_NAME(thumbnailAdDidClose(_:));
- (void)thumbnailAd:(OguryThumbnailAd *)thumbnailAd didFailWithError:(OguryAdError *)error NS_SWIFT_NAME(thumbnailAd(_:didFailWithError:));
- (void)thumbnailAdDidTriggerImpression:(OguryThumbnailAd *)thumbnailAd NS_SWIFT_NAME(thumbnailAdDidTriggerImpression(_:));
@end

NS_ASSUME_NONNULL_END

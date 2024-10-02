//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "OguryAdError.h"

NS_ASSUME_NONNULL_BEGIN

@class OguryThumbnailAd;

@protocol OguryThumbnailAdDelegate <NSObject>
@optional
- (void)oguryThumbnailAdDidLoad:(OguryThumbnailAd *)thumbnail;
- (void)oguryThumbnailAdDidClick:(OguryThumbnailAd *)thumbnail;
- (void)oguryThumbnailAdDidClose:(OguryThumbnailAd *)thumbnail;
- (void)oguryThumbnailAd:(OguryThumbnailAd *)thumbnail didFailWithError:(OguryAdError *)error;
- (void)oguryThumbnailAdDidTriggerImpression:(OguryThumbnailAd *)thumbnail;
@end

NS_ASSUME_NONNULL_END

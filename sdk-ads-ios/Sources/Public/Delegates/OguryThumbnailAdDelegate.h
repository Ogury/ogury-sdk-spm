//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "OguryAdError.h"

NS_ASSUME_NONNULL_BEGIN

@class OguryThumbnailAd;

@protocol OguryThumbnailAdDelegate <NSObject>
@optional
- (void)didLoadOguryThumbnailAd:(OguryThumbnailAd *)thumbnail;
- (void)didClickOguryThumbnailAd:(OguryThumbnailAd *)thumbnail;
- (void)didCloseOguryThumbnailAd:(OguryThumbnailAd *)thumbnail;
- (void)didFailOguryThumbnailAd:(OguryThumbnailAd *)thumbnail error:(OguryAdError *)error;
- (void)didTriggerImpressionOguryThumbnailAd:(OguryThumbnailAd *)thumbnail;
@end

NS_ASSUME_NONNULL_END

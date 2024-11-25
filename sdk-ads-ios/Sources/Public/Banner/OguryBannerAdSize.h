#import <CoreGraphics/CGGeometry.h>

NS_ASSUME_NONNULL_BEGIN

@interface OguryBannerAdSize : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (CGSize)getSize;

+ (OguryBannerAdSize *)small_banner_320x50;

+ (OguryBannerAdSize *)mrec_300x250;

@end

NS_ASSUME_NONNULL_END

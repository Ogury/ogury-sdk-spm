//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OGAAd.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdLandingPagePrefetcher : NSObject

#pragma mark - Properties

@property(class, nonatomic, strong, readonly) OGAAdLandingPagePrefetcher *shared;

#pragma mark - Initialization

- (instancetype)init NS_UNAVAILABLE;

#pragma mark - Methods

- (void)prefetchLandingPageForAd:(OGAAd *)ad;

- (UIView *_Nullable)landingPageForAd:(OGAAd *)ad;

- (void)clearLandingPageForAd:(OGAAd *)ad;

@end

NS_ASSUME_NONNULL_END

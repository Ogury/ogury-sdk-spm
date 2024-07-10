//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGAAdContainerTransition.h"
#import "OGAAdContainerBuilder.h"

@class OGAAdConfiguration;
@protocol OGAAdContainerState;

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdControllerFactory (Testing)

#pragma mark - Methods

- (void)addTransitionsForAd:(OGAAd *)ad configuration:(OGAAdConfiguration *)configuration builder:(OGAAdContainerBuilder *)builder;

- (void)addTransitionsForFullscreenAd:(OGAAd *)ad configuration:(OGAAdConfiguration *)configuration builder:(OGAAdContainerBuilder *)builder;

- (void)addTransitionsForBannerAd:(OGAAd *)ad configuration:(OGAAdConfiguration *)configuration builder:(OGAAdContainerBuilder *)builder;

- (void)addTransitionsForThumbnailAd:(OGAAd *)ad configuration:(OGAAdConfiguration *)configuration builder:(OGAAdContainerBuilder *)builder;

- (void)addTransitionsForWindowedFullscreenAd:(OGAAd *)ad configuration:(OGAAdConfiguration *)configuration builder:(OGAAdContainerBuilder *)builder;

@end

NS_ASSUME_NONNULL_END

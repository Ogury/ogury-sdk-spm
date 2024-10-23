//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGAAd.h"
#import "OGANextAd.h"
#import "OGAAdDisplayerDelegate.h"

@class OGAAdController;

NS_ASSUME_NONNULL_BEGIN

@protocol OGAAdControllerDelegate <NSObject>

#pragma mark - Methods

- (void)controller:(OGAAdController *)controller didLoadAd:(OGAAd *)ad;

- (void)controller:(OGAAdController *)controller didUnLoadAd:(OGAAd *)ad origin:(UnloadOrigin)unloadOrigin;

- (void)controller:(OGAAdController *)controller webkitProcessDidTerminateForAd:(OGAAd *)ad;

- (void)controller:(OGAAdController *)controller didOpenOverlayForAd:(OGAAd *)ad;

- (void)controller:(OGAAdController *)controller didCloseOverlayForAd:(OGAAd *)ad;

- (void)controller:(OGAAdController *)controller didCloseWithNextAd:(OGANextAd *_Nullable)nextAd;

- (void)controller:(OGAAdController *)controller didUnLoadWithNextAd:(OGANextAd *_Nullable)nextAd;

@end

NS_ASSUME_NONNULL_END

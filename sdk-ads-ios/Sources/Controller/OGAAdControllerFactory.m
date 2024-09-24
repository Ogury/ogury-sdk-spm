//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAAdControllerFactory.h"
#import "OGAAdConfiguration.h"
#import "OGAAdManager.h"
#import "OGAAdSequence.h"
#import "OGAAdController.h"
#import "OGAAdSequenceCoordinator.h"
#import "OGAMRAIDAdDisplayer.h"
#import "OGAAdContainer.h"
#import "OGAInitialAdContainerState.h"
#import "OGABannerAdContainerState.h"
#import "OGAClosedAdContainerState.h"
#import "OGAFullscreenAdContainerState.h"
#import "OGAThumbnailAdContainerState.h"
#import "OGABasicAdContainerTransition.h"
#import "OGABannerToFullscreenAdContainerTransition.h"
#import "OGAFullscreenToBannerAdContainerTransition.h"
#import "OGAFullscreenToThumbnailAdContainerTransition.h"
#import "OGAThumbnailToFullscreenAdContainerTransition.h"
#import "OGAOpenSKAdContainerTransition.h"
#import "OGACloseSKAdContainerTransition.h"
#import "OGACloseSKAdToFullscreenAdContainerTransition.h"
#import "OGAShowAdAction.h"
#import "OGACloseAdAction.h"
#import "OGAUnloadAdAction.h"
#import "OGAExpandAdAction.h"
#import "OGAOpenStoreKitAction.h"
#import "OGACloseSKAction.h"
#import "OGAWindowedFullscreenAdContainerState.h"
#import "OGAStoreKitState.h"
#import "OGAAdContainerBuilder.h"
#import "OGASKOverlayState.h"
#import "OGAOpenStoreKitAction.h"
#import "OGAOpenSKOverlayAction.h"
#import "OGACloseSKAdToCloseTransition.h"

@implementation OGAAdControllerFactory

#pragma mark - Methods

- (void)createControllersForSequence:(OGAAdSequence *)sequence ads:(NSArray<OGAAd *> *)ads configuration:(OGAAdConfiguration *)configuration {
    [self createControllersForSequence:sequence ads:ads configuration:configuration adManager:[OGAAdManager sharedManager]];
}

- (void)createControllersForSequence:(OGAAdSequence *)sequence ads:(NSArray<OGAAd *> *)ads configuration:(OGAAdConfiguration *)configuration adManager:(OGAAdManager *)adManager {
    NSMutableArray<OGAAdController *> *controllers = [NSMutableArray array];

    for (OGAAd *currentAd in ads) {
        [controllers addObject:[self createControllerForAd:currentAd sequence:sequence configuration:configuration]];
    }

    sequence.coordinator = [[OGAAdSequenceCoordinator alloc] initWithSequence:sequence adControllers:controllers];
}

- (OGAAdController *)createControllerForAd:(OGAAd *)ad sequence:(OGAAdSequence *)sequence configuration:(OGAAdConfiguration *)configuration {
    OGAMRAIDAdDisplayer *displayer = [[OGAMRAIDAdDisplayer alloc] initWithAd:ad adConfiguration:configuration];

    OGAAdContainerBuilder *builder = [[OGAAdContainerBuilder alloc] initWithDisplayer:displayer];
    [self addTransitionsForAd:ad configuration:configuration builder:builder];

    OGAAdController *controller = [[OGAAdController alloc] initWithAd:ad configuration:configuration displayer:displayer container:[builder build]];
    if (ad.expirationTime == nil) {
        controller.expirationContext = sequence.configuration.expirationContext;
    } else {
        controller.expirationContext = [[OGAExpirationContext alloc] initFrom:OGAdExpirationSourceAd withExpirationTime:ad.expirationTime];
    }

    return controller;
}

- (void)addTransitionsForAd:(OGAAd *)ad configuration:(OGAAdConfiguration *)configuration builder:(OGAAdContainerBuilder *)builder {
    switch (configuration.adType) {
        case OguryAdsTypeInterstitial:
        case OguryAdsTypeRewardedAd:
            [self addTransitionsForFullscreenAd:ad configuration:configuration builder:builder];
            break;
        case OguryAdsTypeBanner: {
            if (!ad.bannerAdResponse) {
                [self addTransitionsForFullscreenAd:ad configuration:configuration builder:builder];
            } else {
                [self addTransitionsForBannerAd:ad configuration:configuration builder:builder];
            }
            break;
        }
        case OguryAdsTypeThumbnailAd: {
            if (!ad.thumbnailAdResponse) {
                [self addTransitionsForWindowedFullscreenAd:ad configuration:configuration builder:builder];
            } else {
                [self addTransitionsForThumbnailAd:ad configuration:configuration builder:builder];
            }
            break;
        }
    }
}

- (void)addTransitionsForFullscreenAd:(OGAAd *)ad configuration:(OGAAdConfiguration *)configuration builder:(OGAAdContainerBuilder *)builder {
    OGAFullscreenAdContainerState *fullscreenState = [[OGAFullscreenAdContainerState alloc] initWithViewControllerProvider:configuration.viewControllerProvider];
    OGASKOverlayState *skOverlayState = [[OGASKOverlayState alloc] initWithAd:ad viewControllerProvider:configuration.viewControllerProvider];
    OGAStoreKitState *storeKitState = [[OGAStoreKitState alloc] initWithAd:ad viewControllerProvider:configuration.viewControllerProvider];

    [builder addBasicTransitionWithAction:OGACloseAdActionName initialState:builder.initialState finalState:builder.closedState];
    [builder addBasicTransitionWithAction:OGAUnloadAdActionName initialState:builder.initialState finalState:builder.closedState];
    [builder addBasicTransitionWithAction:OGAShowAdActionName initialState:builder.initialState finalState:fullscreenState];
    [builder addBasicTransitionWithAction:OGACloseAdActionName initialState:fullscreenState finalState:builder.closedState];
    [builder addBasicTransitionWithAction:OGAUnloadAdActionName initialState:fullscreenState finalState:builder.closedState];
    [builder addBasicTransitionWithAction:OGAOpenStoreKitActionName initialState:skOverlayState finalState:storeKitState];
    [builder addTransition:[[OGAOpenSKAdContainerTransition alloc] initWithAction:OGAOpenSKOverlayActionName initialState:fullscreenState finalState:skOverlayState]];
    [builder addTransition:[[OGAOpenSKAdContainerTransition alloc] initWithAction:OGAOpenStoreKitActionName initialState:fullscreenState finalState:storeKitState]];
    [builder addTransition:[[OGACloseSKAdContainerTransition alloc] initWithInitialState:skOverlayState finalState:fullscreenState]];
    [builder addTransition:[[OGACloseSKAdContainerTransition alloc] initWithInitialState:storeKitState finalState:fullscreenState]];
    [builder addTransition:[[OGACloseSKAdToFullscreenAdContainerTransition alloc] initWithInitialState:storeKitState finalState:fullscreenState]];
    [builder addTransition:[[OGACloseSKAdToFullscreenAdContainerTransition alloc] initWithInitialState:skOverlayState finalState:fullscreenState]];
    [builder addTransition:[[OGACloseSKAdToCloseTransition alloc] initWithAction:OGAUnloadAdActionName initialState:storeKitState finalState:builder.closedState]];
    [builder addTransition:[[OGACloseSKAdToCloseTransition alloc] initWithAction:OGAUnloadAdActionName initialState:skOverlayState finalState:builder.closedState]];
    [builder addTransition:[[OGACloseSKAdToCloseTransition alloc] initWithAction:OGACloseAdActionName initialState:storeKitState finalState:builder.closedState]];
    [builder addTransition:[[OGACloseSKAdToCloseTransition alloc] initWithAction:OGACloseAdActionName initialState:skOverlayState finalState:builder.closedState]];
}

- (void)addTransitionsForBannerAd:(OGAAd *)ad configuration:(OGAAdConfiguration *)configuration builder:(OGAAdContainerBuilder *)builder {
    OGABannerAdContainerState *bannerState = [[OGABannerAdContainerState alloc] initWithViewProvider:configuration.viewProvider viewControllerProvider:configuration.viewControllerProvider];
    OGAFullscreenAdContainerState *fullscreenState = [[OGAFullscreenAdContainerState alloc] initWithViewControllerProvider:configuration.viewControllerProvider];
    OGAStoreKitState *storeKitState = [[OGAStoreKitState alloc] initWithAd:ad viewControllerProvider:configuration.viewControllerProvider];

    [builder addBasicTransitionWithAction:OGACloseAdActionName initialState:builder.initialState finalState:builder.closedState];
    [builder addBasicTransitionWithAction:OGAUnloadAdActionName initialState:builder.initialState finalState:builder.closedState];
    [builder addBasicTransitionWithAction:OGAShowAdActionName initialState:builder.initialState finalState:bannerState];
    [builder addBasicTransitionWithAction:OGAUnloadAdActionName initialState:bannerState finalState:builder.closedState];
    [builder addTransition:[[OGABannerToFullscreenAdContainerTransition alloc] initWithInitialState:bannerState finalState:fullscreenState]];
    [builder addTransition:[[OGAFullscreenToBannerAdContainerTransition alloc] initWithInitialState:fullscreenState finalState:bannerState]];
    [builder addBasicTransitionWithAction:OGAUnloadAdActionName initialState:fullscreenState finalState:builder.closedState];
}

- (void)addTransitionsForThumbnailAd:(OGAAd *)ad configuration:(OGAAdConfiguration *)configuration builder:(OGAAdContainerBuilder *)builder {
    OGAThumbnailAdWindowFactory *thumbnailAdWindowFactory = [[OGAThumbnailAdWindowFactory alloc] init];
    OGAThumbnailAdContainerState *thumbnailState = [[OGAThumbnailAdContainerState alloc] initWithThumbnailAdWindowFactory:thumbnailAdWindowFactory];
    OGAWindowedFullscreenAdContainerState *fullscreenWindowState = [[OGAWindowedFullscreenAdContainerState alloc] initWithThumbnailAdWindowFactory:thumbnailAdWindowFactory];
    OGAStoreKitState *storeKitState = [[OGAStoreKitState alloc] initWithAd:ad viewControllerProvider:configuration.viewControllerProvider];

    [builder addBasicTransitionWithAction:OGACloseAdActionName initialState:builder.initialState finalState:builder.closedState];
    [builder addBasicTransitionWithAction:OGAUnloadAdActionName initialState:builder.initialState finalState:builder.closedState];
    [builder addBasicTransitionWithAction:OGAShowAdActionName initialState:builder.initialState finalState:thumbnailState];
    [builder addBasicTransitionWithAction:OGACloseAdActionName initialState:thumbnailState finalState:builder.closedState];
    [builder addBasicTransitionWithAction:OGAUnloadAdActionName initialState:thumbnailState finalState:builder.closedState];
    [builder addTransition:[[OGAThumbnailToFullscreenAdContainerTransition alloc] initWithInitialState:thumbnailState finalState:fullscreenWindowState]];
    [builder addTransition:[[OGAFullscreenToThumbnailAdContainerTransition alloc] initWithInitialState:fullscreenWindowState finalState:thumbnailState]];
    [builder addBasicTransitionWithAction:OGAUnloadAdActionName initialState:fullscreenWindowState finalState:builder.closedState];
}

// To display EULA/survey using a window since we do not have a root view controller to use the fullscreen ad.
- (void)addTransitionsForWindowedFullscreenAd:(OGAAd *)ad configuration:(OGAAdConfiguration *)configuration builder:(OGAAdContainerBuilder *)builder {
    OGAThumbnailAdWindowFactory *thumbnailAdWindowFactory = [[OGAThumbnailAdWindowFactory alloc] init];
    OGAWindowedFullscreenAdContainerState *fullscreenWindowState = [[OGAWindowedFullscreenAdContainerState alloc] initWithThumbnailAdWindowFactory:thumbnailAdWindowFactory];

    [builder addBasicTransitionWithAction:OGACloseAdActionName initialState:builder.initialState finalState:builder.closedState];
    [builder addBasicTransitionWithAction:OGAUnloadAdActionName initialState:builder.initialState finalState:builder.closedState];
    [builder addBasicTransitionWithAction:OGAShowAdActionName initialState:builder.initialState finalState:fullscreenWindowState];
    [builder addBasicTransitionWithAction:OGACloseAdActionName initialState:fullscreenWindowState finalState:builder.closedState];
    [builder addBasicTransitionWithAction:OGAUnloadAdActionName initialState:fullscreenWindowState finalState:builder.closedState];
}

@end

//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import "OGASKOverlayState.h"
#import "OguryAdsError.h"
#import "OGAAdConfiguration.h"
#import <StoreKit/StoreKit.h>
#import "OGAAdDisplayerUserCloseSKOverlayInformation.h"
#import "OGAMonitoringDispatcher+SKNetwork.h"
#import "OGASKAdNetworkService.h"
#import "OguryAdsError+Internal.h"

API_AVAILABLE(ios(14.0))
@interface OGASKOverlayState () <SKOverlayDelegate>

@property(nonatomic, strong) SKOverlay *skOverlay;
@property(nonatomic, strong) id<OGAAdDisplayer> displayer;
@property(nonatomic, strong) NSError *loadError;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) UIWindowScene *windowScene;
@property(nonatomic) BOOL shouldCloseOnDismiss;

@end

@implementation OGASKOverlayState

#pragma mark - Properties

- (NSString *)name {
    return @"SKOverlay";
}

- (OGAAdContainerStateType)type {
    return OGAAdContainerStateTypeFullScreenOverlay;
}

- (BOOL)isExpanded {
    return YES;
}

#pragma mark - Methods

- (instancetype)initWithAd:(OGAAd *)ad
    viewControllerProvider:(UIViewController * (^)(void))viewControllerProvider {
    return [self initWithAd:ad
          monitoringDispatcher:[OGAMonitoringDispatcher shared]
        viewControllerProvider:viewControllerProvider];
}

- (instancetype)initWithAd:(OGAAd *)ad
      monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher
    viewControllerProvider:(UIViewController * (^)(void))viewControllerProvider {
    self = [super
          initWithViewProvider:^UIView *_Nonnull {
              return nil;
          }
        viewControllerProvider:viewControllerProvider];
    if (self) {
        _monitoringDispatcher = monitoringDispatcher;
        if (@available(iOS 14.0, *)) {
            SKOverlayConfiguration *config = [self getSKOverlayConfiguration:ad];
            _skOverlay = [[SKOverlay alloc] initWithConfiguration:config];
            _skOverlay.delegate = self;
        }
        _shouldCloseOnDismiss = YES;
    }

    return self;
}

- (SKOverlayAppConfiguration *)getSKOverlayConfiguration:(OGAAd *)ad API_AVAILABLE(ios(14.0)) {
    OGASKAdNetworkResponse *skanResponse = ad.skAdNetworkResponse;

    if (!skanResponse) {
        return NULL;
    }
    if (!skanResponse.isStoreKitDisplay) {
        return NULL;
    }

    [self.monitoringDispatcher sendSKNetworkLoadStoreControllerEvent:OGASKNetworkLoadEventStoreViewControllerLoading
                                                               nonce:skanResponse.nonce
                                                        itunesItemId:skanResponse.itunesItemId
                                                     adConfiguration:ad.adConfiguration];
    NSDictionary *parameters = [OGASKAdNetworkService getSKParameterFrom:skanResponse];

    SKOverlayAppConfiguration *config = [[SKOverlayAppConfiguration alloc] initWithAppIdentifier:[ad.skAdNetworkResponse.itunesItemId stringValue] position:SKOverlayPositionBottom];
    for (id param in parameters) {
        [config setAdditionalValue:parameters[param] forKey:param];
    }
    return config;
}

- (BOOL)display:(nonnull id<OGAAdDisplayer>)displayer
          error:(OguryError *_Nullable *_Nullable)error {
    self.displayer = displayer;

    if (!displayer.ad.skAdNetworkResponse) {
        if (error) {
            *error = [OguryError createOguryErrorWithCode:OGAInternalUnknownError localizedDescription:@"[SKAdNetwork] Missing SKAN information to present Store Kit rendered ads."];
        }
        [self sendGenericError];
        return NO;
    }

    if (!displayer.ad.skAdNetworkResponse.isStoreKitDisplay) {
        if (error) {
            *error = [OguryError createOguryErrorWithCode:OGAInternalUnknownError localizedDescription:@"[SKAdNetwork] SKAN should not be rendered with StoreKit."];
        }
        [self sendGenericError];
        return NO;
    }

    if (@available(iOS 14.0, *)) {
        if (!self.loadError) {
            for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes) {
                self.windowScene = scene;
            }
            [self.skOverlay presentInScene:self.windowScene];
        } else {
            [displayer dispatchInformation:[[OGAAdDisplayerUserCloseSKOverlayInformation alloc] initWithErrorCode:@(self.loadError.code)]];
            *error = [OguryError createOguryErrorWithCode:OGAInternalUnknownError localizedDescription:@"[SKAdNetwork] Error during presentation of StoreKit"];
            return NO;
        }
    } else {
        *error = [OguryError createOguryErrorWithCode:OGAInternalUnknownError localizedDescription:@"[SKAdNetwork] This version of iOS is not compatible with StoreKit"];
        [self sendGenericError];
        return NO;
    }

    return YES;
}

- (void)sendGenericError {
    [self.displayer dispatchInformation:[[OGAAdDisplayerUserCloseSKOverlayInformation alloc] initWithErrorCode:@(-1)]];
}

- (void)cleanUp {
    if (@available(iOS 14.0, *)) {
        self.shouldCloseOnDismiss = NO;
        [SKOverlay dismissOverlayInScene:self.windowScene];
    }
}

- (void)forceClose {
    if (!self.viewControllerProvider) {
        [self sendGenericError];
        return;
    }
    UIViewController *rootViewController = self.viewControllerProvider();
    [self dismissPresentedAdViewController:rootViewController];
}

#pragma mark SKOverlayDelegate

- (void)storeOverlay:(SKOverlay *)overlay didFailToLoadWithError:(NSError *)error API_AVAILABLE(ios(14.0)) {
    self.loadError = error;
}

- (void)storeOverlay:(SKOverlay *)overlay willStartDismissal:(SKOverlayTransitionContext *)transitionContext API_AVAILABLE(ios(14.0)) {
    if (self.shouldCloseOnDismiss) {
        [self.displayer dispatchInformation:[[OGAAdDisplayerUserCloseSKOverlayInformation alloc] initWithErrorCode:nil]];
    }
}

@end

//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import "OGAStoreKitState.h"
#import "OguryAdsErrorType.h"
#import "OGAAdConfiguration.h"
#import <StoreKit/StoreKit.h>
#import "OGAAdDisplayerUserCloseStoreKitInformation.h"
#import "OGAFullscreenViewController.h"
#import "OGAMonitoringDispatcher+SKNetwork.h"
#import "OGASKAdNetworkService.h"
#import "OguryError+Ads.h"

@interface OGAStoreKitState () <SKStoreProductViewControllerDelegate>

@property(nonatomic, strong) SKStoreProductViewController *storeProductViewController;
@property(nonatomic, strong) id<OGAAdDisplayer> displayer;
@property(nonatomic, strong) NSError *loadError;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;

@end

@implementation OGAStoreKitState

#pragma mark - Properties

- (NSString *)name {
    return @"storekit";
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
        _storeProductViewController = [[SKStoreProductViewController alloc] init];
        _storeProductViewController.delegate = self;
        _monitoringDispatcher = monitoringDispatcher;
        [self loadStoreKitViewController:ad];
    }

    return self;
}

- (void)loadStoreKitViewController:(OGAAd *)ad {
    OGASKAdNetworkResponse *skanResponse = ad.skAdNetworkResponse;

    if (!skanResponse || !skanResponse.isStoreKitDisplay) {
        return;
    }
    [self.monitoringDispatcher sendSKNetworkLoadStoreControllerEvent:OGASKNetworkLoadEventStoreViewControllerLoading
                                                               nonce:skanResponse.nonce
                                                        itunesItemId:skanResponse.itunesItemId
                                                     adConfiguration:ad.adConfiguration];
    if (@available(iOS 14.0, *)) {
        NSDictionary *parameters = [OGASKAdNetworkService getSKParameterFrom:skanResponse];

        [self.storeProductViewController loadProductWithParameters:parameters
                                                   completionBlock:^(BOOL result, NSError *error) {
                                                       if (error) {
                                                           self.loadError = error;
                                                           [self.monitoringDispatcher sendSKNetworkFailedLoadStoreControllerEvent:OGASKNetworkLoadErrorEventFailedLoadingStoreController
                                                                                                                            nonce:skanResponse.nonce
                                                                                                                     itunesItemId:skanResponse.itunesItemId
                                                                                                                  adConfiguration:ad.adConfiguration];
                                                       } else {
                                                           [self.monitoringDispatcher sendSKNetworkLoadStoreControllerEvent:OGASKNetworkLoadEventStoreViewControllerLoaded
                                                                                                                      nonce:skanResponse.nonce
                                                                                                               itunesItemId:skanResponse.itunesItemId
                                                                                                            adConfiguration:ad.adConfiguration];
                                                       }
                                                   }];
    } else {
        [self.monitoringDispatcher sendSKNetworkLoadStoreControllerEvent:OGASKNetworkLoadEventStoreViewControllerIncompatibleIOSVersion
                                                                   nonce:skanResponse.nonce
                                                            itunesItemId:skanResponse.itunesItemId
                                                         adConfiguration:ad.adConfiguration];
    }
}

- (BOOL)display:(nonnull id<OGAAdDisplayer>)displayer
          error:(OguryError *_Nullable *_Nullable)error {
    self.displayer = displayer;

    if (!self.viewControllerProvider) {
        if (error) {
            *error = [OguryError createOguryErrorWithCode:OGAInternalUnknownError localizedDescription:@"[SKAdNetwork] Missing root view controller to present."];
        }
        [self sendGenericError];
        return NO;
    }
    UIViewController *rootViewController = self.viewControllerProvider();
    while ([rootViewController presentedViewController] != nil) {
        rootViewController = [rootViewController presentedViewController];
    }

    if (!rootViewController) {
        if (error) {
            *error = [OguryError createOguryErrorWithCode:OGAInternalUnknownError localizedDescription:@"[SKAdNetwork] Missing root view controller to present."];
        }
        [self sendGenericError];
        return NO;
    }

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
            [rootViewController presentViewController:self.storeProductViewController animated:YES completion:nil];
        } else {
            [displayer dispatchInformation:[[OGAAdDisplayerUserCloseStoreKitInformation alloc] initWithErrorCode:@(self.loadError.code)]];
            *error = [OguryError createOguryErrorWithCode:OGAInternalUnknownError localizedDescription:@"[SKAdNetwork] Error during presentation of StoreKit"];
            return NO;
        }
    } else {
        *error = [OguryError createOguryErrorWithCode:OGAInternalUnknownError localizedDescription:@"[SKAdNetwork] [SKAdNetwork] This version of iOS is not compatible with StoreKit"];
        [self sendGenericError];
        return NO;
    }

    return YES;
}

- (void)sendGenericError {
    [self.displayer dispatchInformation:[[OGAAdDisplayerUserCloseStoreKitInformation alloc] initWithErrorCode:@(-1)]];
}

- (void)cleanUp {
    [self.storeProductViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)forceClose {
    if (!self.viewControllerProvider) {
        [self sendGenericError];
        return;
    }
    UIViewController *rootViewController = self.viewControllerProvider();
    [self dismissPresentedAdViewController:rootViewController];
}

#pragma mark SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self.displayer dispatchInformation:[[OGAAdDisplayerUserCloseStoreKitInformation alloc] initWithErrorCode:nil]];
}

@end

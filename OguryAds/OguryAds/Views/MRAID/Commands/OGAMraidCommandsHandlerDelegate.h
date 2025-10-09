//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdDisplayerDelegate.h"

@class OGAMraidCommand;
@class OGAMraidAdWebView;

NS_ASSUME_NONNULL_BEGIN

@protocol OGAMraidCommandsHandlerDelegate

- (void)updateWebView:(OGAMraidCommand *)command;

- (void)executeForwardActionForWebViewId:(NSString *)webViewId;

- (void)executeBackActionForWebViewId:(NSString *)webViewId;

- (void)createWebView:(OGAMraidCommand *)command;

- (void)setUseCustomCloseButton:(BOOL)useCustomCloseButton;

- (void)closeFullAd:(OGAMraidCommand *)command;

- (void)unloadAd:(OGAMraidCommand *)command origin:(UnloadOrigin)origin;

- (void)forceClose:(OGAMraidCommand *)command;

- (void)adClicked;

- (void)rewardWasReceived;

- (void)resizeProps:(OGAMraidCommand *)command;

- (void)setOrientationProperties:(OGAMraidCommand *)command;

- (void)expand;

- (void)closeWebView:(OGAMraidCommand *)command;

- (void)adImpressionFormat;

- (void)bunaZiua;

- (void)formatDidLoadAd;

- (BOOL)mraidCommunicationIsUp;

- (void)openStoreKit:(OGAMraidCommand *)command;

- (void)openSKOverlay:(OGAMraidCommand *)command;

- (void)closeSKOverlay:(OGAMraidCommand *)command;

- (void)openUrl:(NSURL *)url;

- (void)eulaConsentStatus:(BOOL)accepted;

@end

NS_ASSUME_NONNULL_END

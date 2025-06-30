//
//  Copyright © 2018 Ogury. All rights reserved.
//

#import "OGAJavascriptCommandExecutor.h"
#import "OGADeviceService.h"
#import "OGAMraidBaseWebView.h"
#import "OGALog.h"
#import "OGAAdConfiguration.h"
#import "OGAAdExposure.h"
#import "OGAAdExposure+MRAID.h"
#import "OGAAd.h"
#import "OGAMraidLogMessage.h"

#import <AVFoundation/AVFoundation.h>

@interface OGAJavascriptCommandExecutor ()

#pragma mark - Properties

@property(nonatomic, weak) UIViewController *viewController;
@property(nonatomic, weak) WKWebView *webView;
@property(nonatomic, weak) OGAMraidBaseWebView *baseWebView;
@property(nonatomic, strong) OGALog *log;

@end

@implementation OGAJavascriptCommandExecutor

#pragma mark - Initialization

- (instancetype)initWithWebView:(OGAMraidBaseWebView *)webView {
    return [self initWithWebView:webView log:[OGALog shared]];
}

- (instancetype)initWithWebView:(OGAMraidBaseWebView *)webView log:(OGALog *)log {
    if (self = [super init]) {
        _baseWebView = webView;
        _webView = webView.wkWebView;
        _log = log;
    }

    return self;
}

#pragma mark - Methods

- (void)sendShowMraidCommandsWithExposure:(OGAAdExposure *)exposure {
    if (exposure.exposurePercentage > 0) {
        [self updateViewability:YES];
    } else {
        [self updateViewability:NO];
    }

    [self updateExposureWithAdExposure:exposure];
}

- (void)sendLoadMraidCommandsWithFrame:(CGRect)frame {
    CGSize screenSize;
    CGRect screenBounds = UIScreen.mainScreen.bounds;
    if (self.baseWebView.ad.adConfiguration.adType == OguryAdsTypeThumbnailAd || self.baseWebView.ad.adConfiguration.adType == OguryAdsTypeBanner) {
        screenSize = CGSizeMake(screenBounds.size.width, screenBounds.size.height);
    } else {
        CGFloat topPadding = [UIApplication sharedApplication].statusBarFrame.size.height;
        CGFloat bottomPadding = 0;
        if (@available(iOS 11.0, *)) {
            UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
            topPadding = window.safeAreaInsets.top;
            bottomPadding = window.safeAreaInsets.bottom;
        }
        screenSize = CGSizeMake(screenBounds.size.width, screenBounds.size.height - topPadding - bottomPadding);
    }

    CGRect defaultRect;
    if (CGRectEqualToRect(frame, CGRectZero)) {
        // Interstitital
        defaultRect = CGRectMake(self.webView.frame.origin.x, self.webView.frame.origin.y, screenSize.width, screenSize.height);
    } else {
        defaultRect = frame;
    }

    NSInteger width = defaultRect.size.width;
    NSInteger height = defaultRect.size.height;

    NSInteger xPoz = defaultRect.origin.x;
    NSInteger yPoz = defaultRect.origin.y;

    if (self.baseWebView.ad.adConfiguration.adType == OguryAdsTypeThumbnailAd || self.baseWebView.ad.adConfiguration.adType == OguryAdsTypeBanner) {
        [self updatePlacementType:@"inline"];
    } else {
        [self updatePlacementType:@"interstitial"];
    }

    [self updateViewability:FALSE];
    [self updateSupportFlags];
    [self updateSize:screenSize];
    [self updateDefaultPosition:width height:height];
    [self updateCurrentPosition:width height:height xPoz:xPoz yPoz:yPoz];
    [self updateResizeProperties:width height:height xPoz:xPoz yPoz:yPoz];
    [self updateExpandProperties:width height:height useCustomClose:NO isModal:YES];
    [self updateState:@"default"];
}

- (void)updateOrientationToSize:(CGSize)size {
    [self updateSize:size];
}

- (void)updateSize:(CGSize)size {
    NSInteger width = size.width;
    NSInteger height = size.height;

    [self updateScreenSize:width height:height];

    [self updateCurrentAppOrientation:[[[OGADeviceService alloc] init] interfaceOrientation] locked:NO];
    [self updateOrientationProperties];
    [self updateMaxSize:width height:height];

    CGRect defaultRect = CGRectMake(self.webView.frame.origin.x, self.webView.frame.origin.y, self.webView.frame.size.width, self.webView.frame.size.height);

    NSInteger widthFrame = defaultRect.size.width;
    NSInteger heightFrame = defaultRect.size.height;
    NSInteger xPoz = defaultRect.origin.x;
    NSInteger yPoz = defaultRect.origin.y;

    [self updateCurrentPosition:widthFrame height:heightFrame xPoz:xPoz yPoz:yPoz];
}

#warning TODO: Displayer // Container IF BANNER
- (void)updateScreenSize:(NSInteger)width height:(NSInteger)height {
    [self evaluateJS:[NSString stringWithFormat:@"ogySdkMraidGateway.updateScreenSize({width: %li, height: %li})", (long)width, (long)height]];
}

- (void)updatePlacementType:(NSString *)placementType {
    [self evaluateJS:[NSString stringWithFormat:@"ogySdkMraidGateway.updatePlacementType(\"%@\")", placementType]];
}

#warning TODO: Container
- (void)updateViewability:(BOOL)boolean {
    [self evaluateJS:[NSString stringWithFormat:@"ogySdkMraidGateway.updateViewability(%@)", boolean ? @"true" : @"false"]];
}

- (void)updateAudioVolume:(NSInteger)audioVolume {
    [self evaluateJS:[NSString stringWithFormat:@"ogySdkMraidGateway.updateAudioVolume(%ld)", (long)audioVolume]];
}

- (void)updateSupportFlags {
    [self evaluateJS:@"ogySdkMraidGateway.updateSupportFlags({sms: false, tel: false, calendar: false, storePicture: false, inlineVideo: false, vpaid: false, location: false})"];
}

- (void)updateCurrentAppOrientation:(NSString *)orientation locked:(BOOL)locked {
    [self evaluateJS:[NSString stringWithFormat:@"ogySdkMraidGateway.updateCurrentAppOrientation({orientation: \"%@\", locked: %@})", orientation, locked ? @"true" : @"false"]];
}

- (void)updateOrientationProperties {
    [self evaluateJS:[NSString stringWithFormat:@"ogySdkMraidGateway.updateOrientationProperties({allowOrientationChange: true, forceOrientation: \"none\"})"]];
}

- (void)updateMaxSize:(NSInteger)width height:(NSInteger)height {
    [self evaluateJS:[NSString stringWithFormat:@"ogySdkMraidGateway.updateMaxSize({width: %ld, height: %ld})", (long)width, (long)height]];
}

- (void)updateDefaultPosition:(NSInteger)width height:(NSInteger)height {
    [self evaluateJS:[NSString stringWithFormat:@"ogySdkMraidGateway.updateDefaultPosition({x: 0, y: 0, width: %ld, height: %ld})", (long)width, (long)height]];
}

- (void)updateCurrentPosition:(NSInteger)width height:(NSInteger)height xPoz:(NSInteger)xPoz yPoz:(NSInteger)yPoz {
    [self evaluateJS:[NSString stringWithFormat:@"ogySdkMraidGateway.updateCurrentPosition({x: 0, y: 0, width: %ld, height: %ld})", (long)width, (long)height]];
}

- (void)updateResizeProperties:(NSInteger)width height:(NSInteger)height xPoz:(NSInteger)xPoz yPoz:(NSInteger)yPoz {
    [self evaluateJS:[NSString stringWithFormat:@"ogySdkMraidGateway.updateResizeProperties({width: %ld, height: %ld, offsetX: %ld, offsetY: %ld, customClosePosition: \"right\", allowOffscreen: false})", (long)width, (long)height, (long)xPoz, (long)yPoz]];
}

- (void)updateExpandProperties:(NSInteger)width height:(NSInteger)height useCustomClose:(BOOL)useCustomClose isModal:(BOOL)isModal {
    [self evaluateJS:[NSString stringWithFormat:@"ogySdkMraidGateway.updateExpandProperties({width: %ld, height: %ld, useCustomClose: %@, isModal: %@})", (long)width, (long)height, useCustomClose ? @"true" : @"false", isModal ? @"true" : @"false"]];
}

- (void)updateState:(NSString *)updateState {
    [self evaluateJS:[NSString stringWithFormat:@"ogySdkMraidGateway.updateState(\"%@\")", updateState]];
}

#warning TODO: To move to the Container, merge with updateViewability information
- (void)updateExposure:(NSInteger)width height:(NSInteger)height {
    [self evaluateJS:[NSString stringWithFormat:@"ogySdkMraidGateway.updateExposure({exposedPercentage: 100.0, visibleRectangle: {x: 0, y: 0, width: %ld, height: %ld}})", (long)width, (long)height]];
}

#warning TODO: To move to the Container, merge with updateViewability information
- (void)updateExposureWithAdExposure:(OGAAdExposure *)adExposure {
    [self evaluateJS:[adExposure toMRAIDCommand]];
}

- (void)callCommandComplete {
    [self evaluateJS:@"ogySdkMraidGateway.callComplete()"];
}

- (void)callPendingMethodCallBackWithCallBackId:(NSString *)callBackId webViewId:(NSString *)webViewId {
    NSString *command = [NSString stringWithFormat:@"ogySdkMraidGateway.callPendingMethodCallback(\"%@\", null, {webviewId: \"%@\"})", callBackId, webViewId];

    [self.log log:[[OGAMraidLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                            adConfiguration:self.baseWebView.ad.adConfiguration
                                                  webviewId:webViewId
                                                    message:[NSString stringWithFormat:@"callPendingMethodCallBackWithCallBackId: [%@]", command]
                                                       tags:nil]];

    [self evaluateJS:command];
}

- (void)sendSystemCloseEvent {
    [self evaluateJS:@"ogySdkMraidGateway.callEventListeners(\"ogyOnCloseSystem\", {})"];
}

- (void)evaluateJS:(NSString *)javaScriptString {
    [self.log log:[[OGAMraidLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                            adConfiguration:self.baseWebView.ad.adConfiguration
                                                  webviewId:self.baseWebView.webViewId
                                                    message:@"Evaluating JS command"
                                                       tags:@[ [OguryLogTag tagWithKey:@"Command" value:javaScriptString] ]]];

    if (!self.webView) {
        return;
    }

    [self.webView evaluateJavaScript:javaScriptString
                   completionHandler:^(id _Nullable response, NSError *_Nullable error) {
                       if (error) {
                           [self.log log:[[OGAMraidLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                                                   adConfiguration:self.baseWebView.ad.adConfiguration
                                                                         webviewId:self.baseWebView.webViewId
                                                                             error:error
                                                                           message:@"Failed to Evaluate JS command"
                                                                              tags:@[
                                                                                  [OguryLogTag tagWithKey:@"Command"
                                                                                                    value:javaScriptString],
                                                                                  [OguryLogTag tagWithKey:@"Reponse"
                                                                                                    value:response]
                                                                              ]]];
                       }
                   }];
}

- (void)callErrorListener:(NSString *)command message:(NSString *)message {
    NSString *method = [NSString stringWithFormat:@"ogySdkMraidGateway.callEventListeners(\"%@\",\"%@\"", command, message];

    if (!self.webView) {
        return;
    }

    [self.log log:[[OGAMraidLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                            adConfiguration:self.baseWebView.ad.adConfiguration
                                                  webviewId:self.baseWebView.webViewId
                                                    message:@"Call event listener"
                                                       tags:@[
                                                           [OguryLogTag tagWithKey:@"Command"
                                                                             value:method]
                                                       ]]];

    [self.webView evaluateJavaScript:method
                   completionHandler:^(id _Nullable response, NSError *_Nullable error) {
                       if (error) {
                           [self.log log:[[OGAMraidLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                                                   adConfiguration:self.baseWebView.ad.adConfiguration
                                                                         webviewId:self.baseWebView.webViewId
                                                                             error:error
                                                                           message:@"Failed to call event listener"
                                                                              tags:@[
                                                                                  [OguryLogTag tagWithKey:@"Command"
                                                                                                    value:method],
                                                                                  [OguryLogTag tagWithKey:@"Reponse"
                                                                                                    value:response]
                                                                              ]]];
                       }
                   }];
}

@end

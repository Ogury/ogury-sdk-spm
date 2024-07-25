//
//  Copyright © 2018 Ogury. All rights reserved.
//

#import "UIKit/UIKit.h"
#import <WebKit/WebKit.h>

@class WKWebView;
@class OGAMraidBaseWebView;
@class OGAAdExposure;

NS_ASSUME_NONNULL_BEGIN

@interface OGAJavascriptCommandExecutor : NSObject

#pragma mark - Initialization

- (instancetype)initWithWebView:(OGAMraidBaseWebView *)webView;

#pragma mark - Methods

- (void)sendLoadMraidCommandsWithFrame:(CGRect)frame;

- (void)sendShowMraidCommandsWithExposure:(OGAAdExposure *)exposure;

- (void)callCommandComplete;

- (void)sendSystemCloseEvent;

- (void)callPendingMethodCallBackWithCallBackId:(NSString *)callBackId webViewId:(NSString *)webViewId;

- (void)updateOrientationToSize:(CGSize)size;

- (void)evaluateJS:(NSString *)javaScriptString;

- (void)updateAudioVolume:(NSInteger)audioVolume;

- (void)updateExposureWithAdExposure:(OGAAdExposure *)adExposure;

- (void)updateState:(NSString *)updateState;

- (void)updateViewability:(BOOL)boolean;

@end

NS_ASSUME_NONNULL_END

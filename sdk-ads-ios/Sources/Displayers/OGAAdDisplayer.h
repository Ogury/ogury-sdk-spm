//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OGAAdDisplayerDelegate.h"
#import "OGAAdMraidDisplayerState.h"
#import "OGAAdDisplayerOrientationDelegate.h"
#import "OGAAdLoadStateManager.h"
#import <WebKit/WebKit.h>

@protocol OGAAdDisplayerInformation;
@class OGAAd;
@class OGAAdConfiguration;

NS_ASSUME_NONNULL_BEGIN

@protocol OGAAdDisplayer <NSObject>

#pragma mark - Properties

@property(nonatomic, strong, readonly) OGAAd *ad;
@property(nonatomic, strong, readonly) OGAAdConfiguration *configuration;
@property(nonatomic, strong, readonly) UIView *view;
@property(nonatomic, weak) id<OGAAdDisplayerDelegate> delegate;
@property(nonatomic, assign, readonly) OGAAdMraidDisplayerState mraidDisplayerState;
@property(nonatomic, weak) id<OGAAdDisplayerOrientationDelegate> orientationDelegate;
@property(nonatomic, strong) OGAAdLoadStateManager *stateManager;
@property(nonatomic, assign, readonly) BOOL hasKeepAlive;

#pragma mark - Methods

- (BOOL)isLoaded;

- (BOOL)isKilled;

/// Dispatch an information payload to the underlying view (can be used to evaluate Javascript within the webview)
- (void)dispatchInformation:(id<OGAAdDisplayerInformation>)information;

- (void)setupCloseButtonTimer;

- (void)registerForVolumeChange;

- (void)cleanUp;

- (void)startOMIDSessionOnShow;

- (void)executeCommandForOguryBrowser:(id<OGAAdDisplayerInformation>)information;

- (BOOL)webViewLoaded:(NSString *)webViewId;

- (void)performQualityChecks;

- (void)webkitProcessDidTerminate;
- (WKWebView *)adWebview;

@end

NS_ASSUME_NONNULL_END

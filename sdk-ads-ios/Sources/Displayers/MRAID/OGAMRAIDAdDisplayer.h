//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdDisplayer.h"
#import "OGAAdDisplayerOrientationDelegate.h"

@class OGAAd;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Implementation of the MRAID displayer.
 *
 * @discussion The MRAID ad displayer is in charge of:
 *
 * - create the ad web view.
 *
 * - loading the resources inside the web view.
 *
 * - handling MRAID command of the ad.
 *
 * - transforming MRAID commands into actions if they change the container.
 *
 * - create and manage OguryBrowser
 *
 * MRAID command that does not modify the container are handled internally like click command.
 *
 * The MRAID ad displayer will expose an UIView that can contains both the webview associated to the ad and the webviews created by the ogyCreateWebView command.
 *
 * This will allow us to reuse more code of the existing SDK. When implementing VAST, if the same logic is necessary for VAST to display the landing page, we will move this logic into its own displayer.
 */
@interface OGAMRAIDAdDisplayer : NSObject <OGAAdDisplayer>

#pragma mark - Properties

@property(nonatomic, strong, readonly) OGAAd *ad;
@property(nonatomic, strong, readonly) OGAAdConfiguration *configuration;
@property(nonatomic, strong, readonly) UIView *view;
@property(nonatomic, weak) id<OGAAdDisplayerDelegate> delegate;
@property(nonatomic, weak) id<OGAAdDisplayerOrientationDelegate> orientationDelegate;
@property(nonatomic, strong) OGAAdLoadStateManager *stateManager;

#pragma mark - Initialization

- (instancetype)initWithAd:(OGAAd *)ad adConfiguration:(OGAAdConfiguration *)configuration;
- (void)webkitProcessDidTerminate;

@end

NS_ASSUME_NONNULL_END

//
//  Copyright © 2018 Ogury. All rights reserved.
//

#import "UIKit/UIKit.h"
#import "OGAMraidAdWebView.h"
#import "OGAMRAIDWebViewDelegate.h"
#import "OGAAdLoadStateManager.h"

@class OGAAd;

NS_ASSUME_NONNULL_BEGIN

@interface OGAMRAIDWebView : OGAMraidAdWebView

#pragma mark - Initialization

- (instancetype)initWithAd:(OGAAd *)ad stateManager:(OGAAdLoadStateManager *)stateManager;
@property(nonatomic) BOOL hasLoaded;

@end

NS_ASSUME_NONNULL_END

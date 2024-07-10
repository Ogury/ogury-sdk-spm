//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGAAd.h"
#import "OGAAdExposure.h"
#import "OGADelegateDispatcher.h"

NS_ASSUME_NONNULL_BEGIN

extern CGFloat const OGAAdImpressionControllerMinExposureForImpression;

/**
 * Managers in charge of sending the impression tracker for the ads.
 *
 * The controller will take care of sending only one impression for each ad even if you call
 * the methods multiple times.
 */
@interface OGAAdImpressionManager : NSObject

#pragma mark - Initialization

+ (instancetype)shared;

#pragma mark - Methods

- (void)sendIfNecessaryAfterExposureChanged:(OGAAdExposure *)exposure ad:(OGAAd *)ad delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher;

- (BOOL)isImpressionDelegateSentFor:(OGAAd *)ad;

- (void)hasSentImpressionDelegateFor:(OGAAd *)ad;

- (void)sendFormatImpressionTrackFor:(OGAAd *)ad;

@end

NS_ASSUME_NONNULL_END

//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryCore.h>

#import "OGAAdSequence.h"
#import "OGAAdSequenceCoordinatorDelegate.h"

@class OGAAdController;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief The sequence coordinator is in charge of handling the list of ad controllers.
 *
 * @discussion
 * - isLoaded must check if all controllers are loaded before returning true.
 *
 * - listen to the delegate to send the loaded through the delegate dispatcher.
 *
 * - displaying the next ad controller in case of the previous closed.
 *
 * - displaying the next ad controller in case of next ad command.
 */
@interface OGAAdSequenceCoordinator : NSObject

#pragma mark - Properties

@property(nonatomic, weak, readonly) OGAAdSequence *sequence;
@property(nonatomic, strong, readonly) NSArray<OGAAdController *> *adControllers;

@property(nonatomic, weak) id<OGAAdSequenceCoordinatorDelegate> delegate;

/**
 * True if all the ad controllers are loaded.
 */
@property(nonatomic, assign, readonly) BOOL isLoaded;

/**
 * True if all the ad controllers are expired.
 */
@property(nonatomic, assign, readonly) BOOL isExpired;

/**
 * True if the currently displayed ad controller is expanded.
 */
@property(nonatomic, assign, readonly) BOOL isExpanded;

/**
 * True if any of the ad controllers is displayed on screen.
 */
@property(nonatomic, assign, readonly) BOOL isDisplayed;

/**
 * True if any of the ad controllers is displayed on screen in an fullscreen overlay state.
 */
@property(nonatomic, assign, readonly) BOOL isFullScreenOverlay;

/**
 * True if any of the ad controllers is displayed on screen in an overlay state.
 */
@property(nonatomic, assign, readonly) BOOL isOverlay;

/**
 * True if all the ad controllers are closed.
 */
@property(nonatomic, assign, readonly) BOOL isClosed;

/**
 * True if one of the ad controllers has been killed by OS.
 */
@property(nonatomic, assign, readonly) BOOL isKilled;

#pragma mark - Initialization

- (instancetype)initWithSequence:(OGAAdSequence *)sequence adControllers:(NSArray<OGAAdController *> *)adControllers;

#pragma mark - Methods

- (BOOL)show:(OguryAdError *_Nullable *_Nullable)error;

- (void)close;

@end

NS_ASSUME_NONNULL_END

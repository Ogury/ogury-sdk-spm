//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGAAdSequence.h"
#import "OGAAdController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * This components will retain sequences that are currently displayed on screen.
 *
 * Retaining a sequence will prevent the ad from disappearing from the screen even if the publisher looses
 * the reference to the ad object.
 *
 * Ex. a banner in a collection view that get recycled when it is presenting its landing page fullscreen.
 */
@interface OGAAdSequenceRetainController : NSObject

+ (instancetype)shared;

#pragma mark - Methods

/**
 * Retain the sequence.
 * Add the controller to the list of controllers that want the sequence to be retained.
 *
 * @param sequence Sequence to retain.
 * @param controller Controller that wants the sequence to be retained.
 */
- (void)retainSequence:(OGAAdSequence *)sequence fromController:(OGAAdController *)controller;

/**
 * Remove the controller from the list that want the sequence to be retained.
 * If there is no more controllers in this list after the operation, the reference to the sequence is released allowing
 * it to be collected by the reference counter.
 *
 * @param sequence Sequence to release.
 * @param controller Controller that do no more require the sequence to be retained.
 */
- (void)releaseSequence:(OGAAdSequence *)sequence fromController:(OGAAdController *)controller;

@end

NS_ASSUME_NONNULL_END

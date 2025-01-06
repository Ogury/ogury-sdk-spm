//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAAdSequenceCoordinator.h"
#import "NSString+OGAUtility.h"
#import "OGAAd+ImpressionSource.h"
#import "OGAAdController.h"
#import "OGAAdSequence.h"
#import "OGAAdSequenceRetainController.h"
#import "OGAMetricsService.h"
#import "OGAMonitoringDispatcher.h"
#import "OGATrackEvent.h"
#import "OguryAdError.h"
#import "OguryAdError+Internal.h"

@interface OGAAdSequenceCoordinator () <OGAAdControllerDelegate>

@property(nonatomic, weak, readwrite) OGAAdSequence *sequence;
@property(nonatomic, strong) OGAAdSequenceRetainController *sequenceRetainController;
@property(nonatomic, assign) BOOL closedDispatched;
@property(nonatomic, assign) BOOL loadedDispatched;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) OGAMetricsService *metricService;

@end

@implementation OGAAdSequenceCoordinator

#pragma mark - Initialization

- (instancetype)initWithSequence:(OGAAdSequence *)sequence adControllers:(NSArray<OGAAdController *> *)adControllers {
    return [self initWithSequence:sequence
                    adControllers:adControllers
         sequenceRetainController:[OGAAdSequenceRetainController shared]
             monitoringDispatcher:[OGAMonitoringDispatcher shared]
                    metricService:[OGAMetricsService shared]];
}

- (instancetype)initWithSequence:(OGAAdSequence *)sequence
                   adControllers:(NSArray<OGAAdController *> *)adControllers
        sequenceRetainController:(OGAAdSequenceRetainController *)sequenceRetainController
            monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher
                   metricService:(OGAMetricsService *)metricService {
    if (self = [super init]) {
        _sequence = sequence;
        _adControllers = adControllers;
        _sequenceRetainController = sequenceRetainController;
        _monitoringDispatcher = monitoringDispatcher;
        _metricService = metricService;

        // Setup delegation
        for (OGAAdController *adController in _adControllers) {
            adController.delegate = self;
        }
    }

    return self;
}

#pragma mark - Properties

- (BOOL)isNotLoadedYet {
    BOOL sequenceIsReady = YES;
    BOOL oneControllerIsLoaded = NO;
    for (OGAAdController *adController in self.adControllers) {
        if (!adController.isLoaded && !adController.isClosed) {
            sequenceIsReady = NO;
        }
        if (adController.isLoaded) {
            oneControllerIsLoaded = YES;
        }
    }
    return !sequenceIsReady && !oneControllerIsLoaded;
}

- (BOOL)isLoaded {
    BOOL sequenceIsReady = YES;
    BOOL oneControllerIsLoaded = NO;
    for (OGAAdController *adController in self.adControllers) {
        if (!adController.isLoaded && !adController.isClosed) {
            sequenceIsReady = NO;
        }
        if (adController.isLoaded) {
            oneControllerIsLoaded = YES;
        }
    }
    return sequenceIsReady && oneControllerIsLoaded;
}

- (BOOL)isKilled {
    for (OGAAdController *adController in self.adControllers) {
        if (adController.isKilled) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isExpired {
    int numberOfExpiredControllers = 0;

    for (OGAAdController *adController in self.adControllers) {
        if (adController.isExpired) {
            numberOfExpiredControllers++;
        }
    }

    return numberOfExpiredControllers == self.adControllers.count;
}

- (BOOL)isExpanded {
    OGAAdController *currentlyDisplayedAdController;

    for (OGAAdController *adController in self.adControllers) {
        if (adController.isDisplayed) {
            currentlyDisplayedAdController = adController;
            break;
        }
    }

    if (currentlyDisplayedAdController) {
        return currentlyDisplayedAdController.isExpanded;
    }

    return NO;
}

- (BOOL)isDisplayed {
    for (OGAAdController *adController in self.adControllers) {
        if (adController.isDisplayed) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isFullScreenOverlay {
    for (OGAAdController *adController in self.adControllers) {
        if (adController.isFullScreenOverlay) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isOverlay {
    for (OGAAdController *adController in self.adControllers) {
        if (adController.isOverlay) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isClosed {
    for (OGAAdController *adController in self.adControllers) {
        if (!adController.isClosed) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Methods

- (BOOL)show:(OguryAdError *_Nullable *_Nullable)error {
    if (!self.isLoaded) {
        if (error) {
            *error = [OguryAdError noAdLoaded];
        }
        return NO;
    }
    if (self.isDisplayed) {
        if (error) {
#warning FIXME create dedicated error for this case.
            *error = [OguryAdError anotherAdIsAlreadyDisplayed];
        }
        return NO;
    }
    if (self.isClosed) {
        if (error) {
            *error = [OguryAdError noAdLoaded];
        }
        return NO;
    }

    OGAAdController *initialController;
    for (int index = 0; index < self.adControllers.count; index++) {
        OGAAdController *currentController = self.adControllers[index];
        if (currentController.isLoaded && !currentController.isExpired) {
            initialController = currentController;
            break;
        }
    }

    if (!initialController) {
        if (error) {
            *error = [OguryAdError adExpired];
        }
        return NO;
    }

    [self.monitoringDispatcher sendShowEventDisplay:[NSNumber numberWithInteger:self.adControllers.count]
                                    adConfiguration:initialController.ad.adConfiguration];

    if (![initialController show:error]) {
        return NO;
    }

    return YES;
}

- (void)close {
    for (OGAAdController *adController in self.adControllers) {
        if (![adController isClosed]) {
            [adController forceClose];
        }
    }

    if ([self.delegate respondsToSelector:@selector(didCloseSequence:)]) {
        [self.delegate didCloseSequence:self.sequence];
    }
    self.sequence.status = OGAAdSequenceStatusClosed;
}

- (void)dispatchClosedIfNecessary {
    if (self.closedDispatched || !self.isClosed) {
        return;
    }
    self.closedDispatched = YES;

    if ([self.delegate respondsToSelector:@selector(didCloseSequence:)]) {
        [self.delegate didCloseSequence:self.sequence];
    }
    [self.sequence.configuration.delegateDispatcher closed];
}

/**
 * Find the controller that must be displayed next according to information contained in next ad and the
 * closing controller.
 *
 * Depending on the next ad:
 * - if nextAdId is nil, empty or equals to "null" chain, we select the first non-closed controller following
 * the closing controller.
 * - else, we select the first non-closed controller with ad id matching the nextAdId.
 *
 * If we cannot find a controller matching any of those two conditions, this method will return nil.
 *
 * @param nextAd Information about the next ad.
 * @param closingController Controller that is currently closing causing the next ad to be displayed if possible.
 * @return the next controller or nil.
 */
- (OGAAdController *)controllerForNextAd:(OGANextAd *_Nullable)nextAd closingController:(OGAAdController *_Nonnull)closingController {
    NSString *nextAdId = [OGANextAd nextAdId:nextAd];
    if (!nextAdId) {
        return [self nextAvailableControllerFromClosingController:closingController];
    } else {
        return [self findAvailableControllerWithAdId:nextAdId];
    }
}

- (BOOL)continueLoadingSequenceWithClosingController:(OGAAdController *_Nonnull)closingController {
    for (OGAAdController *controller in self.adControllers) {
        if (controller != closingController) {
            return YES;
        }
    }
    return NO;
}

- (OGAAdController *)nextAvailableControllerFromClosingController:(OGAAdController *_Nonnull)closingController {
    NSUInteger index = [self.adControllers indexOfObject:closingController];
    OGAAdController *nextController = nil;
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    while (!nextController && index < self.adControllers.count) {
        OGAAdController *controller = self.adControllers[index];
        if (!controller.isClosed && !controller.isExpired) {
            nextController = controller;
        }
        index++;
    }
    return nextController;
}

- (OGAAdController *)findAvailableControllerWithAdId:(NSString *_Nonnull)adId {
    NSEnumerator<OGAAdController *> *it = self.adControllers.objectEnumerator;
    OGAAdController *controller = nil;
    while ((controller = it.nextObject)) {
        if ([adId isEqualToString:controller.ad.identifier] && !controller.isClosed && !controller.isExpired) {
            return controller;
        }
    }
    return nil;
}

#pragma mark - OGAAdControllerDelegate

- (void)controller:(OGAAdController *)controller didLoadAd:(OGAAd *)ad {
    if (self.isLoaded) {
        [self setSequenceStatusLoadedWithAdController:controller];
    }
}

- (void)controller:(OGAAdController *)controller didUnLoadAd:(OGAAd *)ad origin:(UnloadOrigin)unloadOrigin {
    if (self.isLoaded) {
        [self setSequenceStatusLoadedWithAdController:controller];
    } else if (self.isClosed) {
        self.sequence.status = OGAAdSequenceStatusClosed;
        [self.sequence.configuration.delegateDispatcher failedWithError:[OguryAdError noAdLoaded]];
        [self.metricService sendEvent:[[OGATrackEvent alloc] initWithAd:ad event:OGAMetricsEventLoadedError]];
    } else if (self.isNotLoadedYet) {
        self.sequence.status = OGAAdSequenceStatusError;
        [self.sequence.configuration.delegateDispatcher failedWithError:unloadOrigin == UnloadOriginTimeout
                                                            ? [OguryAdError adPrecachingTimeout]
                                                            : [OguryAdError noAdLoaded]];
        [self.metricService sendEvent:[[OGATrackEvent alloc] initWithAd:ad event:OGAMetricsEventLoadedError]];
        if (unloadOrigin == UnloadOriginFormat) {
            [self.monitoringDispatcher sendLoadErrorEventPrecacheFail:OGAMonitoringPrecacheErrorUnload
                                                      adConfiguration:controller.ad.adConfiguration];
        }
    }
}

- (void)setSequenceStatusLoadedWithAdController:(OGAAdController *)controller {
    self.sequence.status = OGAAdSequenceStatusLoaded;
    if (!self.loadedDispatched) {
        [self.sequence.configuration.delegateDispatcher loaded];

        [self.monitoringDispatcher sendLoadEvent:OGALoadEventLoadAdLoaded adConfiguration:controller.ad.adConfiguration];
        self.loadedDispatched = YES;
    }
}

- (void)controller:(OGAAdController *)controller didOpenOverlayForAd:(OGAAd *)ad {
    // Retain the sequence to avoid the ad disappearing if the publisher looses the reference.
    [self.sequenceRetainController retainSequence:self.sequence fromController:controller];
}

- (void)controller:(OGAAdController *)controller webkitProcessDidTerminateForAd:(OGAAd *)ad {
    self.sequence.status = OGAAdSequenceStatusError;
    if ([ad.adConfiguration.delegateDispatcher respondsToSelector:@selector(failedWithError:)]) {
        OguryAdError *adError = [OguryAdError adPrecachingFailedWithStackTrace:OGAMonitoringErrorEventWebviewDidTerminateStackTrace];
        [ad.adConfiguration.delegateDispatcher failedWithError:adError];
    }
    OGAMutableOrderedDictionary *precachingFailReason = [[OGAMutableOrderedDictionary alloc] init];
    precachingFailReason[OGAMonitoringErrorEventContentReason] = OGAMonitoringErrorEventWebviewDidTerminateStackTrace;
    [self.monitoringDispatcher sendLoadErrorEvent:OGALoadErrorEventPrecacheError adConfiguration:ad.adConfiguration errorContent:precachingFailReason];
    [self.metricService sendEvent:[[OGATrackEvent alloc] initWithAd:controller.ad event:OGAMetricsEventLoadedError]];
}

- (void)controller:(OGAAdController *)controller didCloseOverlayForAd:(OGAAd *)ad {
    // Release the sequence.
    [self.sequenceRetainController releaseSequence:self.sequence fromController:controller];
}

- (void)controller:(OGAAdController *)controller didCloseWithNextAd:(OGANextAd *)nextAd {
    // Trigger didClose callback once we have finished displaying all ads in sequence.
    [self dispatchClosedIfNecessary];

    BOOL showNextAd = [OGANextAd shouldShowNextAd:nextAd];
    if (!showNextAd) {
        [self close];
        return;
    }

    OGAAdController *nextController = [self controllerForNextAd:nextAd closingController:controller];
    if (!nextController) {
        [self close];
        return;
    }
    OguryAdError *error = nil;
    if (![nextController show:&error]) {
        [self.sequence.configuration.delegateDispatcher failedWithError:error];
        [self close];
        return;
    }
}

- (void)controller:(OGAAdController *)controller didUnLoadWithNextAd:(OGANextAd *)nextAd {
    if (self.sequence.status == OGAAdSequenceStatusShown) {
        OGAAdController *nextController = [self controllerForNextAd:nextAd closingController:controller];
        OguryAdError *error = nil;
        if (!nextController) {
            [self close];
            [self dispatchClosedIfNecessary];
        } else if (![nextController show:&error]) {
            [self close];
            [self.sequence.configuration.delegateDispatcher failedWithError:error];
        }
        [self.metricService sendEvent:[[OGATrackEvent alloc] initWithAd:controller.ad event:OGAMetricsEventLoadedError]];
    } else if (self.sequence.status == OGAAdSequenceStatusLoading || self.sequence.status == OGAAdSequenceStatusLoaded) {
        if (![self continueLoadingSequenceWithClosingController:controller]) {
            [self close];
            [self.metricService sendEvent:[[OGATrackEvent alloc] initWithAd:controller.ad event:OGAMetricsEventLoadedError]];
        }
    }
}

- (void)killWebviews {
    for (int index = 0; index < self.adControllers.count; index++) {
        OGAAdController *ctrl = self.adControllers[index];
        [ctrl.displayer webkitProcessDidTerminate];
    }
}

@end

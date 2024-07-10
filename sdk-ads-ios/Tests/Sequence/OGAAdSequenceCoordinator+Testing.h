//
// Copyright (c) 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGAAdControllerDelegate.h"
#import "OGAAdSequenceCoordinator.h"
#import "OGAAdSequenceRetainController.h"
#import "OGAMonitoringDispatcher.h"
#import "OGAMetricsService.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdSequenceCoordinator (Testing) <OGAAdControllerDelegate>

#pragma mark - Properties

@property(nonatomic, assign) BOOL closedDispatched;

#pragma mark - Methods

- (void)dispatchClosedIfNecessary;

- (OGAAdController *)controllerForNextAd:(OGANextAd *_Nullable)nextAd closingController:(OGAAdController *)closingController;

- (OGAAdController *)nextAvailableControllerFromClosingController:(OGAAdController *)closingController;

- (OGAAdController *)findAvailableControllerWithAdId:(NSString *)adId;

- (instancetype)initWithSequence:(OGAAdSequence *)sequence
                   adControllers:(NSArray<OGAAdController *> *)adControllers
        sequenceRetainController:(OGAAdSequenceRetainController *)sequenceRetainController
            monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher
                   metricService:(OGAMetricsService *)metricService;

- (BOOL)continueLoadingSequenceWithClosingController:(OGAAdController *_Nonnull)closingController;
- (BOOL)isNotLoadedYet;

@end

NS_ASSUME_NONNULL_END

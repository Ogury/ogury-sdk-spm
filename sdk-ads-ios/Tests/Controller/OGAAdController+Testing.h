//
// Copyright (c) 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGAAdController.h"

#import "OGAAdContainer.h"
#import "OGANextAd.h"
#import "OGAAdManager.h"
#import "OGAMetricsService.h"
#import "OGAAdExpirationManager.h"
#import "OGAMonitoringDispatcher.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdController (Testing) <OGAAdDisplayerDelegate, OGAAdContainerDelegate>

#pragma mark - Properties

@property(nonatomic, strong, nullable) OGANextAd *nextAd;
@property(nonatomic, strong, readonly) NSDate *createdAt;

#pragma mark - Initialization

- (instancetype)initWithAd:(OGAAd *)ad
             configuration:(OGAAdConfiguration *)configuration
                 displayer:(id<OGAAdDisplayer>)displayer
                 container:(OGAAdContainer *)container
            metricsService:(OGAMetricsService *)metricsService
       adExpirationManager:(OGAAdExpirationManager *)adExpirationManager
      monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher
                       log:(OGALog *)log;

#pragma mark - Methods

- (void)sendLoadedTracker;

@end

NS_ASSUME_NONNULL_END

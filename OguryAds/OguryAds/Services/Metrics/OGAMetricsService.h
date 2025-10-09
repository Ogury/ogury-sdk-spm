//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAMonitoringDispatcher.h"

@class OGAMetricEvent;
@class OGAAd;

NS_ASSUME_NONNULL_BEGIN

@interface OGAMetricsService : NSObject

#pragma mark - Constants

+ (instancetype)shared;

#pragma mark - Methods

/**
 * Enqueue the supplied track event and send it as soon as possible.
 *
 * @param event The event to enqueue.
 */
- (void)sendEvent:(OGAMetricEvent *)event;

/**
 * Sends a custom track event to a dedicated URL specified within the Ad.
 *
 * @param ad The Ad to send the custom track event for.
 * @param url The URL to send the custom track event to.
 */
- (void)sendTrackEventForAd:(OGAAd *)ad withURL:(NSString *)url;

/**
 * Enqueue the supplied track event, if it needs to be put on hold, it will be sent later on.
 *
 * @param event The event to enqueue.
 */
- (void)enqueueEvent:(OGAMetricEvent *)event;

/**
 * Enqueue custom track event to a dedicated URL specified within the Ad., if it needs to be put on hold, it will be sent later on.
 *
 * @param ad The Ad to send the custom track event for.
 * @param url The URL to send the custom track event to.
 */
- (void)enqueueTrackEventForAd:(OGAAd *)ad withURL:(NSString *)url;

/**
 * Make the metrics service hold the event associated with the supplied Ad until they are released.
 *
 * @param ad The Ad from which the identifier will be taken to hold the array of events to send for.
 */
- (void)holdEventsForAd:(OGAAd *)ad;

/**
 * Make the metrics service release the event(s) associated with the supplied Ad.
 *
 * @param ad The Ad from which the identifier will be taken to release the events to send.
 */
- (void)releaseEventsForAd:(OGAAd *)ad;

- (void)setTrackingMask:(OGATrackingMask)trackingMask;

@end

NS_ASSUME_NONNULL_END

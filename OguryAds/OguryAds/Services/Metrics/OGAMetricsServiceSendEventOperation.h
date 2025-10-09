//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OGAMetricEvent;

NS_ASSUME_NONNULL_BEGIN

/// Represents an operation that can be used to send a metric event.
@interface OGAMetricsServiceSendEventOperation : NSOperation

#pragma mark - Initialization

- (instancetype)initWithEvent:(OGAMetricEvent *)event;

@end

NS_ASSUME_NONNULL_END

//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGAMetricEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAMetricsRequestBuilder : NSObject

- (NSURLRequest *_Nullable)buildRequest:(OGAMetricEvent *)event;

@end

NS_ASSUME_NONNULL_END

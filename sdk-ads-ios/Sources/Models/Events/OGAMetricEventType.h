//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    OGAMetricsEventLoad = 0,
    OGAMetricsEventShow = 1,
    OGAMetricsEventLoaded = 2,
    OGAMetricsEventShown = 3,
    OGAMetricsEventExpired = 4,
    OGAMetricsEventLoadedError = 5,
    OGAMetricsEventHistory = 6
} OGAMetricEventType;

//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGMMonitorable.h"

NS_ASSUME_NONNULL_BEGIN

/// The purpose of the MonitorManager if to be always alive so that is can send events whenever needed
/// To that extend, the monitors added to the Manager are always up.
/// If you wish to reset the outputs due to external event, please use `resetMonitors`
@interface OGMMonitorManager : NSObject <OGMMonitorable>

- (void)addMonitor:(id<OGMMonitorable>)monitor;
- (void)resetMonitors;

@end

NS_ASSUME_NONNULL_END

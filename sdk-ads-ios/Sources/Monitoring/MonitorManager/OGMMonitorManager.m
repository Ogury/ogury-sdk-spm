//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import "OGMMonitorManager.h"
#import "OGMOSLogMonitor.h"

#pragma mark - MonitorManager Private
@interface OGMMonitorManager ()

@property(nonnull, retain) NSMutableArray<id<OGMMonitorable>> *monitors;

@end

#pragma mark - MonitorManager
@implementation OGMMonitorManager

@synthesize monitors;

- (instancetype)init {
    if (self = [super init]) {
        monitors = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addMonitor:(id<OGMMonitorable>)monitor {
    [monitors addObject:monitor];
}

- (void)resetMonitors {
    [monitors removeAllObjects];
}

- (void)monitor:(id<OGMEventMonitorable>)event {
    for (int index = 0; index < monitors.count; index++) {
        [monitors[index] monitor:event];
    }
}

@end

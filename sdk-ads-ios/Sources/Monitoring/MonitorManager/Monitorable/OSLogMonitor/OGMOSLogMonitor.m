//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import "OGMOSLogMonitor.h"
#import <os/log.h>

@implementation OGMOSLogMonitor

- (void)monitor:(id<OGMEventMonitorable>)event {
    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_INFO, "%{public}s", [[NSString alloc] initWithFormat:@"[Monitoring] %@", event.asDisctionary].UTF8String);
}

@end

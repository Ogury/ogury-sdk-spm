//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#ifndef Monitorable_h
#define Monitorable_h

#import "OGMEventMonitorable.h"

@protocol OGMMonitorable <NSObject>

- (void)monitor:(id<OGMEventMonitorable>)event;

@end

#endif /* Monitorable_h */

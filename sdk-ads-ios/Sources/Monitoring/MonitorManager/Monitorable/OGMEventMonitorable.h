//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#ifndef MonitorEvent_h
#define MonitorEvent_h

#import <Foundation/Foundation.h>

@protocol OGMEventMonitorable <NSObject, NSCoding>

- (NSDictionary *)asDisctionary;

@end

#endif /* MonitorEvent_h */

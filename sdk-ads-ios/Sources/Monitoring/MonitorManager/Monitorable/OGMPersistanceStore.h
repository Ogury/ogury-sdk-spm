//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#ifndef OGMPersistanceStore_h
#define OGMPersistanceStore_h

#import <Foundation/Foundation.h>
#import "OGMEventMonitorable.h"

@protocol OGMPersistanceStore <NSObject>

- (NSMutableArray<id<OGMEventMonitorable>> *)getEvents;
- (void)saveEvents:(NSArray<id<OGMEventMonitorable>> *)events;
- (void)cleanEvents;

@end

#endif /* OGMPersistanceStore_h */

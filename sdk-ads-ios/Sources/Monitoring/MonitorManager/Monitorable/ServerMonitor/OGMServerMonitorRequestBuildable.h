//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#ifndef OGMServerMonitorRequestBuildable_h
#define OGMServerMonitorRequestBuildable_h

#import "OGMEventMonitorable.h"
#import <Foundation/Foundation.h>

@protocol OGMServerMonitorRequestBuildable <NSObject>

- (NSURLRequest *)buildRequestWithEvents:(NSArray<id<OGMEventMonitorable>> *)events;

@end

#endif /* OGMServerMonitorRequestBuildable_h */

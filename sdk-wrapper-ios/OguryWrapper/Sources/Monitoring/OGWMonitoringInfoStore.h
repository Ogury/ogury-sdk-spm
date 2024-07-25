//
// Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGWMonitoringInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGWMonitoringInfoStore : NSObject

- (BOOL)save:(OGWMonitoringInfo *)monitoringInfo error:(NSError * _Nullable * _Nullable)error;

- (OGWMonitoringInfo * _Nullable)load;

@end

NS_ASSUME_NONNULL_END

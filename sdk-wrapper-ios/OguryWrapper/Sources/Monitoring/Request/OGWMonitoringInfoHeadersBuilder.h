//
// Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGWMonitoringInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGWMonitoringInfoHeadersBuilder : NSObject

#pragma mark - Methods

- (NSDictionary<NSString *, NSString *> *)build:(OGWMonitoringInfo *)monitoringInfo;

@end

NS_ASSUME_NONNULL_END

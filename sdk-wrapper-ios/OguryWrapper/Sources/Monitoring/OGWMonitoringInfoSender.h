//
// Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGWMonitoringInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGWMonitoringInfoSender : NSObject

#pragma mark - Methods

- (void)send:(OGWMonitoringInfo *)monitoringInfo completionHandler:(void(^ _Nullable)(NSError *))completionHandler;

@end

NS_ASSUME_NONNULL_END

//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGMMonitorable.h"
#import "OGMPersistanceStore.h"
#import "OGMServerMonitorRequestBuildable.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGMServerMonitor : NSObject <OGMMonitorable>

- (instancetype)initWithRequestBuilder:(id<OGMServerMonitorRequestBuildable>)requestBuilder
                      persistanceStore:(id<OGMPersistanceStore>)persistanceStore;

@end

NS_ASSUME_NONNULL_END

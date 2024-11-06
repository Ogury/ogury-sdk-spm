//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGMMonitorEvent.h"
#import "OGAMonitoringConstants.h"
#import "OGAAdConfiguration.h"
#import "OGAMonitorEventConfiguration.h"
#import "OGMEventLogMonitorable.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdMonitorEvent : OGMMonitorEvent<OGMEventLogMonitorable>

@property(nonatomic, retain) OGAAdConfiguration* adConfiguration;

- (instancetype)initWithEventConfiguration:(OGAMonitorEventConfiguration *)eventConfiguration
                           adConfiguration:(OGAAdConfiguration *)adConfiguration
                           customSessionId:(NSString *_Nullable)sessionId
                         detailsDictionary:(NSDictionary *_Nullable)detailsDictionary
                              errorContent:(NSDictionary *_Nullable)errorContent;

@end

NS_ASSUME_NONNULL_END

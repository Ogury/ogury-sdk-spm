//
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAMonitoringConstants.h"
#import "OGAMonitorEventConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAMonitorEventConfigurationFactory : NSObject
+ (instancetype)shared;
- (OGAMonitorEventConfiguration *)configurationFor:(OGAMonitoringEvent)event;
@end

NS_ASSUME_NONNULL_END

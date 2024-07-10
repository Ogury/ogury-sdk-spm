//
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAMonitoringConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAMonitoringEventPermissionTestsHelper : NSObject

- (BOOL)canSendCampaignIdFor:(OGAMonitoringEvent)event;

- (BOOL)canSendCreativeIdFor:(OGAMonitoringEvent)event;

- (BOOL)canSendExtrasFor:(OGAMonitoringEvent)event;

@end

NS_ASSUME_NONNULL_END

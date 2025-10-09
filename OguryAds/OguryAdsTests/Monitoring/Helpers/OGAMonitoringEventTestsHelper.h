//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAMonitoringDispatcher.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAMonitoringEventTestsHelper : NSObject

- (NSString *)eventCodeFromEvent:(OGAMonitoringEvent)event;
- (NSString *)eventNameFromEvent:(OGAMonitoringEvent)event;
- (NSString *)errorTypeFromEvent:(OGAMonitoringEvent)event;
- (NSString *)errorDescriptionFromEvent:(OGAMonitoringEvent)event;

@end

NS_ASSUME_NONNULL_END

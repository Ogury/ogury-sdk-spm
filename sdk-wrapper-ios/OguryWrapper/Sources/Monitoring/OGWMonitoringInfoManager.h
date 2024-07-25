//
// Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OguryConfigurationPrivate.h"

@interface OGWMonitoringInfoManager : NSObject

#pragma mark - Methods

- (void)appendMonitoringInfoAndSendIfNecessary:(OguryConfiguration *)configuration;

@end

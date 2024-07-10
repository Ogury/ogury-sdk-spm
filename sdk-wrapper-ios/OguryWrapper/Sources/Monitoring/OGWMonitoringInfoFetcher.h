//
// Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGWMonitoringInfo.h"
#import "OguryConfiguration.h"

extern NSString * const OGWMonitoringInfoFetcherAssetKeyKey;

@interface OGWMonitoringInfoFetcher : NSObject

- (OGWMonitoringInfo *)populate:(OguryConfiguration *)configuration;

@end

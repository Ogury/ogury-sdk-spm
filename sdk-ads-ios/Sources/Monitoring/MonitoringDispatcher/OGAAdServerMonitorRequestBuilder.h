//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGMEventMonitorable.h"
#import "OGMServerMonitorRequestBuildable.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdServerMonitorRequestBuilder : NSObject <OGMServerMonitorRequestBuildable>

- (instancetype)initWithUrl:(NSURL *)url;
- (NSURLRequest *_Nullable)buildRequestWithEvents:(NSArray<id<OGMEventMonitorable>> *)events;

@end

NS_ASSUME_NONNULL_END

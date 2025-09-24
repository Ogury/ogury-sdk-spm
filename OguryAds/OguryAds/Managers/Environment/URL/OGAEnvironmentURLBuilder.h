//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAEnvironmentConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAEnvironmentURLBuilder : NSObject

- (instancetype)initWith:(OGAEnvironment)environment;

- (NSURL *)buildAdSyncURL;

- (NSURL *)buildMonitoringURL;

- (NSURL *)buildProfigURL;

- (NSURL *)buildLaunchURL;

- (NSURL *)buildPreCacheURL;

- (NSURL *)buildTrackURL;

- (NSURL *)buildAdHistoryURL;

- (void)updateEnvironment:(OGAEnvironment)environment;

@end

NS_ASSUME_NONNULL_END

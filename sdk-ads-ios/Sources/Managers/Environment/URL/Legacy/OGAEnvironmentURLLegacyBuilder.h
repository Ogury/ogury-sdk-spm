//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAEnvironmentConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAEnvironmentURLLegacyBuilder : NSObject

- (instancetype)initWith:(OGAEnvironment)environment;

- (NSURL *)buildLaunchURL;

- (NSURL *)buildPreCacheURL;

- (NSURL *)buildTrackURL;

- (NSURL *)buildAdHistoryURL;

- (void)updateEnvironment:(OGAEnvironment)environment;

@end

NS_ASSUME_NONNULL_END

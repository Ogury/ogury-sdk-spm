//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdExpirationManager.h"
#import "OGAMetricsService.h"
#import "OGALog.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdExpirationManager (Testing)

#pragma mark - Properties

@property(atomic, strong) NSMutableDictionary<NSString *, NSNumber *> *expirationTrackersSentByAdLocalIdentifiers;

#pragma mark - Initialization

- (instancetype)initWithMetricsService:(OGAMetricsService *)metricsService log:(OGALog *)log;

@end

NS_ASSUME_NONNULL_END

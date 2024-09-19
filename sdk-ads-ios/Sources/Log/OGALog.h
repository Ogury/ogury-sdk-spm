//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryLogLevel.h>
#import <OguryCore/OguryLog.h>
#import "OGAAdConfiguration.h"
#import "OGAAdLogMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGALog : NSObject

#pragma mark - Singleton
+ (instancetype)shared;

#pragma mark - Management
- (void)setLogLevel:(OguryLogLevel)logLevel;
- (void)addLogger:(id<OguryLogger>)logger;

#pragma mark - Logs
- (void)log:(OguryLogMessage *)message;

NSString *logErrorMessage(NSError *error);

@end

NS_ASSUME_NONNULL_END

//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryLogLevel.h>
#import <OguryCore/OguryLogger.h>
#import <OguryCore/OguryLogMessage.h>

extern OguryLogSDK const OguryLogSDKWrapper;
@class OguryConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface OGWLog : NSObject

#pragma mark - Methods

+ (instancetype)shared;

- (void)setLogLevel:(OguryLogLevel)logLevel;

- (void)log:(OguryLogLevel)logLevel message:(NSString *)message;
- (void)log:(OguryLogLevel)logLevel logType:(OguryLogType)logType message:(NSString *)message;

@end

NS_ASSUME_NONNULL_END

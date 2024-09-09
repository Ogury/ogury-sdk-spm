//
//  Copyright © 2022 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryLog.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGCLog : NSObject

#pragma mark - Methods

+ (instancetype)shared;

- (void)setLogLevel:(OguryLogLevel)logLevel;

- (void)logMessage:(OguryLogLevel)logLevel message:(NSString *)message;

- (void)logMessageFormat:(OguryLogLevel)logLevel format:(NSString *)format, ...;

- (void)logRequestMessage:(OguryLogLevel)logLevel message:(NSString *)message request:(NSURLRequest *)request;

- (void)logRequestMessageFormat:(OguryLogLevel)logLevel request:(NSURLRequest *)request format:(NSString *)format, ...;

@end

NS_ASSUME_NONNULL_END

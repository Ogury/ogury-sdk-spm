//
//  Copyright © 2022 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryLog.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGCLog : NSObject

@property (nonatomic, strong, readonly) OguryLog *oguryLog;

#pragma mark - Methods

+ (instancetype)shared;

- (void)setLogLevel:(OguryLogLevel)logLevel;

- (void)setAllowedTypes:(NSArray<NSString *> *)allowedLogTypes;

- (void)setAllowedTypes:(NSArray<NSString *> *)allowedLogTypes whiteList:(NSArray<Class> *)whitelist;

- (void)logMessage:(OguryLogLevel)logLevel message:(NSString *)message;

- (void)logMessageFormat:(OguryLogLevel)logLevel format:(NSString *)format, ...;

- (void)logRequestMessage:(OguryLogLevel)logLevel message:(NSString *)message request:(NSURLRequest *)request;

- (void)logRequestMessageFormat:(OguryLogLevel)logLevel request:(NSURLRequest *)request format:(NSString *)format, ...;

@end

NS_ASSUME_NONNULL_END

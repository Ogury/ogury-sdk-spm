//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, OguryLogLevel);

@protocol OguryLogger;
@class OguryLogMessage;

NS_ASSUME_NONNULL_BEGIN

@interface OguryLog : NSObject

#pragma mark - Properties

@property (nonatomic, strong, readonly) NSMutableArray<id<OguryLogger>> *loggers;

#pragma mark - Methods

- (void)addLogger:(id<OguryLogger>)logger;
- (void)removeLogger:(id<OguryLogger>)logger;

- (void)clearLoggers;

- (void)setLogLevel:(OguryLogLevel)logLevel;

- (void)logMessage:(OguryLogMessage *)message;

@end

NS_ASSUME_NONNULL_END

//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryLogger.h"

typedef NS_ENUM(NSInteger, OguryLogLevel);

@class OguryLogMessage;

NS_ASSUME_NONNULL_BEGIN

@interface OguryOSLogger : NSObject <OguryLogger>

#pragma mark - Properties

@property (nonatomic, assign, readwrite) OguryLogLevel logLevel;
@property (nonatomic, assign, readwrite) NSArray<OguryLogType> *allowedLogTypes;

#pragma mark - Initialization

- (instancetype)initWithSubSystem:(nullable NSString *)subSystem category:(nullable NSString *)category NS_DESIGNATED_INITIALIZER;

- (void)logMessage:(OguryLogMessage *)message;

@end

NS_ASSUME_NONNULL_END

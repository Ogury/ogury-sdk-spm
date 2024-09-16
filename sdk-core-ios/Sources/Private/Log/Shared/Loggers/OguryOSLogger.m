//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import "OguryOSLogger.h"
#import "OguryLogFormatter.h"
#import "OguryLogMessage.h"
#import "OguryLogLevel.h"

@interface OguryOSLogger ()

@property (nonatomic, copy, nullable) NSString *subSystem;
@property (nonatomic, copy, nullable) NSString *category;
@property (nonatomic, strong, nonnull) os_log_t logger;

@end

@implementation OguryOSLogger 

#pragma mark - Initialization

- (instancetype)init {
    return [self initWithSubSystem:nil category:nil];
}

- (instancetype)initWithSubSystem:(nullable NSString *)subSystem category:(nullable NSString *)category {
    if (self = [super init]) {
        _subSystem = subSystem;
        _category = category;
        _logLevel = OguryLogLevelError;
        _allowedLogTypes = @[OguryLogTypeAll];
    }
    return self;
}

#pragma mark - Methods

- (os_log_t)logger {
    if (!_logger) {
        // Returns the default logger if no sub system or category has been specified
        _logger = (!self.subSystem || !self.category) ? OS_LOG_DEFAULT : os_log_create(self.subSystem.UTF8String, self.category.UTF8String);
    }

    return _logger;
}

- (void)logMessage:(id<OguryLogMessage>)message {
    NSString *formattedMessage = message.formattedMessage;
    
    if (!formattedMessage || formattedMessage.length == 0) {
        return;
    }

    [self logToOSLevel:formattedMessage forType:[self logTypeWithLogLevel:message.level]];
}

- (os_log_type_t)logTypeWithLogLevel:(OguryLogLevel) logLevel {
    switch (logLevel) {
    case OguryLogLevelError:
        return OS_LOG_TYPE_ERROR;

    case OguryLogLevelWarning:
    case OguryLogLevelInfo:
        return OS_LOG_TYPE_INFO;

    default:
        return OS_LOG_TYPE_DEBUG;
    }
}

- (void)logToOSLevel:(NSString *)formattedMessage forType:(os_log_type_t)logType {
    os_log_with_type(self.logger, logType, "%{public}s", formattedMessage.UTF8String);
}

@end

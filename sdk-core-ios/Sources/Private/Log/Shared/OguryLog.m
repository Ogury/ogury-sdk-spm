//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import "OguryLog.h"
#import "OguryLogger.h"
#import "OguryAbstractLogMessage.h"
#import "OguryLogLevel.h"
#import "OGCURLRequestLogMessage.h"
#import "OGCEventLogMessage.h"
#import "OguryNSLogger.h"
#import "OguryOSLogger.h"
#import <OguryCore/OguryLogMessage.h>

@interface OguryLog ()

#pragma mark - Properties

@property (nonatomic, strong, readwrite) NSMutableArray<id<OguryLogger>> *loggers;

@end

@implementation OguryLog

#pragma mark - Initialization

- (instancetype)init {
    return [self init:[[NSMutableArray alloc] init]];
}

- (instancetype)init:(NSMutableArray *)loggers {
    if (self = [super init]) {
        _loggers = loggers;
    }
    
    return self;
}

#pragma mark - Methods

- (void)addLogger:(id<OguryLogger>)logger {
    @synchronized (self.loggers) {
        // Check if the logger is already added
        for (id<OguryLogger> currentLogger in self.loggers) {
            if ([currentLogger.class isEqual:logger.class]) {
                return; // Logger already exists, no need to add it again
            }
        }
        [self.loggers addObject:logger];
    }
}

- (void)removeLogger:(id<OguryLogger>)logger {
    @synchronized (self.loggers) {
        [self.loggers removeObject:logger];
    }
}

- (void)clearLoggers {
    @synchronized (self.loggers) {
        [self.loggers removeAllObjects];
    }
}

- (void)setLogLevel:(OguryLogLevel)logLevel {
    @synchronized (self.loggers) {
        for (id<OguryLogger> currentLogger in self.loggers) {
            currentLogger.logLevel = logLevel;
        }
    }
}

- (void)setAllowedTypes:(NSArray<NSString *> *)allowedLogTypes {
    @synchronized (self.loggers) {
        for (id<OguryLogger> currentLogger in self.loggers) {
            currentLogger.allowedLogTypes = @[OguryLogTypePublisher, OguryLogTypeInternal, OguryLogTypeRequests, @"Mraid", @"Monitoring", @"SDK Callbacks"];
            currentLogger.logFormatter.displayOptions = OguryLogDisplaySDK | OguryLogDisplayOrigin | OguryLogDisplayType | OguryLogDisplayLevel | OguryLogDisplayTags | OguryLogDisplayDate;
        }
    }
}

- (void)logMessage:(OguryLogMessage *)message {
    @synchronized (self.loggers) {
        for (id<OguryLogger> currentLogger in self.loggers) {
            if ([self canSendMessage:message to:currentLogger]) {
                [currentLogger logMessage:message];
            }
        }
    }
}

- (BOOL)canSendMessage:(OguryLogMessage *)message to:(id<OguryLogger>)logger {
    if (message.level > logger.logLevel) {
        return NO;
    }
    
    if (![logger.allowedLogTypes containsObject:message.logType]) {
        return NO;
    }
    return YES;
}

- (void)ogcLogRequestMessage:(OguryLogLevel)level message:(NSString *)message request:(NSURLRequest *)request {
    @synchronized (self.loggers) {
        for (id<OguryLogger> currentLogger in self.loggers) {
            OGCURLRequestLogMessage *logMessage = [[OGCURLRequestLogMessage alloc] initWithLevel:level message:message request:request];
            if ([self canSendMessage:logMessage to:currentLogger]) {
                [currentLogger logMessage:logMessage];
            }
        }
    }
}

@end

//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import "OguryLog.h"
#import "OguryLogger.h"
#import "OguryAbstractLogMessage.h"
#import "OguryLogLevel.h"
#import "OGCURLRequestLogMessage.h"
#import "OGCEventLogMessage.h"

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
        [self.loggers addObject:logger];
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

- (void)logMessage:(NSString *)message level:(OguryLogLevel)level {
    @synchronized (self.loggers) {
        for (id<OguryLogger> currentLogger in self.loggers) {
            [currentLogger logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:level message:message]];
        }
    }
}

- (void)log:(OguryLogLevel)level format:(NSString *)format, ... {
    va_list arguments;
    va_start(arguments, format);

    NSString *message = [[NSString alloc] initWithFormat:format arguments:arguments];

    va_end(arguments);

    [self logMessage:message level:level];
}

- (void)ogcLogEventBusMessage:(OguryLogLevel)level message:(NSString *)message eventEntry:(OguryEventEntry *)eventEntry {
    @synchronized (self.loggers) {
        for (id<OguryLogger> currentLogger in self.loggers) {
            [currentLogger logMessage:[[OGCEventLogMessage alloc] initWithLevel:level message:message eventEntry:eventEntry]];
        }
    }
}

- (void)ogcLogRequestMessage:(OguryLogLevel)level message:(NSString *)message request:(NSURLRequest *)request {
    @synchronized (self.loggers) {
        for (id<OguryLogger> currentLogger in self.loggers) {
            [currentLogger logMessage:[[OGCURLRequestLogMessage alloc] initWithLevel:level message:message request:request]];
        }
    }
}

@end

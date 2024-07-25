//
//  Copyright © 2022 Ogury. All rights reserved.
//

#import "OGCLog.h"
#import "OguryOSLogger.h"
#import "OGCLogFormatter.h"
#import "OGCConstants.h"

@interface OguryLog (Core)

- (void)ogcLogEventBusMessage:(OguryLogLevel)level message:(NSString *)message eventEntry:(OguryEventEntry *)eventEntry;

- (void)ogcLogRequestMessage:(OguryLogLevel)level message:(NSString *)message request:(NSURLRequest *)request;

@end

@interface OGCLog ()

@property (nonatomic, strong) OguryLog *oguryLog;

@end

@implementation OGCLog

+ (instancetype)shared {
    static OGCLog *instance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[OGCLog alloc] init];
    });
    return instance;
}

- (instancetype)init {
    return [self init:[[OguryLog alloc] init] oSLogger:[[OguryOSLogger alloc] initWithSubSystem:OGCOguryCoreBundle category:OGCOgury] logFormatter:[[OGCLogFormatter alloc] init]];
}

- (instancetype)init:(OguryLog *)oguryLog oSLogger:(OguryOSLogger *)logger logFormatter:(OGCLogFormatter *)formatter {
    if (self = [super init]) {
        _oguryLog = oguryLog;
        logger.logFormatter = formatter;
        [_oguryLog addLogger:logger];
    }
    return self;
}

- (void)setLogLevel:(OguryLogLevel)logLevel {
    [self.oguryLog setLogLevel:logLevel];
}

- (void)logMessage:(OguryLogLevel)logLevel message:(NSString *)message {
    [self.oguryLog logMessage:message level:logLevel];
}

- (void)logMessageFormat:(OguryLogLevel)logLevel format:(NSString *)format, ... {
    va_list arguments;
    va_start(arguments, format);
    [self logMessage:logLevel message:[[NSString alloc] initWithFormat:format arguments:arguments]];
    va_end(arguments);
}

- (void)logEventBusMessage:(OguryLogLevel)logLevel message:(NSString *)message eventEntry:(OguryEventEntry *)eventEntry {
    [self.oguryLog ogcLogEventBusMessage:logLevel message:message eventEntry:eventEntry];
}

- (void)logEventBusMessageFormat:(OguryLogLevel)logLevel eventEntry:(OguryEventEntry *)eventEntry format:(NSString *)format, ... {
    va_list arguments;
    va_start(arguments, format);
    [self logEventBusMessage:logLevel message:[[NSString alloc] initWithFormat:format arguments:arguments] eventEntry:eventEntry];
    va_end(arguments);
}

- (void)logRequestMessage:(OguryLogLevel)logLevel message:(NSString *)message request:(NSURLRequest *)request {
    [self.oguryLog ogcLogRequestMessage:logLevel message:message request:request];
}

- (void)logRequestMessageFormat:(OguryLogLevel)logLevel request:(NSURLRequest *)request format:(NSString *)format, ... {
    va_list arguments;
    va_start(arguments, format);
    [self logRequestMessage:logLevel message:[[NSString alloc] initWithFormat:format arguments:arguments] request:request];
    va_end(arguments);
}

@end

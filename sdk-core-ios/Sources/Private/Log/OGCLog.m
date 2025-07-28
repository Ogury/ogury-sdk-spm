//
//  Copyright © 2022 Ogury. All rights reserved.
//

#import "OGCLog.h"
#import "OguryOSLogger.h"
#import "OguryNSLogger.h"
#import "OGCLogFormatter.h"
#import "OGCConstants.h"

@interface OguryLog (Core)

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
    return [self init:[[OguryLog alloc] init] 
             oSLogger:[[OguryOSLogger alloc] initWithSubSystem:OGCOguryCoreBundle category:OGCOgury]
             nsLogger:[[OguryNSLogger alloc] initWithLevel:OguryLogLevelError]];
}

- (instancetype)init:(OguryLog *)oguryLog 
            oSLogger:(OguryOSLogger *)osLogger
            nsLogger:(OguryNSLogger *)nsLogger {
    if (self = [super init]) {
        _oguryLog = oguryLog;
        [_oguryLog addLogger:nsLogger];
    }
    return self;
}

- (void)setLogLevel:(OguryLogLevel)logLevel {
    [self.oguryLog setLogLevel:logLevel];
}

- (void)setAllowedTypes:(NSArray<NSString *> *)allowedLogTypes {
    [self.oguryLog setAllowedTypes:allowedLogTypes];
}

- (void)logMessage:(OguryLogLevel)logLevel message:(NSString *)message {
    [self.oguryLog logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:logLevel
                                                                     logType:OguryLogTypeInternal
                                                                         sdk:OguryLogSDKCore
                                                                     message:message]];
}

- (void)logMessageFormat:(OguryLogLevel)logLevel format:(NSString *)format, ... {
    va_list arguments;
    va_start(arguments, format);
    [self logMessage:logLevel message:[[NSString alloc] initWithFormat:format arguments:arguments]];
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

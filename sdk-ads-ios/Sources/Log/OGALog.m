//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGALog.h"
#import <OguryCore/OguryOSLogger.h>
#import "OGALogFormatter.h"
#import "OguryLog+Ads.h"
#import "NSString+OGAUtility.h"
#import "OguryLogConstants.h"
#import <Foundation/Foundation.h>

@interface OGALog ()

@property(nonatomic, strong) OguryLog *oguryLog;
// this hidden completion block serves only because variadic parameters Mocking with NSInvocation crashes on M1 chips
// it is only used in [logFormat:format:] method without mocking it
@property(nonatomic, copy, nullable) void (^testCompletionBlock)(NSString *, OguryLogLevel);

@end

@implementation OGALog

#pragma mark - initialisation

+ (instancetype)shared {
    static OGALog *instance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[OGALog alloc] init];
    });
    return instance;
}

- (instancetype)init {
    return [self init:[[OguryLog alloc] init] oSLogger:[[OguryOSLogger alloc] initWithSubSystem:OGABundleIdentifier category:OGALogOgury] logFormatter:[[OGALogFormatter alloc] init]];
}

- (instancetype)init:(OguryLog *)oguryLog oSLogger:(OguryOSLogger *)logger logFormatter:(OGALogFormatter *)formatter {
    if (self = [super init]) {
        _oguryLog = oguryLog;
        logger.logFormatter = formatter;
        [_oguryLog addLogger:logger];
    }
    return self;
}

#pragma mark - Methods

- (void)setLogLevel:(OguryLogLevel)logLevel {
    [self.oguryLog setLogLevel:logLevel];
}

- (void)log:(OguryLogLevel)logLevel message:(NSString *)message {
    [self.oguryLog logMessage:message level:logLevel];
}

- (void)logFormat:(OguryLogLevel)logLevel format:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    [self log:logLevel message:message];
    if (self.testCompletionBlock != nil) {
        self.testCompletionBlock(message, logLevel);
    }
    va_end(args);
}

- (void)logError:(NSError *)error message:(NSString *)message {
    [self log:OguryLogLevelError message:[NSString stringWithFormat:@"%@ - Error: %@", message, [self formatError:error]]];
}

- (void)logErrorFormat:(NSError *)error format:(NSString *)format, ... {
    va_list arguments;
    va_start(arguments, format);
    [self logError:error message:[[NSString alloc] initWithFormat:format arguments:arguments]];
    va_end(arguments);
}

- (void)logAd:(OguryLogLevel)logLevel
    forAdConfiguration:(OGAAdConfiguration *)adConfiguration
               message:(NSString *)message {
    [self.oguryLog ogaLogAdMessage:logLevel adConfiguration:adConfiguration message:message];
}

- (void)logAdFormat:(OguryLogLevel)logLevel
    forAdConfiguration:(OGAAdConfiguration *)adConfiguration
                format:(NSString *)format, ... {
    va_list arguments;
    va_start(arguments, format);
    [self logAd:logLevel forAdConfiguration:adConfiguration message:[[NSString alloc] initWithFormat:format arguments:arguments]];
    va_end(arguments);
}

- (void)logAdError:(NSError *)error forAdConfiguration:(OGAAdConfiguration *)adConfiguration message:(NSString *)message {
    [self logAd:OguryLogLevelError forAdConfiguration:adConfiguration message:[NSString stringWithFormat:@"%@ - Error: %@", message, [self formatError:error]]];
}

- (void)logAdErrorFormat:(NSError *)error
      forAdConfiguration:(OGAAdConfiguration *)adConfiguration
                  format:(NSString *)format, ... {
    va_list arguments;
    va_start(arguments, format);
    [self logAdError:error forAdConfiguration:adConfiguration message:[[NSString alloc] initWithFormat:format arguments:arguments]];
    va_end(arguments);
}

- (void)logMraid:(OguryLogLevel)logLevel
    forAdConfiguration:(OGAAdConfiguration *)adConfiguration
             webViewId:(NSString *)webViewId
               message:(NSString *)message {
    [self.oguryLog ogaLogMraidMessage:logLevel adConfiguration:adConfiguration webViewId:webViewId message:message];
}

- (void)logMraidFormat:(OguryLogLevel)logLevel
    forAdConfiguration:(OGAAdConfiguration *)adConfiguration
             webViewId:(NSString *)webViewId
                format:(NSString *)format, ... {
    va_list arguments;
    va_start(arguments, format);
    [self logMraid:logLevel forAdConfiguration:adConfiguration webViewId:webViewId message:[[NSString alloc] initWithFormat:format arguments:arguments]];
    va_end(arguments);
}

- (void)logMraidError:(NSError *)error
    forAdConfiguration:(OGAAdConfiguration *)adConfiguration
             webViewId:(NSString *)webViewId
               message:(NSString *)message {
    [self logMraid:OguryLogLevelError forAdConfiguration:adConfiguration webViewId:webViewId message:[NSString stringWithFormat:@"%@ - Error: %@", message, [self formatError:error]]];
}

- (void)logMraidErrorFormat:(NSError *)error
         forAdConfiguration:(OGAAdConfiguration *)adConfiguration
                  webViewId:(NSString *)webViewId
                     format:(NSString *)format, ... {
    va_list arguments;
    va_start(arguments, format);
    [self logMraidError:error forAdConfiguration:adConfiguration webViewId:webViewId message:[[NSString alloc] initWithFormat:format arguments:arguments]];
    va_end(arguments);
}

- (void)logEventBus:(OguryLogLevel)logLevel eventEntry:(OguryEventEntry *)eventEntry message:(NSString *)message {
    [self.oguryLog ogaLogEventBusMessage:logLevel eventEntry:eventEntry message:message];
}

- (void)logEventBusFormat:(OguryLogLevel)logLevel eventEntry:(OguryEventEntry *)eventEntry format:(NSString *)format, ... {
    va_list arguments;
    va_start(arguments, format);
    [self logEventBus:logLevel eventEntry:eventEntry message:[[NSString alloc] initWithFormat:format arguments:arguments]];
    va_end(arguments);
}

- (void)logEventBusError:(NSError *)error eventEntry:(OguryEventEntry *)eventEntry message:(NSString *)message {
    [self logEventBus:OguryLogLevelError eventEntry:eventEntry message:[NSString stringWithFormat:@"%@ - Error: %@", message, [self formatError:error]]];
}

- (void)logEventBusErrorFormat:(NSError *)error eventEntry:(OguryEventEntry *)eventEntry format:(NSString *)format, ... {
    va_list arguments;
    va_start(arguments, format);
    [self logEventBusError:error eventEntry:eventEntry message:[[NSString alloc] initWithFormat:format arguments:arguments]];
    va_end(arguments);
}

- (NSString *)formatError:(NSError *)error {
    if ([NSString ogaIsNilOrEmpty:error.localizedDescription]) {
        return [NSString stringWithFormat:@"Caused by error with code %ld and domain '%@'.", error.code, error.domain];
    } else {
        return [NSString stringWithFormat:@"Caused by %@ (code: %ld, domain: '%@').", error.localizedDescription, error.code, error.domain];
    }
}

@end

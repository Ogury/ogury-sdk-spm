//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import "OGWLog.h"
#import <OguryCore/OguryOSLogger.h>
#import "OGWLogFormatter.h"
#import "OguryLog+Wrapper.h"

@interface OGWLog ()

@property(nonatomic, strong) OguryLog *oguryLog;

// this hidden completion block serves only because variadic parameters Mocking with NSInvocation crashes on M1 chips
// it is only used in [logFormat:format:] method without mocking it
@property(nonatomic, copy, nullable) void (^testCompletionBlock)(NSString *, OguryLogLevel);

@end

@implementation OGWLog

NSString *const OGWLogOgury = @"Ogury";
NSString *const OGWBundleIdentifier = @"com.ogury.OguryWrapper";

+ (instancetype)shared {
   static OGWLog *instance;
   static dispatch_once_t token;
   dispatch_once(&token, ^{
     instance = [[OGWLog alloc] init];
   });
   return instance;
}

- (instancetype)init {
   return [self init:[[OguryLog alloc] init] oSLogger:[[OguryOSLogger alloc] initWithSubSystem:OGWBundleIdentifier category:OGWLogOgury] logFormatter:[[OGWLogFormatter alloc] init]];
}

- (instancetype)init:(OguryLog *)oguryLog oSLogger:(OguryOSLogger *)logger logFormatter:(OGWLogFormatter *)formatter {
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
   NSString *message = [[NSString alloc] initWithFormat:format arguments:arguments];
   [self logError:error message:message];
   if (self.testCompletionBlock != nil) {
      self.testCompletionBlock(message, OguryLogLevelError);
   }
   va_end(arguments);
}

- (void)logAssetKey:(OguryLogLevel)logLevel assetKey:(NSString *)assetKey message:(NSString *)message {
   [self.oguryLog ogwlogAssetKeyMessage:logLevel assetKey:assetKey message:message];
}

- (void)logAssetKeyFormat:(OguryLogLevel)logLevel assetKey:(NSString *)assetKey format:(NSString *)format, ... {
   va_list arguments;
   va_start(arguments, format);
   NSString *message = [[NSString alloc] initWithFormat:format arguments:arguments];
   [self logAssetKey:logLevel assetKey:assetKey message:message];
   if (self.testCompletionBlock != nil) {
      self.testCompletionBlock(message, logLevel);
   }
   va_end(arguments);
}

- (void)logAssetKeyError:(NSError *)error assetKey:(NSString *)assetKey message:(NSString *)message {
   [self logAssetKey:OguryLogLevelError assetKey:assetKey message:[NSString stringWithFormat:@"%@ - Error: %@", message, [self formatError:error]]];
}

- (void)logAssetKeyErrorFormat:(NSError *)error assetKey:(NSString *)assetKey format:(NSString *)format, ... {
   va_list arguments;
   va_start(arguments, format);
   NSString *message = [[NSString alloc] initWithFormat:format arguments:arguments];
   [self logAssetKeyError:error assetKey:assetKey message:message];
   if (self.testCompletionBlock != nil) {
      self.testCompletionBlock(message, OguryLogLevelError);
   }
   va_end(arguments);
}

- (NSString *)formatError:(NSError *)error {
   if (!error.localizedDescription || error.localizedDescription.length == 0) {
      return [NSString stringWithFormat:@"Caused by error with code %ld and domain '%@'.", error.code, error.domain];
   } else {
      return [NSString stringWithFormat:@"Caused by %@ (code: %ld, domain: '%@').", error.localizedDescription, error.code, error.domain];
   }
}

@end

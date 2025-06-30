//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import "OGWLog.h"
#import <OguryCore/OguryOSLogger.h>
#import <OguryCore/OguryLog.h>
#import <OguryCore/OguryLogMessage.h>

OguryLogSDK const OguryLogSDKWrapper = @"OgurySDK";

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
   return [self init:[[OguryLog alloc] init]
            oSLogger:[[OguryOSLogger alloc] initWithSubSystem:OGWBundleIdentifier category:OGWLogOgury]];
}

- (instancetype)init:(OguryLog *)oguryLog oSLogger:(OguryOSLogger *)logger {
   if (self = [super init]) {
      _oguryLog = oguryLog;
      [_oguryLog addLogger:logger];
   }
   return self;
}

#pragma mark - Methods

- (void)setLogLevel:(OguryLogLevel)logLevel {
   [self.oguryLog setLogLevel:logLevel];
}

- (void)log:(OguryLogLevel)logLevel message:(NSString *)message {
    [self log:logLevel logType:OguryLogTypeInternal message:message];
}

- (void)log:(OguryLogLevel)logLevel logType:(OguryLogType)logType message:(NSString *)message {
    [self.oguryLog logMessage:[[OguryLogMessage alloc] initWithLevel:logLevel
                                                             logType:logType
                                                                 sdk:OguryLogSDKWrapper
                                                             message:message]];
}

@end

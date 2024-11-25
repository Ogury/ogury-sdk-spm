//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGALog.h"
#import <OguryCore/OguryOSLogger.h>
#import "NSString+OGAUtility.h"
#import "OguryLogConstants.h"
#import "OGAAdLogMessage.h"
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
    return [self init:[[OguryLog alloc] init]
             oSLogger:[[OguryOSLogger alloc] initWithSubSystem:OGABundleIdentifier category:OGALogOgury]];
}

- (instancetype)init:(OguryLog *)oguryLog
            oSLogger:(OguryOSLogger *)logger {
    if (self = [super init]) {
        _oguryLog = oguryLog;
        [_oguryLog addLogger:logger];
    }
    return self;
}

NSString *logErrorMessage(NSError *error) {
    if (error.localizedRecoverySuggestion) {
        return [NSString stringWithFormat:@"[Error] #%ld %@ (%@)",
                                          error.code,
                                          error.localizedDescription,
                                          error.localizedRecoverySuggestion];
    }
    return [NSString stringWithFormat:@"[Error] #%ld %@", error.code, error.localizedDescription];
}

#pragma mark - Methods

- (void)setLogLevel:(OguryLogLevel)logLevel {
    [self.oguryLog setLogLevel:logLevel];
}

- (void)addLogger:(id<OguryLogger>)logger {
    [self.oguryLog addLogger:logger];
}

- (void)log:(OGAAdLogMessage *)message {
    [self.oguryLog logMessage:message];
}

@end

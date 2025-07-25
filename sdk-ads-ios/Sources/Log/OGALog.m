//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGALog.h"
#import <OguryCore/OguryNSLogger.h>
#import <OguryCore/OGCLog.h>
#import "NSString+OGAUtility.h"
#import "OguryLogConstants.h"
#import "OGAAdLogMessage.h"
#import <Foundation/Foundation.h>
#import "OGAAdConfiguration.h"

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
    return [self init:[OGCLog shared].oguryLog
             nsLogger:[[OguryNSLogger alloc] init]];
}

- (instancetype)init:(OguryLog *)oguryLog
            nsLogger:(OguryNSLogger *)logger {
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

- (void)removeLogger:(id<OguryLogger>)logger {
    [self.oguryLog removeLogger:logger];
}

- (void)log:(OGAAdLogMessage *)message {
    [self.oguryLog logMessage:message];
}

@end

//
//  Copyright © 2024 Ogury. All rights reserved.
//
#import "OguryLogMessage.h"
@implementation OguryLogTag
@synthesize key, value;
+(instancetype)tagWithKey:(NSString *)key value:(id)value {
    return [[self alloc] initWithKey:key value:value];
}

- (instancetype)initWithKey:(NSString *)key value:(id)value {
    if (self = [super init]) {
        self.key = key;
        self.value = value;
    }
    return self;
}
@end

OguryLogSDK const OguryLogSDKCore = @"Core";

@implementation OguryLogMessage
@synthesize tags, level, logType, origin, sdk, messageDate, message, logFormatter;

- (nonnull instancetype)initWithLevel:(OguryLogLevel)level
                              logType:(nonnull OguryLogType)logType
                                  sdk:(OguryLogSDK _Nonnull)sdk
                              message:(nonnull NSString *)message {
    return [self initWithLevel:level
                       logType:logType
                        origin:nil
                           sdk:sdk
                   messageDate:[NSDate date]
                       message:message
                          tags:nil];
}

- (instancetype)initWithLevel:(OguryLogLevel)level
                      logType:(OguryLogType _Nonnull)logType
                       origin:(NSString *_Nullable)origin
                          sdk:(OguryLogSDK _Nonnull)sdk
                  messageDate:(NSDate *_Nullable)messageDate
                      message:(NSString *_Nonnull)message
                         tags:(NSArray<OguryLogTag *> *_Nullable)tags {
    if (self = [super init]) {
        self.level = level;
        self.logType = logType;
        self.origin = origin;
        self.sdk = sdk;
        self.message = message;
        self.tags = tags;
        self.messageDate = messageDate == nil ? [NSDate date] : messageDate;
    }
    return self;
}

- (nonnull NSString *)formattedMessage {
    return [self.logFormatter formatLogMessage:self];
}

@end

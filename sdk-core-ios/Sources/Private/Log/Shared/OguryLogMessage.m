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

- (BOOL)isEqual:(id)object {
    OguryLogTag *rhsTag = (OguryLogTag*)object;
    if (rhsTag == nil) {
        return NO;
    }
    if (![self.key isEqualToString:rhsTag.key]) {
        return NO;
    }
    if ([self.value class] != [rhsTag.value class]) {
        return NO;
    }
    return [self.value isEqual:rhsTag.value];
}

@end

OguryLogSDK const OguryLogSDKCore = @"Core";

@implementation OguryLogMessage
@synthesize tags, level, logType, origin, sdk, messageDate, message;

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

- (BOOL)isEqual:(id)object {
    // clang-format off
    OguryLogMessage *rhsMessage = (OguryLogMessage *)object;
    if (rhsMessage == nil) {
        return NO;
    }
    return self.level == rhsMessage.level
    && [self.logType isEqualToString:rhsMessage.logType]
    && ((self.origin == nil && rhsMessage.origin == nil) || [self.origin isEqualToString:rhsMessage.origin])
    && [self.sdk isEqualToString:rhsMessage.sdk]
    && ((self.tags == nil && rhsMessage.tags == nil) || [self.tags isEqualToArray:rhsMessage.tags])
    && [self.message isEqualToString:rhsMessage.message];
    // clang-format on
}

@end

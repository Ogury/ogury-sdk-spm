//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import "OGMMonitorEvent.h"
#import "OGAMonitoringConstants.h"

@interface OGMMonitorEvent ()

@property(nonatomic, retain) NSNumber *timestamp;
@property(nonatomic, retain) NSString *sessionId;
@property(nonatomic, retain) NSString *eventCode;
@property(nonatomic, retain) NSString *eventName;
@property(nonatomic, retain, nullable) NSDictionary *details;
@property(nonatomic, retain, nullable) NSString *errorType;
@property(nonatomic, retain, nullable) NSDictionary *errorContent;

@end

@implementation OGMMonitorEvent
- (instancetype)initEventWithTimestamp:(NSNumber *)timestamp
                             sessionId:(NSString *)sessionId
                             eventCode:(NSString *)eventCode
                             eventName:(NSString *)eventName
                          dispatchType:(OGMDispatchType)dispatchType
                     detailsDictionary:(NSDictionary *_Nullable)detailsDictionary
                             errorType:(NSString *_Nullable)errorType
                          errorContent:(NSDictionary *_Nullable)errorContent {
    if (self = [super init]) {
        _timestamp = timestamp;
        _sessionId = sessionId;
        _eventCode = eventCode;
        _eventName = eventName;
        _dispatchType = dispatchType;
        _details = detailsDictionary;
        _errorType = errorType;
        _errorContent = errorContent;
    }
    return self;
}

- (NSDictionary *)asDisctionary {
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];

    body[OGAMonitorEventBodyTimestamp] = self.timestamp;
    body[OGAMonitorEventBodySessionId] = [self.sessionId lowercaseString];
    body[OGAMonitorEventBodyEventCode] = self.eventCode;
    body[OGAMonitorEventBodyEventName] = self.eventName;
    body[OGAMonitorEventBodyDispatchMethod] = [self stringFromDispatchType:self.dispatchType];

    NSError *err;
    NSData *jsonData;
    if (self.details) {
        jsonData = [NSJSONSerialization dataWithJSONObject:self.details options:0 error:&err];
        if (!err && jsonData != nil) {
            body[OGAMonitorEventBodyDetails] = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    }

    if (self.errorType && self.errorContent) {
        body[OGAMonitorEventBodyError] = [[NSMutableDictionary alloc] init];
        body[OGAMonitorEventBodyError][OGAMonitorEventBodyErrorType] = self.errorType;

        err = nil;
        jsonData = [NSJSONSerialization dataWithJSONObject:self.errorContent options:0 error:&err];
        if (!err && jsonData != nil) {
            body[OGAMonitorEventBodyError][OGAMonitorEventBodyErrorContent] = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    }

    return body;
}

- (NSString *)stringFromDispatchType:(OGMDispatchType)dispatchType {
    return dispatchType == OGMDispatchTypeDeferred ? OGAMonitorEventBodyDispatchMethodDeferred : OGAMonitorEventBodyDispatchMethodImmediate;
}

- (OGMDispatchType)stringTodispatchType:(NSString *)str {
    return str == OGAMonitorEventBodyDispatchMethodDeferred ? OGMDispatchTypeDeferred : OGMDispatchTypeImmediate;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.timestamp forKey:OGAMonitorEventBodyTimestamp];
    [coder encodeObject:self.sessionId forKey:OGAMonitorEventBodySessionId];
    [coder encodeObject:self.eventCode forKey:OGAMonitorEventBodyEventCode];
    [coder encodeObject:self.eventName forKey:OGAMonitorEventBodyEventName];

    if (self.details) {
        [coder encodeObject:self.details forKey:OGAMonitorEventBodyDetails];
    }

    if (self.errorType && self.errorContent) {
        [coder encodeObject:self.errorType forKey:OGAMonitorEventBodyErrorType];
        [coder encodeObject:self.errorContent forKey:OGAMonitorEventBodyErrorContent];
    }
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    NSNumber *timestamp = [coder decodeObjectForKey:OGAMonitorEventBodyTimestamp];
    NSString *sessionId = [coder decodeObjectForKey:OGAMonitorEventBodySessionId];
    NSString *eventCode = [coder decodeObjectForKey:OGAMonitorEventBodyEventCode];
    NSString *eventName = [coder decodeObjectForKey:OGAMonitorEventBodyEventName];
    NSDictionary *details = [coder decodeObjectForKey:OGAMonitorEventBodyDetails];
    NSString *errorType = [coder decodeObjectForKey:OGAMonitorEventBodyErrorType];
    NSDictionary *errorContent = [coder decodeObjectForKey:OGAMonitorEventBodyErrorContent];

    return [self initEventWithTimestamp:timestamp
                              sessionId:sessionId
                              eventCode:eventCode
                              eventName:eventName
                           dispatchType:OGMDispatchTypeDeferred  // tracks are always deferred when they are not send immediately
                      detailsDictionary:details
                              errorType:errorType
                           errorContent:errorContent];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[OGMMonitorEvent class]] == NO) {
        return NO;
    }
    OGMMonitorEvent *event = (OGMMonitorEvent *)object;
    BOOL isEqual = [self.timestamp isEqual:event.timestamp] && [self.sessionId isEqual:event.sessionId] && [self.eventCode isEqual:event.eventCode] && [self.eventName isEqual:event.eventName] && self.dispatchType == event.dispatchType && ((self.details != nil || event.details != nil) ? [self.details isEqual:event.details] : YES) && ((self.errorType != nil || event.errorType != nil) ? [self.errorType isEqual:event.errorType] : YES) && ((self.errorContent != nil || event.errorContent != nil) ? [self.errorContent isEqual:event.errorContent] : YES);
    return isEqual;
}

@end

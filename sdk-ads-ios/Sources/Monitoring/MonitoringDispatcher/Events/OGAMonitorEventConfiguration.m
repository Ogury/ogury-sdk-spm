//
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import "OGAMonitorEventConfiguration.h"

@interface OGAMonitorEventConfiguration ()

@property(nonatomic, retain) NSString *eventCode;
@property(nonatomic, retain) NSString *eventName;
@property(nonatomic, retain, nullable) NSString *errorType;
@property(nonatomic, retain, nullable) NSString *errorDescription;
@property(nonatomic) OGAAdIdMask permissionMask;

@end

@implementation OGAMonitorEventConfiguration
- (instancetype)initWithEventCode:(NSString *)eventCode
                        eventName:(NSString *)eventName
                   permissionMask:(OGAAdIdMask)permissionMask {
    if (self = [super init]) {
        _eventCode = eventCode;
        _eventName = eventName;
        _errorType = nil;
        _errorDescription = nil;
        _permissionMask = permissionMask;
    }
    return self;
}

- (instancetype)initWithEventCode:(NSString *)eventCode
                        eventName:(NSString *)eventName
                        errorType:(NSString *)errorType
                 errorDescription:(NSString *)errorDescription
                   permissionMask:(OGAAdIdMask)permissionMask {
    if (self = [self initWithEventCode:eventCode eventName:eventName permissionMask:permissionMask]) {
        _errorType = errorType;
        _errorDescription = errorDescription;
    }
    return self;
}

@end

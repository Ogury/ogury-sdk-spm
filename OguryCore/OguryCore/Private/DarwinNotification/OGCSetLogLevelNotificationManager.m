//
//  Copyright © 2022 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGCSetLogLevelNotificationManager.h"
#import "OGCInternal.h"
#import "OGCLog.h"
#import "OguryLogLevel.h"

@interface OGCSetLogLevelNotificationManager()

@property (nonatomic, assign) CFNotificationCenterRef cFNotificationCenter;
@property (nonatomic, strong) OGCDarwinNotificationStringFormatter *stringFormatter;
@property (nonatomic, strong) OGCLog *log;

@end

@implementation OGCSetLogLevelNotificationManager

- (instancetype)init {
    return [self init:CFNotificationCenterGetDarwinNotifyCenter() stringFormatter:[[OGCDarwinNotificationStringFormatter alloc] init] log:OGCLog.shared];
}

- (instancetype)init:(CFNotificationCenterRef)cFNotificationCenter stringFormatter:(OGCDarwinNotificationStringFormatter *)stringFormatter log:(OGCLog *)log {
    if (self = [super init]) {
        _cFNotificationCenter = cFNotificationCenter;
        _stringFormatter = stringFormatter;
        _log = log;
    }
    return self;
}

- (void)dealloc {
    [self unregisterFromNotification];
}

- (void)registerToNotification {
    NSString *formattedString = [self.stringFormatter stringFromOGCDarwinNotificationIdentifier:OGCDarwinNotificationIdentifierLogAll];
    
    [self.log logMessageFormat:OguryLogLevelInfo format:@"Registered to darwin notification [%@]", formattedString];
    CFNotificationCenterAddObserver(self.cFNotificationCenter,
                                    (__bridge const void *)(self),
                                    ogcNotificationCallback,
                                    (__bridge CFStringRef)formattedString,    // the only string data shared by darwin notification
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately); // last 2 parameters are ignored when the notification center is a Darwin notification center
}

- (void)unregisterFromNotification {
    NSString *formattedString = [self.stringFormatter stringFromOGCDarwinNotificationIdentifier:OGCDarwinNotificationIdentifierLogAll];

    [self.log logMessageFormat:OguryLogLevelInfo format:@"Unregistered darwin notification [%@]", formattedString];
    CFNotificationCenterRemoveObserver(self.cFNotificationCenter, (__bridge const void *)(self), (__bridge CFStringRef)formattedString, NULL);
}

void ogcNotificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name,  void const *object, CFDictionaryRef userInfo) {
    [[OGCInternal shared] setLogLevel:OguryLogLevelAll];
}

@end

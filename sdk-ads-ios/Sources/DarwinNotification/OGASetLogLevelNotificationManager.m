//
//  Copyright © 2022 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGASetLogLevelNotificationManager.h"
#import "OGALog.h"
#import "OGAInternal.h"

@interface OGASetLogLevelNotificationManager ()

@property(nonatomic, assign) CFNotificationCenterRef cFNotificationCenter;
@property(nonatomic, strong) OGADarwinNotificationStringFormatter *stringFormatter;
@property(nonatomic, strong) OGALog *log;

@end

@implementation OGASetLogLevelNotificationManager

- (instancetype)init {
    return [self init:CFNotificationCenterGetDarwinNotifyCenter() stringFormatter:[[OGADarwinNotificationStringFormatter alloc] init] log:OGALog.shared];
}

- (instancetype)init:(CFNotificationCenterRef)cFNotificationCenter stringFormatter:(OGADarwinNotificationStringFormatter *)stringFormatter log:(OGALog *)log {
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
    NSString *formattedString = [self.stringFormatter stringFromOGADarwinNotificationIdentifier:OGADarwinNotificationIdentifierLogAll];

    [self.log logFormat:OguryLogLevelInfo format:@"Registered to darwin notification [%@]", formattedString];
    CFNotificationCenterAddObserver(self.cFNotificationCenter,
                                    (__bridge const void *)(self),
                                    ogaNotificationCallback,
                                    (__bridge CFStringRef)formattedString,  // the only string data shared by darwin notification
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);  // last 2 parameters are ignored when the notification center is a Darwin notification center
}

- (void)unregisterFromNotification {
    NSString *formattedString = [self.stringFormatter stringFromOGADarwinNotificationIdentifier:OGADarwinNotificationIdentifierLogAll];

    [self.log logFormat:OguryLogLevelInfo format:@"Unregistered darwin notification [%@]", formattedString];
    CFNotificationCenterRemoveObserver(self.cFNotificationCenter, (__bridge const void *)(self), (__bridge CFStringRef)formattedString, NULL);
}

void ogaNotificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, void const *object, CFDictionaryRef userInfo) {
    [[OGAInternal shared] setLogLevel:OguryLogLevelAll];
}

@end

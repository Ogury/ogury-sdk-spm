//
//  Copyright © 2022 Ogury. All rights reserved.
//

#import "OGWSetLogLevelNotificationManager.h"
#import <Foundation/Foundation.h>
#import "OGWLog.h"
#import "Ogury.h"

@interface OGWSetLogLevelNotificationManager ()

@property(nonatomic, assign) CFNotificationCenterRef cFNotificationCenter;
@property(nonatomic, strong) OGWDarwinNotificationStringFormatter *stringFormatter;

@end

@implementation OGWSetLogLevelNotificationManager

- (instancetype)init {
   return [self init:CFNotificationCenterGetDarwinNotifyCenter() stringFormatter:[[OGWDarwinNotificationStringFormatter alloc] init]];
}

- (instancetype)init:(CFNotificationCenterRef)cFNotificationCenter stringFormatter:(OGWDarwinNotificationStringFormatter *)stringFormatter {
   if (self = [super init]) {
      _cFNotificationCenter = cFNotificationCenter;
      _stringFormatter = stringFormatter;
   }
   return self;
}

- (void)dealloc {
   [self unregisterFromNotification];
}

- (void)registerToNotification {
   NSString *formattedString = [self.stringFormatter stringFromOGWDarwinNotificationIdentifier:OGWDarwinNotificationIdentifierLogAll];

    [[OGWLog shared] log:OguryLogLevelInfo message:[NSString stringWithFormat:@"Registered to darwin notification [%@]", formattedString]];
   CFNotificationCenterAddObserver(self.cFNotificationCenter,
                                   (__bridge const void *)(self),
                                   ogwNotificationCallback,
                                   (__bridge CFStringRef)formattedString,  // the only string data shared by darwin notification
                                   NULL,
                                   CFNotificationSuspensionBehaviorDeliverImmediately);  // last 2 parameters are ignored when the notification center is a Darwin notification center
}

- (void)unregisterFromNotification {
   NSString *formattedString = [self.stringFormatter stringFromOGWDarwinNotificationIdentifier:OGWDarwinNotificationIdentifierLogAll];
    [[OGWLog shared] log:OguryLogLevelInfo message:[NSString stringWithFormat:@"Unregistered darwin notification [%@]", formattedString]];
   CFNotificationCenterRemoveObserver(self.cFNotificationCenter, (__bridge const void *)(self), (__bridge CFStringRef)formattedString, NULL);
}

void ogwNotificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, void const *object, CFDictionaryRef userInfo) {
   [Ogury setLogLevel:OguryLogLevelAll];
}

@end

//
//  Copyright © 2022 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGCLog.h"
#import "OguryLogLevel.h"
#import "OGCDarwinNotificationStringFormatter.h"

@interface OGCDarwinNotificationStringFormatter ()

#pragma mark - Properties

@property (nonatomic, strong) OGCLog *log;

@end

@implementation OGCDarwinNotificationStringFormatter

- (instancetype)init {
    return [self init:[OGCLog shared]];
}

- (instancetype)init:(OGCLog *)log {
    if (self = [super init]) {
        _log = log;
    }
    return self;
}

- (NSString *)identifierToString:(OGCDarwinNotificationIdentifier)identifier  {
    switch (identifier) {
        case OGCDarwinNotificationIdentifierLogAll:
            return @"all";
        default:
            [self.log logMessage:OguryLogLevelError message:@"notification identifier not correctly converted"];
            return @"Error";
    }
}

- (NSString *)stringFromOGCDarwinNotificationIdentifier:(OGCDarwinNotificationIdentifier)identifier {
    return [[NSString alloc] initWithFormat:@"%@.co.ogury.core.loglevel.%@", NSBundle.mainBundle. bundleIdentifier, [self identifierToString:identifier]];
}

@end

//
//  Copyright © 2022 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGALog.h"
#import "OGADarwinNotificationStringFormatter.h"

@interface OGADarwinNotificationStringFormatter ()

#pragma mark - Properties

@property(nonatomic, strong) OGALog *log;

@end

@implementation OGADarwinNotificationStringFormatter

- (instancetype)init {
    return [self init:[OGALog shared]];
}

- (instancetype)init:(OGALog *)log {
    if (self = [super init]) {
        _log = log;
    }
    return self;
}

- (NSString *)identifierToString:(OGADarwinNotificationIdentifier)identifier {
    switch (identifier) {
        case OGADarwinNotificationIdentifierLogAll:
            return @"all";
        default:
            [self.log log:OguryLogLevelError message:@"notification identifier not correctly converted"];
            return @"Error";
    }
}

- (NSString *)stringFromOGADarwinNotificationIdentifier:(OGADarwinNotificationIdentifier)identifier {
    return [[NSString alloc] initWithFormat:@"%@.co.ogury.OguryAds.loglevel.%@", NSBundle.mainBundle.bundleIdentifier, [self identifierToString:identifier]];
}

@end

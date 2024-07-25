//
//  Copyright © 2022 Ogury. All rights reserved.
//

#import "OGWDarwinNotificationStringFormatter.h"
#import <Foundation/Foundation.h>
#import "OGWLog.h"

@interface OGWDarwinNotificationStringFormatter ()

@end

@implementation OGWDarwinNotificationStringFormatter

- (NSString *)identifierToString:(OGWDarwinNotificationIdentifier)identifier {
   switch (identifier) {
      case OGWDarwinNotificationIdentifierLogAll:
         return @"all";
      default:
         [[OGWLog shared] log:OguryLogLevelError message:@"notification identifier not correctly converted"];
         return @"Error";
   }
}

- (NSString *)stringFromOGWDarwinNotificationIdentifier:(OGWDarwinNotificationIdentifier)identifier {
   return [[NSString alloc] initWithFormat:@"%@.co.ogury.loglevel.%@", NSBundle.mainBundle.bundleIdentifier, [self identifierToString:identifier]];
}

@end

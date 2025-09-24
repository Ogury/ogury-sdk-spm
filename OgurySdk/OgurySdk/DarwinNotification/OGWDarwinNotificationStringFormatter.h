//
//  Copyright © 2022 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, OGWDarwinNotificationIdentifier) {
    OGWDarwinNotificationIdentifierLogAll = 0,
};

NS_ASSUME_NONNULL_BEGIN

@interface OGWDarwinNotificationStringFormatter : NSObject

- (NSString *)stringFromOGWDarwinNotificationIdentifier:(OGWDarwinNotificationIdentifier)identifier;

@end

NS_ASSUME_NONNULL_END

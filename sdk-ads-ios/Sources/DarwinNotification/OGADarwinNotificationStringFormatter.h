//
//  Copyright © 2022 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, OGADarwinNotificationIdentifier) {
    OGADarwinNotificationIdentifierLogAll = 0,
};

NS_ASSUME_NONNULL_BEGIN

@interface OGADarwinNotificationStringFormatter : NSObject

- (NSString *)stringFromOGADarwinNotificationIdentifier:(OGADarwinNotificationIdentifier)identifier;

@end

NS_ASSUME_NONNULL_END

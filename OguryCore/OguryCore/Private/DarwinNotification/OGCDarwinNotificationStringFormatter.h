//
//  Copyright © 2022 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryStringFormattable.h>

typedef NS_ENUM(NSInteger, OGCDarwinNotificationIdentifier) {
    OGCDarwinNotificationIdentifierLogAll = 0,
};

NS_ASSUME_NONNULL_BEGIN

@interface OGCDarwinNotificationStringFormatter : NSObject

- (NSString *)stringFromOGCDarwinNotificationIdentifier:(OGCDarwinNotificationIdentifier)identifier;

@end

NS_ASSUME_NONNULL_END

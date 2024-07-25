//
//  Copyright © 2022 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGWDarwinNotificationStringFormatter.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGWSetLogLevelNotificationManager : NSObject

- (void)registerToNotification;
- (void)unregisterFromNotification;

@end

NS_ASSUME_NONNULL_END

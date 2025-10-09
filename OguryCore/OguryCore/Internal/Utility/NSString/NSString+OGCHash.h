//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (OGCHash)

- (NSString *)oguryCoreSha256HashWithSalt:(NSString *)salt;
+ (NSString *)oguryCoreRandomSaltOfSize:(int)length;

@end

NS_ASSUME_NONNULL_END

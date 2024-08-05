//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdIdentifierService : NSObject

+ (NSString *)getAdIdentifier;
+ (NSString *)getVendorIdentifier;
+ (NSString *)getInstanceToken;
+ (BOOL)isAdOptin;
+ (BOOL)isFakeAaid;
+ (NSString *)getUserAgent;
+ (void)updateInstanceToken;

@end

NS_ASSUME_NONNULL_END

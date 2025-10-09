//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGCAdIdentifierPrivacyLayer : NSObject

#pragma mark - Methods

- (NSString *)adIdentifier;

- (NSString *)vendorIdentifier;

- (NSString *)generateToken;

- (BOOL)isEmptyIDFA;

@end

NS_ASSUME_NONNULL_END

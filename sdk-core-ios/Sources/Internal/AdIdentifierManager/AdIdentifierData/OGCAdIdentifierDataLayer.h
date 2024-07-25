//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGCAdIdentifierDataLayer : NSObject

#pragma mark - Methods

- (void)resetPrivacyDefaults;

- (BOOL)isInstanceTokenStored;

- (NSData *)getInstanceToken;

- (void)storeInstanceToken:(NSData *)instanceToken;

- (BOOL)isConsentTokenStored;

- (NSData *)getConsentToken;

- (void)storeConsentToken:(NSData *)consentToken;

- (void)removeOldProfigParam;

- (void)migrateDeprecatedOGYDeviceSettingsWithInstanceTokenID:(NSString *)instanceTokenID;

@end

NS_ASSUME_NONNULL_END

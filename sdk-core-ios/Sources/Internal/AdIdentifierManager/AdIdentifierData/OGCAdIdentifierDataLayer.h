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

- (void)removeOldProfigParam;

- (void)migrateDeprecatedOGYDeviceSettingsWithInstanceTokenID:(NSString *)instanceTokenID;

- (NSData *)getGPPConsentString;

- (NSData *)getGPPSID;

- (NSData *)getTCFConsentString;

- (void)storePrivacyData:(NSString *)key boolean:(BOOL)value;

- (void)storePrivacyData:(NSString *)key integer:(NSInteger)value;

- (void)storePrivacyData:(NSString *)key string:(NSString *)value;

@end

NS_ASSUME_NONNULL_END

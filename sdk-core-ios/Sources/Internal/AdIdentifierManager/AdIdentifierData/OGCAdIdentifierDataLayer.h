//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGCConsentChangedDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGCAdIdentifierDataLayer : NSObject

@property (nonatomic, weak) id<OGCConsentChangedDelegate> consentChangedDelegate;

#pragma mark - Methods

- (void)resetPrivacyDefaults;

- (BOOL)isInstanceTokenStored;

- (NSData *)getInstanceToken;

- (void)storeInstanceToken:(NSData *)instanceToken;

- (void)removeOldProfigParam;

- (void)migrateDeprecatedOGYDeviceSettingsWithInstanceTokenID:(NSString *)instanceTokenID;

- (NSString *)getGPPConsentString;

- (NSString *)getGPPSID;

- (NSString *)getTCFConsentString;

- (void)storePrivacyData:(id)value forKey:(NSString *)key;

- (NSDictionary<NSString *, id> *)retrieveDataPrivacy;

@end

NS_ASSUME_NONNULL_END

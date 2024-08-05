//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGCAdIdentifierManager : NSObject

#pragma mark - Methods

- (NSString *)getAdIdentifier;

- (NSString *)getVendorIdentifier;

- (NSString *)getInstanceToken;

- (NSString *)getConsentToken;

- (NSString * _Nullable) retrieveGPPConsentString;

- (NSString * _Nullable) retrieveGPPSID;

- (NSString * _Nullable) retrieveTCFConsentString;

- (void)migrateDeprecatedUserDefaultKeys;

- (void)removeDeprecatedProfigUserDefaultKeys;

- (BOOL)isAdOptin;

- (void)updateInstanceToken;

- (void)updateConsentToken;

@end

NS_ASSUME_NONNULL_END

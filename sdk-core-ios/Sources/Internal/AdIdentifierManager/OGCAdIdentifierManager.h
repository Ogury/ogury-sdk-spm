//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGCConsentChangedDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGCAdIdentifierManager : NSObject

@property (nonatomic, weak) id<OGCConsentChangedDelegate> consentChangedDelegate;

#pragma mark - Methods

- (NSString *)getAdIdentifier;

- (NSString *)getVendorIdentifier;

- (NSString *)getInstanceToken;

- (NSString * _Nullable)retrieveGPPConsentString;

- (NSString * _Nullable)retrieveGPPSID;

- (NSString * _Nullable)retrieveTCFConsentString;

- (void)migrateDeprecatedUserDefaultKeys;

- (void)removeDeprecatedProfigUserDefaultKeys;

- (BOOL)isAdOptin;

- (void)updateInstanceToken;

- (void)storePrivacyData:(NSString *)key boolean:(BOOL)value;

- (void)storePrivacyData:(NSString *)key integer:(NSInteger)value;

- (void)storePrivacyData:(NSString *)key string:(NSString *)value;

- (NSDictionary *)retrivedDataPrivacy;

@end

NS_ASSUME_NONNULL_END

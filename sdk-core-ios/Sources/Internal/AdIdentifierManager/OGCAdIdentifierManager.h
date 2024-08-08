//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGCDelegateConsentChanged.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGCAdIdentifierManager : NSObject

@property (nonatomic, weak) id<OGCDelegateConsentChanged> delegateConsentChanged;

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

@end

NS_ASSUME_NONNULL_END

//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, OguryLogLevel);

typedef enum : NSUInteger {
    OGCSDKTypeNative = 0,
    OGCSDKTypeUnity,
    OGCSDKTypeCordova,
    OGCSDKTypeXamarin,
    OGCSDKTypeAdobeAir,
    OGCSDKEnumCount
} OGCSDKType;

NS_ASSUME_NONNULL_BEGIN

@interface OGCInternal : NSObject

+ (instancetype)shared;
- (void)setLogLevel:(OguryLogLevel)logLevel;
- (NSString *)getVersion;
- (NSString *)getAdIdentifier;
- (NSString *)getVendorIdentifier;
- (NSString *)getInstanceToken;
- (OGCSDKType)getFrameworkType;
- (void)updateInstanceToken;
- (BOOL)isAdOptin;
- (NSString * _Nullable) retrieveGPPConsentString;
- (NSString * _Nullable) retrieveGPPSID;
- (NSString * _Nullable) retrieveTCFConsentString;
- (void)storePrivacyData:(NSString *)key boolean:(BOOL)value;
- (void)storePrivacyData:(NSString *)key integer:(NSInteger)value;
- (void)storePrivacyData:(NSString *)key string:(NSString *)value;
- (NSDictionary<NSString *, id> *)retrieveDataPrivacy;

@end

NS_ASSUME_NONNULL_END

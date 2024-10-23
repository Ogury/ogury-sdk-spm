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
- (BOOL)isAdOptin;
- (NSString * _Nullable) gppConsentString;
- (NSString * _Nullable) gppSID;
- (NSString * _Nullable) tcfConsentString;
- (void)setPrivacyData:(NSString *)key boolean:(BOOL)value;
- (void)setPrivacyData:(NSString *)key integer:(NSInteger)value;
- (void)setPrivacyData:(NSString *)key string:(NSString *)value;
- (NSDictionary<NSString *, id> *)retrieveDataPrivacy;

@end

NS_ASSUME_NONNULL_END

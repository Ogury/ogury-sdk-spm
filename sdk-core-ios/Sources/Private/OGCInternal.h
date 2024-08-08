//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGCDelegateConsentChanged.h"

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

@property (nonatomic, weak) id<OGCDelegateConsentChanged> delegateConsentChanged;

+ (instancetype)shared;
- (void)setLogLevel:(OguryLogLevel)logLevel;
- (NSString *)getVersion;
- (NSString *)getAdIdentifier;
- (NSString *)getVendorIdentifier;
- (NSString *)getInstanceToken;
- (OGCSDKType)getFrameworkType;
- (void)updateInstanceToken;
- (BOOL)isAdOptin;
- (void)storePrivacyData:(NSString *)key boolean:(BOOL)value;
- (void)storePrivacyData:(NSString *)key integer:(NSInteger)value;
- (void)storePrivacyData:(NSString *)key string:(NSString *)value;

@end

NS_ASSUME_NONNULL_END

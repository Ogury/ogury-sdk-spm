//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import "OGCInternal.h"
#import "OGCUtils.h"
#import "OGCAdIdentifierManager.h"
#import "OGCLog.h"
#import "OguryLogLevel.h"
#import "OGCSetLogLevelNotificationManager.h"

@interface OGCInternal() <OGCDelegateConsentChanged>

@property (nonatomic, strong) OGCAdIdentifierManager *adIdentifierManager;
@property (nonatomic, strong) OGCLog *log;
@property (nonatomic, strong) OGCSetLogLevelNotificationManager *logNotificationManager;

@end

@implementation OGCInternal

- (id)initWithAdIdentifierManager:(OGCAdIdentifierManager *)adIdentifierManager log:(OGCLog *)log logNotificationManager:(OGCSetLogLevelNotificationManager *)logNotificationManager {
    if (self = [super init]) {
        _adIdentifierManager = adIdentifierManager;
        _adIdentifierManager.delegateConsentChanged = self;
        _log = log;
        _logNotificationManager = logNotificationManager;
        [_logNotificationManager registerToNotification];
    }
    return self;
}

- (id)init {
    OGCAdIdentifierManager *adIdentifierManager = [[OGCAdIdentifierManager alloc] init];
    return [self initWithAdIdentifierManager:adIdentifierManager log:[OGCLog shared] logNotificationManager:[[OGCSetLogLevelNotificationManager alloc] init]];
}

- (NSString *)getVersion {
    return SDK_VERSION;
}

+ (instancetype)shared {
    static OGCInternal *sharedInstance = nil;
    static dispatch_once_t token;

    dispatch_once(&token, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance.adIdentifierManager removeDeprecatedProfigUserDefaultKeys];
        [sharedInstance.adIdentifierManager migrateDeprecatedUserDefaultKeys];
    });
    
    return sharedInstance;
}

- (void)setLogLevel:(OguryLogLevel)logLevel {
    [self.log setLogLevel:logLevel];
}

- (NSString *)getAdIdentifier {
    return [self.adIdentifierManager getAdIdentifier];
}

- (NSString *)getVendorIdentifier {
    return [self.adIdentifierManager getVendorIdentifier];
}

- (NSString *)getInstanceToken {
    return [self.adIdentifierManager getInstanceToken];
}

- (BOOL)isAdOptin {
    return [self.adIdentifierManager isAdOptin];
}

- (void)updateInstanceToken {
    [self.adIdentifierManager updateInstanceToken];
}

- (OGCSDKType)getFrameworkType {
    return [OGCUtils getFrameworkType];
}

- (void)consentChanged { 
   if ([self.delegateConsentChanged respondsToSelector:@selector(consentChanged)]) {
      [self.delegateConsentChanged consentChanged];
   }
}

- (void)dataPrivacyChanged:(NSString *)key integer:(NSInteger *)value {
   if ([self.delegateConsentChanged respondsToSelector:@selector(dataPrivacyChanged:integer:)]) {
      [self.delegateConsentChanged dataPrivacyChanged:key integer:value];
   }
}

- (void)dataPrivacyChanged:(NSString *)key boolean:(BOOL)value{
   if ([self.delegateConsentChanged respondsToSelector:@selector(dataPrivacyChanged:boolean:)]) {
      [self.delegateConsentChanged dataPrivacyChanged:key boolean:value];
   }
}

- (void)dataPrivacyChanged:(NSString *)key string:(NSString *)value{
   if ([self.delegateConsentChanged respondsToSelector:@selector(dataPrivacyChanged:string:)]) {
      [self.delegateConsentChanged dataPrivacyChanged:key string:value];
   }
}

- (void)storePrivacyData:(NSString *)key boolean:(BOOL)value {
   [self.adIdentifierManager storePrivacyData:key boolean:value];
}

- (void)storePrivacyData:(NSString *)key integer:(NSInteger)value {
   [self.adIdentifierManager storePrivacyData:key integer:value];
}

- (void)storePrivacyData:(NSString *)key string:(NSString *)value {
   [self.adIdentifierManager storePrivacyData:key string:value];
}


@end

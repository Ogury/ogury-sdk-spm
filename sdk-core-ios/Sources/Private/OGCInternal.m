//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import "OGCInternal.h"
#import "OGCUtils.h"
#import "OGCAdIdentifierManager.h"
#import "OGCLog.h"
#import "OguryLogLevel.h"
#import "OGCSetLogLevelNotificationManager.h"

@interface OGCInternal()

@property (nonatomic, strong) OGCAdIdentifierManager *adIdentifierManager;
@property (nonatomic, strong) OGCLog *log;
@property (nonatomic, strong) OGCSetLogLevelNotificationManager *logNotificationManager;
- (void)updateInstanceToken;

@end

@implementation OGCInternal

- (id)initWithAdIdentifierManager:(OGCAdIdentifierManager *)adIdentifierManager log:(OGCLog *)log logNotificationManager:(OGCSetLogLevelNotificationManager *)logNotificationManager {
    if (self = [super init]) {
        _adIdentifierManager = adIdentifierManager;
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

- (OGCSDKType)frameworkType {
    return [OGCUtils frameworkType];
}

// GPP
- (NSString * _Nullable)gppConsentString {
    return [self.adIdentifierManager retrieveGPPConsentString];
}

- (NSString * _Nullable)gppSID {
    return [self.adIdentifierManager retrieveGPPSID];
}

- (NSString * _Nullable)tcfConsentString {
    return [self.adIdentifierManager retrieveTCFConsentString];
}

- (void)setPrivacyData:(NSString *)key boolean:(BOOL)value {
   [self.adIdentifierManager setPrivacyData:[NSNumber numberWithBool:value]  forKey:[key stringByAppendingString:@"_bool"]];
}

- (void)setPrivacyData:(NSString *)key integer:(NSInteger)value {
   [self.adIdentifierManager setPrivacyData:[NSNumber numberWithInteger:value] forKey:[key stringByAppendingString:@"_int"]];
}

- (void)setPrivacyData:(NSString *)key string:(NSString *)value {
   [self.adIdentifierManager setPrivacyData:value forKey:[key stringByAppendingString:@"_string"]];
}

- (NSDictionary<NSString *, id> *)retrieveDataPrivacy {
   return [self.adIdentifierManager retrieveDataPrivacy];
}

@end

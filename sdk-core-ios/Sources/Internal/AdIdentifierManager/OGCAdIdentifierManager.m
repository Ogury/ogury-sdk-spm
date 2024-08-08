//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import "OGCAdIdentifierManager.h"
#import "OGCAdIdentifierPrivacyLayer.h"
#import "OGCAdIdentifierDataLayer.h"
#import "NSString+OGCHash.h"
#import "OGCInstanceToken.h"
#import "OGCLog.h"
#import "OguryLogLevel.h"

@interface OGCAdIdentifierManager() <OGCDelegateConsentChanged>

#pragma mark - Properties

@property (nonatomic, strong) OGCAdIdentifierPrivacyLayer *privacyLayer;
@property (nonatomic, strong) OGCAdIdentifierDataLayer *dataLayer;
@property (nonatomic, strong) OGCInstanceToken *instanceToken;
@property (nonatomic, strong) NSProcessInfo *processInfo;
@property (nonatomic, strong) OGCLog *log;

@end

@interface OGCInstanceToken()

- (id)initWithInstanceToken:(NSString *)instanceTokenID andProcessInfo:(NSProcessInfo *)processInfo;

@end

@implementation OGCAdIdentifierManager

#pragma mark - Initialization

- (id)init {
    OGCAdIdentifierPrivacyLayer *privacyLayer = [[OGCAdIdentifierPrivacyLayer alloc] init];
    OGCAdIdentifierDataLayer *dataLayer = [[OGCAdIdentifierDataLayer alloc] init];
    return [self initWithPrivacyLayer:privacyLayer andDataLayer:dataLayer andProcessInfo:[NSProcessInfo processInfo] log:[OGCLog shared]];
}

- (id)initWithPrivacyLayer:(OGCAdIdentifierPrivacyLayer *)privacyLayer andDataLayer:(OGCAdIdentifierDataLayer *)dataLayer andProcessInfo:(NSProcessInfo *)processInfo log:(OGCLog *)log {
    if (self = [super init]) {
        _privacyLayer = privacyLayer;
        _dataLayer = dataLayer;
        _dataLayer.delegateConsentChanged = self;
        _processInfo = processInfo;
        _instanceToken = [self createInstanceTokenWithProcessInfo:processInfo];
        _log = log;
    }

    return self;
}

#pragma mark - Methods

- (OGCInstanceToken *)createInstanceTokenWithProcessInfo:(NSProcessInfo *)processInfo {
    NSString *adIdentifierFromDevice = [self.privacyLayer adIdentifier];
    if (![self.dataLayer isInstanceTokenStored]) {
        OGCInstanceToken *generatedInstanceToken = [self generateNewInstanceTokenWithProcessInfo:processInfo andIdentifier:adIdentifierFromDevice];
        [self.dataLayer storeInstanceToken:[NSKeyedArchiver archivedDataWithRootObject:generatedInstanceToken]];
        return generatedInstanceToken;
    } else {
        [NSKeyedUnarchiver setClass:[OGCInstanceToken class] forClassName:@"OGYInstanceToken"];
        OGCInstanceToken *storedInstanceToken = [NSKeyedUnarchiver unarchiveObjectWithData:[self.dataLayer getInstanceToken]];
        [storedInstanceToken updateIOSVersionWith:processInfo];
        [self.dataLayer storeInstanceToken:[NSKeyedArchiver archivedDataWithRootObject:storedInstanceToken]];
        return storedInstanceToken;
    }
}

- (OGCInstanceToken *)generateNewInstanceTokenWithProcessInfo:(NSProcessInfo *)processInfo andIdentifier:(NSString *)adIdentifier {
    OGCInstanceToken *generatedInstanceToken = [[OGCInstanceToken alloc] initWithInstanceToken:[self.privacyLayer generateToken] andProcessInfo:processInfo];
    return generatedInstanceToken;
}

- (void)migrateDeprecatedUserDefaultKeys {
    [self.dataLayer migrateDeprecatedOGYDeviceSettingsWithInstanceTokenID:[self getInstanceToken]];
}

- (void)removeDeprecatedProfigUserDefaultKeys {
    [self.dataLayer removeOldProfigParam];
}

- (NSString *)getAdIdentifier {
    return [self.privacyLayer adIdentifier];
}

- (NSString *)getVendorIdentifier {
    return [self.privacyLayer vendorIdentifier];
}

- (NSString * _Nullable) retrieveGPPConsentString {
   return [self stringFrom: [self.dataLayer getGPPConsentString]];
}

- (NSString * _Nullable) retrieveGPPSID {
   return [self stringFrom: [self.dataLayer getGPPSID]];
}

- (NSString * _Nullable) retrieveTCFConsentString {
   return [self stringFrom: [self.dataLayer getTCFConsentString]];
}

- (NSString * _Nullable)stringFrom:(NSData*)data {
   if (data == nil) {
      return nil;
   }
   NSString *gppSIDString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
   return gppSIDString;
}

- (NSString *)getInstanceToken {
    [NSKeyedUnarchiver setClass:[OGCInstanceToken class] forClassName:@"OGYInstanceToken"];
    OGCInstanceToken *storedInstanceToken = [NSKeyedUnarchiver unarchiveObjectWithData:[self.dataLayer getInstanceToken]];
    if (storedInstanceToken) {
        [self.dataLayer storeInstanceToken:[NSKeyedArchiver archivedDataWithRootObject:storedInstanceToken]];
        return storedInstanceToken.instanceTokenID;
    } else {
        self.instanceToken = [self createInstanceTokenWithProcessInfo:self.processInfo];
        return self.instanceToken.instanceTokenID;
    }
}

- (BOOL)isAdOptin {
    return ![self.privacyLayer isEmptyIDFA];
}

- (void)updateInstanceToken {
    self.instanceToken = [self createInstanceTokenWithProcessInfo:self.processInfo];
    [self.log logMessage:OguryLogLevelDebug message:@"Update instance token"];
}

- (void)consentChanged {
   if ([self.delegateConsentChanged respondsToSelector:@selector(consentChanged)]) {
      [self.delegateConsentChanged consentChanged];
   }
}

- (void)dataPrivacyChanged:(NSString *)key integer:(NSInteger)value {
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
   [self.dataLayer storePrivacyData:key boolean:value];
}

- (void)storePrivacyData:(NSString *)key integer:(NSInteger)value {
   [self.dataLayer storePrivacyData:key integer:value];
}

- (void)storePrivacyData:(NSString *)key string:(NSString *)value {
   [self.dataLayer storePrivacyData:key string:value];
}

@end

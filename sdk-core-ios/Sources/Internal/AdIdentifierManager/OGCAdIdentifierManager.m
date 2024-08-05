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

@interface OGCAdIdentifierManager()

#pragma mark - Properties

@property (nonatomic, strong) OGCAdIdentifierPrivacyLayer *privacyLayer;
@property (nonatomic, strong) OGCAdIdentifierDataLayer *dataLayer;
@property (nonatomic, strong) OGCInstanceToken *instanceToken;
@property (nonatomic, copy) NSString *consentToken;
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
   NSData *GPPConsentData = [self.dataLayer getGPPConsentString];
   if (GPPConsentData == nil) {
      return nil;
   }
   NSString *GPPConsentString = [[NSString alloc] initWithData:GPPConsentData encoding:NSUTF8StringEncoding];
   return GPPConsentString;
}

- (NSString * _Nullable) retrieveGPPSID {
   return [[NSString alloc] initWithData:[self.dataLayer getGPPSID] encoding:NSUTF8StringEncoding];
}

- (NSString * _Nullable) retrieveTCFConsentString {
   return [[NSString alloc] initWithData:[self.dataLayer getTCFConsentString] encoding:NSUTF8StringEncoding];
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

- (NSString *)getConsentToken {
    NSString *storedConsentToken = [[NSString alloc] initWithData:[self.dataLayer getConsentToken] encoding:NSUTF8StringEncoding];

    if (storedConsentToken && storedConsentToken.length > 0) {
        return storedConsentToken;
    }

    // Generate and store a new consent token
    self.consentToken = [self.privacyLayer generateToken];

    [self.dataLayer storeConsentToken:[self.consentToken dataUsingEncoding:NSUTF8StringEncoding]];

    return self.consentToken;
}

- (BOOL)isAdOptin {
    return ![self.privacyLayer isEmptyIDFA];
}

- (void)updateInstanceToken {
    self.instanceToken = [self createInstanceTokenWithProcessInfo:self.processInfo];
    [self.log logMessage:OguryLogLevelDebug message:@"Update instance token"];
}

- (void)updateConsentToken {
    self.consentToken = [self.privacyLayer generateToken];
    [self.log logMessage:OguryLogLevelDebug message:@"Update consent token"];
}


@end

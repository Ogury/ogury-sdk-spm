//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import "OGCAdIdentifierDataLayer.h"

#pragma mark - Constants

static NSString * const OGCInstanceTokenKey = @"OGURY_INSTANCE_TOKEN";
static NSString * const OGCConsentTokenKey = @"OGURY_CONSENT_TOKEN";
static NSString * const OGCLastProfigParamsKey = @"LastProfigParams";
static NSString * const OGCDeprecatedOGYDeviceSettingsKey = @"DeviceSettings";
static NSString * const OGCCMDeviceSettingsKey = @"OGYDeviceSettings";

static NSString * const OGCGPPConsentStringKey = @"IABGPP_HDR_GppString";
static NSString * const OGCGPPSIDKey = @"IABGPP_GppSID";
static NSString * const OGCTCStringKey = @"IABTCF_TCString";

@interface OGCAdIdentifierDataLayer()

#pragma mark - Properties

@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end

@implementation OGCAdIdentifierDataLayer

#pragma mark - Initialization

- (id)init {
    return [self initWithUserDefaults:NSUserDefaults.standardUserDefaults];
}

- (id)initWithUserDefaults:(NSUserDefaults *)userDefault {
    if (self = [super init]) {
        _userDefaults = userDefault;
    }
    
    return self;
}

#pragma mark - Methods

- (NSData *)dataForKey:(NSString *)key {
    return [self.userDefaults dataForKey:key];
}

- (BOOL)isKeyStored:(NSString *)key {
    return [[self.userDefaults dictionaryRepresentation].allKeys containsObject:key];
}

- (BOOL)isInstanceTokenStored {
    return [self isKeyStored:OGCInstanceTokenKey];
}

- (void)resetPrivacyDefaults {
    [self.userDefaults removeObjectForKey:OGCInstanceTokenKey];
    [self.userDefaults removeObjectForKey:OGCConsentTokenKey];
}

- (void)removeOldProfigParam {
    [self.userDefaults removeObjectForKey:OGCLastProfigParamsKey];
}

- (void)migrateDeprecatedOGYDeviceSettingsWithInstanceTokenID:(NSString *)instanceTokenID {
    id storedValue = [self.userDefaults objectForKey:OGCDeprecatedOGYDeviceSettingsKey];

    if (storedValue != nil && [storedValue isKindOfClass:[NSData class]]) {
        NSData *data = storedValue;
        NSError *error = nil;

        id object = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

        if (error) {
            return;
        } else if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *deprecatedDeviceSettings = object;
            if (deprecatedDeviceSettings[@"advertisingId"]  && deprecatedDeviceSettings[@"locale"] && deprecatedDeviceSettings[@"assetKey"] && deprecatedDeviceSettings[@"bundleId"] && [[deprecatedDeviceSettings allKeys] count] == 4){
                NSDictionary *deviceSettings = [NSDictionary dictionaryWithObjects:@[deprecatedDeviceSettings[@"bundleId"],deprecatedDeviceSettings[@"locale"],deprecatedDeviceSettings[@"assetKey"],instanceTokenID] forKeys:@[@"bundleId",@"locale",@"assetKey",@"instanceTokenId"]];
                NSError *jsonError = nil;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:deviceSettings options:kNilOptions error:&jsonError];
                [self.userDefaults setObject:jsonData forKey:OGCCMDeviceSettingsKey];
                [self.userDefaults removeObjectForKey:OGCDeprecatedOGYDeviceSettingsKey];
            }
        }
    }
}

- (NSData *)getInstanceToken {
    return [self dataForKey:OGCInstanceTokenKey];
}

- (NSData *)getConsentToken {
    return [self dataForKey:OGCConsentTokenKey];
}

- (NSData *)getGPPConsentString {
   return [self dataForKey:OGCGPPConsentStringKey];
}

- (NSData *)getGPPSID {
   return [self dataForKey:OGCGPPSIDKey];
}

- (NSData *)getTCFConsentString {
   return [self dataForKey:OGCTCStringKey];
}

- (void)storePrivacyData:(NSString *)key boolean:(BOOL)value {
   [self.userDefaults setBool:value forKey:key];
}

- (void)storePrivacyData:(NSString *)key integer:(NSInteger)value {
   [self.userDefaults setInteger:value forKey:key];
}

- (void)storePrivacyData:(NSString *)key string:(NSString *)value {
   [self.userDefaults setValue:value forKey:key];
}

- (void)storeInstanceToken:(NSData *)instanceToken {
    [self storeData:instanceToken key:OGCInstanceTokenKey];
}

- (void)storeConsentToken:(NSData *)consentToken {
    [self storeData:consentToken key:OGCConsentTokenKey];
}

- (void)storeData:(NSData *)data key:(NSString *)key {
    [self.userDefaults setObject:data forKey:key];
}

@end

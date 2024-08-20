//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import "OGCAdIdentifierDataLayer.h"

#pragma mark - Constants

static NSString * const OGCInstanceTokenKey = @"OGURY_INSTANCE_TOKEN";
static NSString * const OGCLastProfigParamsKey = @"LastProfigParams";
static NSString * const OGCDeprecatedOGYDeviceSettingsKey = @"DeviceSettings";
static NSString * const OGCCMDeviceSettingsKey = @"OGYDeviceSettings";

static NSString * const OGCGPPConsentStringKey = @"IABGPP_HDR_GppString";
static NSString * const OGCGPPSIDKey = @"IABGPP_GppSID";
static NSString * const OGCTCStringKey = @"IABTCF_TCString";

static NSString * const OGCPrefixKey = @"OGY-";
static NSString * const OGCDataPrivacyKey = @"OGY-PrivacyDataKeys";
static NSString * const OGCHashConsentKey = @"OGY-HashConsentKeys";

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
        [_userDefaults addObserver:self forKeyPath:OGCGPPConsentStringKey options:NSKeyValueObservingOptionNew context:NULL];
        [_userDefaults addObserver:self forKeyPath:OGCGPPSIDKey options:NSKeyValueObservingOptionNew context:NULL];
        [_userDefaults addObserver:self forKeyPath:OGCTCStringKey options:NSKeyValueObservingOptionNew context:NULL];
        [_userDefaults synchronize];
        [self checkChangeOfConsent];
    }
    
    return self;
}

- (void)deinit{
   [_userDefaults removeObserver:self forKeyPath:OGCGPPConsentStringKey];
   [_userDefaults removeObserver:self forKeyPath:OGCGPPSIDKey];
   [_userDefaults removeObserver:self forKeyPath:OGCTCStringKey];
}

#pragma mark - Methods

- (NSData *)globalConsentData {
   NSData *gppData = [[self.userDefaults objectForKey:OGCGPPConsentStringKey] dataUsingEncoding:NSUTF8StringEncoding];
   NSData *sidData = [[self.userDefaults objectForKey:OGCGPPSIDKey] dataUsingEncoding:NSUTF8StringEncoding];
   NSData *tcfData = [[self.userDefaults objectForKey:OGCTCStringKey] dataUsingEncoding:NSUTF8StringEncoding];
   NSDictionary *privacy = [self retrieveDataPrivacy];
   NSData *privacyData = [NSKeyedArchiver archivedDataWithRootObject:privacy];
   NSMutableData *globalConsentData = [[NSMutableData alloc] init];
   [globalConsentData appendData:gppData];
   [globalConsentData appendData:sidData];
   [globalConsentData appendData:tcfData];
   if (privacy.allKeys.count > 0) {
      [globalConsentData appendData:privacyData];
   }
   return globalConsentData;
}

- (void)checkChangeOfConsent {
   NSData *hashConsent = [self dataForKey:OGCHashConsentKey];
   NSData *globalConsentData = [self globalConsentData];
   if ([hashConsent isEqual:globalConsentData] || (globalConsentData.length == 0 && hashConsent.length == 0 )) {
      return;
   }
   
   [self.userDefaults setObject:globalConsentData forKey:OGCHashConsentKey];
   if ([self.consentChangedDelegate respondsToSelector:@selector(consentChanged)]) {
      [self.consentChangedDelegate consentChanged];
   }
}

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

- (NSString *)getGPPConsentString {
   return [self.userDefaults objectForKey:OGCGPPConsentStringKey];
}

- (NSString *)getGPPSID {
   return [self.userDefaults objectForKey:OGCGPPSIDKey];
}

- (NSData *)getTCFConsentString {
   return [self.userDefaults objectForKey:OGCTCStringKey];
}

- (void)storePrivacyData:(id)value forKey:(NSString *)key; {
   [self.userDefaults setValue:value forKey:[OGCPrefixKey stringByAppendingString: key]];
   [self addPrivacyDataKey:key];
   if ([self.consentChangedDelegate respondsToSelector:@selector(dataPrivacyChanged:boolean:)]) {
      [self.consentChangedDelegate dataPrivacyChanged:key boolean:value];
   }
}

- (void)addPrivacyDataKey:(NSString *)key {
   if ([[self.userDefaults objectForKey:OGCDataPrivacyKey] isKindOfClass:[NSArray class]]) {
      NSArray<NSString *> *dataPrivacyKeys = [self.userDefaults objectForKey:OGCDataPrivacyKey];
      if (![dataPrivacyKeys containsObject:key]) {
         NSMutableArray *dataPrivacyKeysMutable =  [dataPrivacyKeys mutableCopy];
         [dataPrivacyKeysMutable addObject:key];
         [self.userDefaults setObject:dataPrivacyKeysMutable forKey:OGCDataPrivacyKey];
      }
      return;
   }
   [self.userDefaults setObject:@[key] forKey:OGCDataPrivacyKey];
}

- (NSDictionary<NSString *, id> *)retrieveDataPrivacy {
   NSMutableDictionary *dataPrivacy = [NSMutableDictionary new];
   NSArray *dataPrivacyKeys = [self.userDefaults objectForKey:OGCDataPrivacyKey];
   for (NSString *key in dataPrivacyKeys) {
      dataPrivacy[key] = [self.userDefaults objectForKey:[OGCPrefixKey stringByAppendingString: key]];
   }
   return dataPrivacy;
}

- (void)storeInstanceToken:(NSData *)instanceToken {
    [self storeData:instanceToken key:OGCInstanceTokenKey];
}

- (void)storeData:(NSData *)data key:(NSString *)key {
    [self.userDefaults setObject:data forKey:key];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
   if ([self.consentChangedDelegate respondsToSelector:@selector(consentChanged)]) {
      [self.consentChangedDelegate consentChanged];
   }
}

@end

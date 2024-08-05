//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import "OGCAdIdentifierDataLayer.h"

#pragma mark - Constants

static NSString * const OGCInstanceTokenKey = @"OGURY_INSTANCE_TOKEN";
static NSString * const OGCLastProfigParamsKey = @"LastProfigParams";
static NSString * const OGCDeprecatedOGYDeviceSettingsKey = @"DeviceSettings";
static NSString * const OGCCMDeviceSettingsKey = @"OGYDeviceSettings";

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

- (void)storeInstanceToken:(NSData *)instanceToken {
    [self storeData:instanceToken key:OGCInstanceTokenKey];
}

- (void)storeData:(NSData *)data key:(NSString *)key {
    [self.userDefaults setObject:data forKey:key];
}

@end

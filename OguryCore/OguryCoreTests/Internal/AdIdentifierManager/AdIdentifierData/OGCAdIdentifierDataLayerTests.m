//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGCAdIdentifierDataLayer.h"
#import "OGCNSUserDefaultsMock.h"

static NSString * const OguryInstanceTokenKey = @"OGURY_INSTANCE_TOKEN";

@interface OGCAdIdentifierDataLayerTests : XCTestCase

@property (nonatomic, strong) OGCNSUserDefaultsMock *mockedUserDefault;

@end

@interface OGCAdIdentifierDataLayer()

- (id)initWithUserDefaults:(NSUserDefaults *)userDefault;
- (NSData *)globalConsentData;
- (void)checkChangeOfConsent;

@end

@implementation OGCAdIdentifierDataLayerTests

static NSString *instanceToken = @"00000000-1111-3333-1598-000000000000";
static NSString *NoIDFA = @"00000000-0000-0000-0000-000000000000";

- (void)setUp {
    self.mockedUserDefault = [[OGCNSUserDefaultsMock alloc] init];
}

- (void)tearDown {
    self.mockedUserDefault = nil;
}

- (void)testStoreInstanceToken {
    OGCAdIdentifierDataLayer *dataLayer = [[OGCAdIdentifierDataLayer alloc] initWithUserDefaults:self.mockedUserDefault];
    void *bytes = malloc(10);
    NSData *data = [NSData dataWithBytes:bytes length:10];
    [dataLayer storeInstanceToken:data];
    NSData *token = [self.mockedUserDefault.dict objectForKey:OguryInstanceTokenKey];
    XCTAssertNotNil(token);
    XCTAssertEqualObjects(token, data);
    free(bytes);
}

- (void)testIsInstanceTokenStored {
    OGCAdIdentifierDataLayer *dataLayer = [[OGCAdIdentifierDataLayer alloc] initWithUserDefaults:self.mockedUserDefault];
    XCTAssertFalse([dataLayer isInstanceTokenStored]);
    [self.mockedUserDefault.dict setObject:NoIDFA forKey:OguryInstanceTokenKey];
    XCTAssertTrue([dataLayer isInstanceTokenStored]);
}

- (void)testResetPrivacyDefaults {
    OGCAdIdentifierDataLayer *dataLayer = [[OGCAdIdentifierDataLayer alloc] initWithUserDefaults:self.mockedUserDefault];
    XCTAssertEqual([self.mockedUserDefault.dict count], 0);
    [dataLayer resetPrivacyDefaults];
    XCTAssertEqual([self.mockedUserDefault.dict count], 0);
    void *bytes = malloc(10);
    NSData *data = [NSData dataWithBytes:bytes length:10];
    [self.mockedUserDefault.dict setObject:data forKey:OguryInstanceTokenKey];
    XCTAssertEqual([self.mockedUserDefault.dict count], 1);
    [self.mockedUserDefault.dict setObject:data forKey:OguryInstanceTokenKey];
    [self.mockedUserDefault.dict setObject:NoIDFA forKey:@"KEY_TEST"];
    XCTAssertEqual([self.mockedUserDefault.dict count], 2);
    [dataLayer resetPrivacyDefaults];
    XCTAssertEqual([self.mockedUserDefault.dict count], 1);
}

- (void)testRemoveOldProfigParam {
    OGCAdIdentifierDataLayer *dataLayer = [[OGCAdIdentifierDataLayer alloc] initWithUserDefaults:self.mockedUserDefault];
    XCTAssertEqual([self.mockedUserDefault.dict count], 0);
    [dataLayer removeOldProfigParam];
    XCTAssertEqual([self.mockedUserDefault.dict count], 0);
    void *bytes = malloc(10);
    NSData *data = [NSData dataWithBytes:bytes length:10];
    [self.mockedUserDefault.dict setObject:data forKey:@"LastProfigParams"];
    XCTAssertEqual([self.mockedUserDefault.dict count], 1);
    [self.mockedUserDefault.dict setObject:data forKey:OguryInstanceTokenKey];
    [self.mockedUserDefault.dict setObject:NoIDFA forKey:@"KEY_TEST"];
    XCTAssertEqual([self.mockedUserDefault.dict count], 3);
    [dataLayer removeOldProfigParam];
    XCTAssertEqual([self.mockedUserDefault.dict count], 2);
}

- (void)testMigrateDeprecatedOGYDeviceSettings {
    OGCAdIdentifierDataLayer *dataLayer = [[OGCAdIdentifierDataLayer alloc] initWithUserDefaults:self.mockedUserDefault];
    XCTAssertEqual([self.mockedUserDefault.dict count], 0);
    [dataLayer migrateDeprecatedOGYDeviceSettingsWithInstanceTokenID:instanceToken];
    void *bytes = malloc(10);
    NSData *data = [NSData dataWithBytes:bytes length:10];
    [self.mockedUserDefault.dict setObject:data forKey:@"LastProfigParams"];
    XCTAssertEqual([self.mockedUserDefault.dict count], 1);
    NSDictionary *oldSettings = [NSDictionary dictionaryWithObjects:@[] forKeys:@[]];
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:oldSettings options:kNilOptions error:&jsonError];
    XCTAssertNil(jsonError);
    [self.mockedUserDefault setObject:jsonData forKey:@"DeviceSettings"];
    XCTAssertEqual([self.mockedUserDefault.dict count], 2);
    [dataLayer migrateDeprecatedOGYDeviceSettingsWithInstanceTokenID:instanceToken];
    XCTAssertEqual([self.mockedUserDefault.dict count], 2);
    oldSettings = [NSDictionary dictionaryWithObjects:@[@"1",@"2",@"3",@"4"] forKeys:@[@"bundleId",@"assetKey",@"locale",@"advertisingId"]];
    jsonError = nil;
    jsonData = [NSJSONSerialization dataWithJSONObject:oldSettings options:kNilOptions error:&jsonError];
    XCTAssertNil(jsonError);
    [self.mockedUserDefault setObject:jsonData forKey:@"DeviceSettings"];
    XCTAssertEqual([self.mockedUserDefault.dict count], 2);
    [dataLayer migrateDeprecatedOGYDeviceSettingsWithInstanceTokenID:instanceToken];
    XCTAssertEqual([self.mockedUserDefault.dict count], 2);
    XCTAssertNil([self.mockedUserDefault objectForKey:@"DeviceSettings"]);
    XCTAssertNotNil([self.mockedUserDefault objectForKey:@"LastProfigParams"]);
    XCTAssertNotNil([self.mockedUserDefault objectForKey:@"OGYDeviceSettings"]);
    NSData *settingData = [self.mockedUserDefault objectForKey:@"OGYDeviceSettings"];
    NSError *settingError = nil;
    NSDictionary *settingDict = [NSJSONSerialization JSONObjectWithData:settingData options:kNilOptions error:&settingError];
    XCTAssertNil(settingError);
    XCTAssertNotNil([settingDict objectForKey:@"bundleId"]);
    XCTAssertNotNil([settingDict objectForKey:@"assetKey"]);
    XCTAssertNotNil([settingDict objectForKey:@"locale"]);
    XCTAssertNil([settingDict objectForKey:@"advertisingId"]);
    XCTAssertEqualObjects([settingDict objectForKey:@"bundleId"], @"1");
    XCTAssertEqualObjects([settingDict objectForKey:@"assetKey"], @"2");
    XCTAssertEqualObjects([settingDict objectForKey:@"locale"], @"3");
}

- (void)testMigrateDeprecatedOGYDeviceSettingsOtherFormat {
    OGCAdIdentifierDataLayer *dataLayer = [[OGCAdIdentifierDataLayer alloc] initWithUserDefaults:self.mockedUserDefault];
    
    [self.mockedUserDefault setObject:@"toto" forKey:@"DeviceSettings"];
    XCTAssertEqual([self.mockedUserDefault.dict count], 1);
    XCTAssertNotNil([self.mockedUserDefault objectForKey:@"DeviceSettings"]);
    [dataLayer migrateDeprecatedOGYDeviceSettingsWithInstanceTokenID:instanceToken];
    XCTAssertEqual([self.mockedUserDefault.dict count], 1);
    XCTAssertNotNil([self.mockedUserDefault objectForKey:@"DeviceSettings"]);
    
    [self.mockedUserDefault setObject:[NSArray arrayWithObject:@"toto"] forKey:@"DeviceSettings"];
    [dataLayer migrateDeprecatedOGYDeviceSettingsWithInstanceTokenID:instanceToken];
    XCTAssertEqual([self.mockedUserDefault.dict count], 1);
    XCTAssertNotNil([self.mockedUserDefault objectForKey:@"DeviceSettings"]);
    
    [self.mockedUserDefault setFloat:1 forKey:@"DeviceSettings"];
    [dataLayer migrateDeprecatedOGYDeviceSettingsWithInstanceTokenID:instanceToken];
    XCTAssertEqual([self.mockedUserDefault.dict count], 1);
    XCTAssertNotNil([self.mockedUserDefault objectForKey:@"DeviceSettings"]);
    
    void *bytes = malloc(10);
    NSData *data = [NSData dataWithBytes:bytes length:10];
    [self.mockedUserDefault.dict setObject:data forKey:@"DeviceSettings"];
    [dataLayer migrateDeprecatedOGYDeviceSettingsWithInstanceTokenID:instanceToken];
    XCTAssertEqual([self.mockedUserDefault.dict count], 1);
    XCTAssertNotNil([self.mockedUserDefault objectForKey:@"DeviceSettings"]);
}

- (void)testStoreAndRetrievePrivacyData {
    OGCAdIdentifierDataLayer *dataLayer = [[OGCAdIdentifierDataLayer alloc] initWithUserDefaults:self.mockedUserDefault];
    XCTAssertEqual([self.mockedUserDefault.dict count], 0);
    [dataLayer setPrivacyData:@"testValue" forKey:@"testKey"];
    XCTAssertEqual([self.mockedUserDefault.dict count], 2);
    XCTAssertEqual([[dataLayer retrieveDataPrivacy] count], 1);
    [dataLayer setPrivacyData:@"testValue" forKey:@"testKey"];
    XCTAssertEqual([self.mockedUserDefault.dict count], 2);
    XCTAssertEqual([[dataLayer retrieveDataPrivacy] count], 1);
    [dataLayer setPrivacyData:[NSNumber numberWithBool:false] forKey:@"testKeyBool"];
    [dataLayer setPrivacyData:[NSNumber numberWithBool:false] forKey:@"testKeyBool"];
    XCTAssertEqual([self.mockedUserDefault.dict count], 3);
    XCTAssertEqual([[dataLayer retrieveDataPrivacy] count], 2);
    [dataLayer setPrivacyData:[NSNumber  numberWithInt:12] forKey:@"testKeyInt"];
    [dataLayer setPrivacyData:[NSNumber  numberWithInt:12] forKey:@"testKeyInt"];
    XCTAssertEqual([self.mockedUserDefault.dict count], 4);
    XCTAssertEqual([[dataLayer retrieveDataPrivacy] count], 3);
}

@end

//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGCAdIdentifierManager.h"
#import "OGCAdIdentifierPrivacyLayer.h"
#import "OGCAdIdentifierDataLayer.h"
#import "OGCNSUserDefaultsMock.h"
#import "OGCASIdentifierManagerMock.h"
#import "OGCNSProcessInfoMock.h"
#import "OGCInstanceToken.h"
#import "NSString+OGCHash.h"
#import "OGCLog.h"
#import <OCMock/OCMock.h>

@interface OGCAdIdentifierManagerTests : XCTestCase

@property OGCAdIdentifierDataLayer *dataLayer;
@property OGCAdIdentifierPrivacyLayer *privacyLayer;
@property OGCNSUserDefaultsMock *mockedUserDefault;
@property OGCASIdentifierManagerMock *identifierManagerMock;
@property OGCLog *log;

@end

@interface OGCInstanceToken()

@property (nonatomic, strong, readwrite) NSDate *_Nullable expirationDate;
@property (readwrite) NSString *_Nullable idfaHash;
@property (readwrite) NSString *_Nullable salt;
- (id)initWithInstanceToken:(NSString *)instanceTokenID andProcessInfo:(NSProcessInfo *)processInfo;

@end

@interface OGCAdIdentifierPrivacyLayer()

- (id)initAdIdentifierManager:(ASIdentifierManager *)identifierManager;

@end

@interface OGCAdIdentifierDataLayer()

- (id)initWithUserDefaults:(NSUserDefaults *)userDefault;

@end

@interface OGCAdIdentifierManager()

- (id)initWithPrivacyLayer:(OGCAdIdentifierPrivacyLayer *)privacyLayer andDataLayer:(OGCAdIdentifierDataLayer *)dataLayer andProcessInfo:(NSProcessInfo *)processInfo log:(OGCLog *)log;

@end

@implementation OGCAdIdentifierManagerTests

NSString *emptyIdfa= @"00000000-0000-0000-0000-000000000000";
NSString * const InternalIdfv = @"11000000-1111-3333-1598-000000000000";
NSString *idfa1= @"11000000-1111-3333-1598-000000000000";
NSString *idfa2= @"22000000-1111-3333-1598-000000000000";
NSString *salt1= @"1234567890";
NSString *salt2= @"azertyuiop";
NSString *tokenId1= @"00000000-1111-3333-1598-000000000000";
NSString *tokenId2= @"00000000-2222-3333-1598-000000000000";

- (void)setUp {
    self.mockedUserDefault = [[OGCNSUserDefaultsMock alloc] init];
    self.identifierManagerMock = [[OGCASIdentifierManagerMock alloc] init];
    self.dataLayer = [[OGCAdIdentifierDataLayer alloc] initWithUserDefaults:self.mockedUserDefault];
    self.privacyLayer =[[OGCAdIdentifierPrivacyLayer alloc] initAdIdentifierManager:self.identifierManagerMock];
    self.log = [OGCLog shared];
}

- (void)tearDown {
    self.privacyLayer = nil;
    self.mockedUserDefault = nil;
    self.dataLayer = nil;
    self.identifierManagerMock = nil;
    self.mockedUserDefault = nil;
}

#pragma mark -  Storage Initializers

- (void)storeInstanceTokenFormIOS13WithIDFA {
    OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:13];
    OGCInstanceToken *instanceToken = [[OGCInstanceToken alloc] initWithInstanceToken:tokenId1 andProcessInfo:processInfo];
    [self.dataLayer storeInstanceToken:[NSKeyedArchiver archivedDataWithRootObject:instanceToken]];
}

- (void)storeInstanceTokenFormIOS13WithEmptyIDFA {
    OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:13];
    OGCInstanceToken *instanceToken = [[OGCInstanceToken alloc] initWithInstanceToken:tokenId1 andProcessInfo:processInfo];
    [self.dataLayer storeInstanceToken:[NSKeyedArchiver archivedDataWithRootObject:instanceToken]];
}

- (void)storeInstanceTokenFormIOS13WithEmptyIDFAExpiredToken {
    OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:13];
    OGCInstanceToken *instanceToken = [[OGCInstanceToken alloc] initWithInstanceToken:tokenId1 andProcessInfo:processInfo];
    [self.dataLayer storeInstanceToken:[NSKeyedArchiver archivedDataWithRootObject:instanceToken]];
}

#pragma mark -  Init without storage

- (void)testInitWithIDFA1 {
    OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:13];
    self.identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:idfa1];
    OGCAdIdentifierManager *modelLayer = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:processInfo log:self.log];
    NSString *adIdentifier = [modelLayer getAdIdentifier];
    XCTAssertEqual(adIdentifier.length, 36);
    XCTAssertEqualObjects(adIdentifier, idfa1);
    OGCInstanceToken *storedToken = [NSKeyedUnarchiver unarchiveObjectWithData:[self.dataLayer getInstanceToken]];
    XCTAssertNotNil(storedToken.instanceTokenID);
    XCTAssertEqual(storedToken.iosVersion, 13);
}

- (void)testInitWithEmptyIDFA {
    OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:13];
    self.identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:emptyIdfa];
    OGCAdIdentifierManager *modelLayer = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:processInfo log:self.log];
    NSString *adIdentifier = [modelLayer getAdIdentifier];
    XCTAssertEqual(adIdentifier.length, 36);
    XCTAssertEqualObjects(adIdentifier, emptyIdfa);
    OGCInstanceToken *storedToken = [NSKeyedUnarchiver unarchiveObjectWithData:[self.dataLayer getInstanceToken]];
    XCTAssertNotNil(storedToken.instanceTokenID);
    XCTAssertEqual(storedToken.iosVersion, 13);
}

- (void)testInit {
    OGCAdIdentifierManager *modelLayer = [[OGCAdIdentifierManager alloc] init];
    NSString *adIdentifier = [modelLayer getAdIdentifier];
    NSString *tokenId = [modelLayer getInstanceToken];
    XCTAssertNotNil(modelLayer);
    XCTAssertEqual(adIdentifier.length, 36);
    XCTAssertEqualObjects(adIdentifier, [modelLayer getAdIdentifier]);
    XCTAssertEqual(adIdentifier.length, 36);
    XCTAssertEqualObjects(tokenId, [modelLayer getInstanceToken]);
}

#pragma mark -  Init with stored instance token No Migration to iOS 14

- (void)testInitIOS13To13FromIDFA1ToIDFA1 {
    [self storeInstanceTokenFormIOS13WithIDFA];
    OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:13];
    self.identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:idfa1];
    OGCAdIdentifierManager *modelLayer = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:processInfo log:self.log];
    NSString *adIdentifier = [modelLayer getAdIdentifier];
    XCTAssertEqual(adIdentifier.length, 36);
    XCTAssertEqualObjects(adIdentifier, idfa1);
    OGCInstanceToken *storedToken = [NSKeyedUnarchiver unarchiveObjectWithData:[self.dataLayer getInstanceToken]];
    XCTAssertNotNil(storedToken.instanceTokenID);
    XCTAssertEqualObjects(storedToken.instanceTokenID, tokenId1);
    XCTAssertEqual(storedToken.iosVersion, 13);
}

- (void)testInitIOS13To13FromIDFA1ToIDFA2 {
    [self storeInstanceTokenFormIOS13WithIDFA];
    OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:13];
    self.identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:idfa2];
    OGCAdIdentifierManager *modelLayer = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:processInfo log:self.log];
    NSString *adIdentifier = [modelLayer getAdIdentifier];
    XCTAssertEqual(adIdentifier.length, 36);
    XCTAssertEqualObjects(adIdentifier, idfa2);
    OGCInstanceToken *storedToken = [NSKeyedUnarchiver unarchiveObjectWithData:[self.dataLayer getInstanceToken]];
    XCTAssertNotNil(storedToken.instanceTokenID);
    XCTAssertTrue([storedToken.instanceTokenID isEqualToString:tokenId1]);
    XCTAssertEqual(storedToken.iosVersion, 13);
}

- (void)testInitIOS13To13FromEmptyIDFAToEmptyIDFA {
    [self storeInstanceTokenFormIOS13WithEmptyIDFA];
    OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:13];
    self.identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:emptyIdfa];
    OGCAdIdentifierManager *modelLayer = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:processInfo log:self.log];
    NSString *adIdentifier = [modelLayer getAdIdentifier];
    XCTAssertEqual(adIdentifier.length, 36);
    XCTAssertEqualObjects(adIdentifier, emptyIdfa);
    OGCInstanceToken *storedToken = [NSKeyedUnarchiver unarchiveObjectWithData:[self.dataLayer getInstanceToken]];
    XCTAssertNotNil(storedToken.instanceTokenID);
    XCTAssertEqualObjects(storedToken.instanceTokenID, tokenId1);
    XCTAssertEqual(storedToken.iosVersion, 13);
}

- (void)testInitIOS13To13FromEmptyIDFAToIDFA1 {
    [self storeInstanceTokenFormIOS13WithEmptyIDFA];
    OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:13];
    self.identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:idfa1];
    OGCAdIdentifierManager *modelLayer = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:processInfo log:self.log];
    NSString *adIdentifier = [modelLayer getAdIdentifier];
    XCTAssertEqual(adIdentifier.length, 36);
    XCTAssertEqualObjects(adIdentifier, idfa1);
    OGCInstanceToken *storedToken = [NSKeyedUnarchiver unarchiveObjectWithData:[self.dataLayer getInstanceToken]];
    XCTAssertNotNil(storedToken.instanceTokenID);
    XCTAssertEqualObjects(storedToken.instanceTokenID, tokenId1);
    XCTAssertEqual(storedToken.iosVersion, 13);
}

- (void)testInitIOS13To13FromIDFA1ToEmptyIDFA {
    [self storeInstanceTokenFormIOS13WithIDFA];
    OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:13];
    self.identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:emptyIdfa];
    OGCAdIdentifierManager *modelLayer = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:processInfo log:self.log];
    NSString *adIdentifier = [modelLayer getAdIdentifier];
    XCTAssertEqual(adIdentifier.length, 36);
    XCTAssertEqualObjects(adIdentifier, emptyIdfa);
    OGCInstanceToken *storedToken = [NSKeyedUnarchiver unarchiveObjectWithData:[self.dataLayer getInstanceToken]];
    XCTAssertNotNil(storedToken.instanceTokenID);
    XCTAssertTrue([storedToken.instanceTokenID isEqualToString:tokenId1]);
    XCTAssertEqual(storedToken.iosVersion, 13);
}

- (void)testInitIOS13To13FromEmptyIDFAToEmptyIDFATokenExpired {
    [self storeInstanceTokenFormIOS13WithEmptyIDFAExpiredToken];
    OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:13];
    self.identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:emptyIdfa];
    OGCAdIdentifierManager *modelLayer = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:processInfo log:self.log];
    NSString *adIdentifier = [modelLayer getAdIdentifier];
    XCTAssertEqual(adIdentifier.length, 36);
    XCTAssertEqualObjects(adIdentifier, emptyIdfa);
    OGCInstanceToken *storedToken = [NSKeyedUnarchiver unarchiveObjectWithData:[self.dataLayer getInstanceToken]];
    XCTAssertNotNil(storedToken.instanceTokenID);
    XCTAssertTrue([storedToken.instanceTokenID isEqualToString:tokenId1]);
    XCTAssertEqual(storedToken.iosVersion, 13);
}

#pragma mark -  Init with stored instance token and Migration to iOS 14

- (void)testInitIOS13To14FromEmptyIDFAToEmptyIDFA {
    [self storeInstanceTokenFormIOS13WithEmptyIDFA];
    OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:14];
    self.identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:emptyIdfa];
    OGCAdIdentifierManager *modelLayer = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:processInfo log:self.log];
    NSString *adIdentifier = [modelLayer getAdIdentifier];
    XCTAssertEqual(adIdentifier.length, 36);
    XCTAssertEqualObjects(adIdentifier, emptyIdfa);
    OGCInstanceToken *storedToken = [NSKeyedUnarchiver unarchiveObjectWithData:[self.dataLayer getInstanceToken]];
    XCTAssertNotNil(storedToken.instanceTokenID);
    XCTAssertEqualObjects(storedToken.instanceTokenID, tokenId1);
    XCTAssertEqual(storedToken.iosVersion, 14);
}

- (void)testInitIOS13To14FromEmptyIDFAToIDFA {
    [self storeInstanceTokenFormIOS13WithEmptyIDFA];
    OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:14];
    self.identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:idfa1];
    OGCAdIdentifierManager *modelLayer = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:processInfo log:self.log];
    NSString *adIdentifier = [modelLayer getAdIdentifier];
    XCTAssertEqual(adIdentifier.length, 36);
    XCTAssertEqualObjects(adIdentifier, idfa1);
    OGCInstanceToken *storedToken = [NSKeyedUnarchiver unarchiveObjectWithData:[self.dataLayer getInstanceToken]];
    XCTAssertNotNil(storedToken.instanceTokenID);
    XCTAssertEqualObjects(storedToken.instanceTokenID, tokenId1);
    XCTAssertEqual(storedToken.iosVersion, 14);
}

- (void)testInitIOS13To14FromIDFAToEmptyIDFA {
    [self storeInstanceTokenFormIOS13WithIDFA];
    OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:14];
    self.identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:emptyIdfa];
    OGCAdIdentifierManager *modelLayer = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:processInfo log:self.log];
    NSString *adIdentifier = [modelLayer getAdIdentifier];
    XCTAssertEqual(adIdentifier.length, 36);
    XCTAssertEqualObjects(adIdentifier, emptyIdfa);
    OGCInstanceToken *storedToken = [NSKeyedUnarchiver unarchiveObjectWithData:[self.dataLayer getInstanceToken]];
    XCTAssertNotNil(storedToken.instanceTokenID);
    XCTAssertEqualObjects(storedToken.instanceTokenID, tokenId1);
    XCTAssertEqual(storedToken.iosVersion, 14);
}

- (void)testInitIOS13To14FromIDFA1ToIDFA2 {
    [self storeInstanceTokenFormIOS13WithIDFA];
    OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:14];
    self.identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:idfa2];
    OGCAdIdentifierManager *modelLayer = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:processInfo log:self.log];
    NSString *adIdentifier = [modelLayer getAdIdentifier];
    XCTAssertEqual(adIdentifier.length, 36);
    XCTAssertEqualObjects(adIdentifier, idfa2);
    OGCInstanceToken *storedToken = [NSKeyedUnarchiver unarchiveObjectWithData:[self.dataLayer getInstanceToken]];
    XCTAssertNotNil(storedToken.instanceTokenID);
    XCTAssertTrue([storedToken.instanceTokenID isEqualToString:tokenId1]);
    XCTAssertEqual(storedToken.iosVersion, 14);
}

- (void)testInitIOS13To14FromIDFAToIDFA {
    [self storeInstanceTokenFormIOS13WithIDFA];
    OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:14];
    self.identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:idfa1];
    OGCAdIdentifierManager *modelLayer = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:processInfo log:self.log];
    NSString *adIdentifier = [modelLayer getAdIdentifier];
    XCTAssertEqual(adIdentifier.length, 36);
    XCTAssertEqualObjects(adIdentifier, idfa1);
    OGCInstanceToken *storedToken = [NSKeyedUnarchiver unarchiveObjectWithData:[self.dataLayer getInstanceToken]];
    XCTAssertNotNil(storedToken.instanceTokenID);
    XCTAssertEqualObjects(storedToken.instanceTokenID, tokenId1);
    XCTAssertEqual(storedToken.iosVersion, 14);
}

- (void)testInitIOS13To14FromEmptyIDFAToEmptyIDFAExpiredToken {
    [self storeInstanceTokenFormIOS13WithEmptyIDFAExpiredToken];
    OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:14];
    self.identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:emptyIdfa];
    OGCAdIdentifierManager *modelLayer = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:processInfo log:self.log];
    NSString *adIdentifier = [modelLayer getAdIdentifier];
    XCTAssertEqual(adIdentifier.length, 36);
    XCTAssertEqualObjects(adIdentifier, emptyIdfa);
    OGCInstanceToken *storedToken = [NSKeyedUnarchiver unarchiveObjectWithData:[self.dataLayer getInstanceToken]];
    XCTAssertNotNil(storedToken.instanceTokenID);
    XCTAssertTrue([storedToken.instanceTokenID isEqualToString:tokenId1]);
    XCTAssertEqual(storedToken.iosVersion, 14);
}

- (void)testAdIdentifier {
    [self storeInstanceTokenFormIOS13WithIDFA];
    OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:14];
    self.identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:idfa1];
    OGCAdIdentifierManager *modelLayer = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:processInfo log:self.log];
    NSString *adIdentifier = [modelLayer getAdIdentifier];
    XCTAssertEqual(adIdentifier.length, 36);
    XCTAssertEqualObjects(adIdentifier, idfa1);
}

- (void)testVendorIdentifier {
    OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:14];
    OGCAdIdentifierPrivacyLayer* privacyLayer = OCMPartialMock([[OGCAdIdentifierPrivacyLayer alloc] initAdIdentifierManager:self.identifierManagerMock]);
    OGCAdIdentifierManager *modelLayer = OCMPartialMock([[OGCAdIdentifierManager alloc] initWithPrivacyLayer:privacyLayer
                                                                                                andDataLayer:self.dataLayer
                                                                                              andProcessInfo:processInfo
                                                                                                         log:self.log]);
    OCMStub([privacyLayer vendorIdentifier]).andReturn(InternalIdfv);
    XCTAssertEqualObjects([modelLayer getVendorIdentifier], InternalIdfv);
}

- (void)testGetInstanceTokenWithIDFA {
    [self storeInstanceTokenFormIOS13WithIDFA];
    OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:14];
    self.identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:idfa1];
    OGCAdIdentifierManager *modelLayer = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:processInfo log:self.log];
    NSString *instanceTokenID = [modelLayer getInstanceToken];
    XCTAssertEqual(instanceTokenID.length, 36);
    OGCInstanceToken *storedToken = [NSKeyedUnarchiver unarchiveObjectWithData:[self.dataLayer getInstanceToken]];
    XCTAssertNotNil(storedToken.instanceTokenID);
    XCTAssertEqualObjects(storedToken.instanceTokenID, tokenId1);
    XCTAssertEqual(storedToken.iosVersion, 14);
}

- (void)testGetInstanceTokenWithEmptyIDFA {
    [self storeInstanceTokenFormIOS13WithEmptyIDFA];
    OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:14];
    self.identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:emptyIdfa];
    OGCAdIdentifierManager *modelLayer = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:processInfo log:self.log];
    NSString *instanceTokenID = [modelLayer getInstanceToken];
    XCTAssertEqual(instanceTokenID.length, 36);
    OGCInstanceToken *storedToken = [NSKeyedUnarchiver unarchiveObjectWithData:[self.dataLayer getInstanceToken]];
    XCTAssertNotNil(storedToken.instanceTokenID);
    XCTAssertEqualObjects(storedToken.instanceTokenID, tokenId1);
    XCTAssertEqual(storedToken.iosVersion, 14);
}

- (void)testGetInstanceTokenWithBrokenUserDefault {
    [self.mockedUserDefault lockUserDefault];
    [self storeInstanceTokenFormIOS13WithIDFA];
    OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:14];
    self.identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:emptyIdfa];
    OGCAdIdentifierManager *modelLayer = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:processInfo log:self.log];
    NSString *instanceTokenID = [modelLayer getInstanceToken];
    XCTAssertEqual(instanceTokenID.length, 36);
}

- (void)testMigrateDeprecatedUserDefaultKeys {
    [self storeInstanceTokenFormIOS13WithIDFA];
    OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:13];
    self.identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:idfa1];
    [self.mockedUserDefault setObject:@"toto" forKey:@"DeviceSettings"];
    XCTAssertEqual([self.mockedUserDefault.dict count], 2);
    XCTAssertNotNil([self.mockedUserDefault objectForKey:@"DeviceSettings"]);
    OGCAdIdentifierManager *modelLayer = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:processInfo log:self.log];
    [modelLayer migrateDeprecatedUserDefaultKeys];
    XCTAssertEqual([self.mockedUserDefault.dict count], 2);
    XCTAssertNotNil([self.mockedUserDefault objectForKey:@"DeviceSettings"]);
    [modelLayer migrateDeprecatedUserDefaultKeys];
    NSDictionary *oldSettings = [NSDictionary dictionaryWithObjects:@[@"1",@"2",@"3",@"4"] forKeys:@[@"bundleId",@"assetKey",@"locale",@"advertisingId"]];
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:oldSettings options:kNilOptions error:&jsonError];
    XCTAssertNil(jsonError);
    [self.mockedUserDefault setObject:jsonData forKey:@"DeviceSettings"];
    XCTAssertEqual([self.mockedUserDefault.dict count], 2);
    XCTAssertNotNil([self.mockedUserDefault objectForKey:@"DeviceSettings"]);
    [modelLayer migrateDeprecatedUserDefaultKeys];
    XCTAssertEqual([self.mockedUserDefault.dict count], 2);
    XCTAssertNil([self.mockedUserDefault objectForKey:@"DeviceSettings"]);
    XCTAssertNotNil([self.mockedUserDefault objectForKey:@"OGYDeviceSettings"]);
}

- (void)testRemoveDeprecatedProfigUserDefaultKeys {
    [self storeInstanceTokenFormIOS13WithIDFA];
    OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:13];
    self.identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:idfa1];
    OGCAdIdentifierManager *modelLayer = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:processInfo log:self.log];
    [modelLayer removeDeprecatedProfigUserDefaultKeys];
    XCTAssertEqual([self.mockedUserDefault.dict count], 1);
    [modelLayer removeDeprecatedProfigUserDefaultKeys];
    XCTAssertEqual([self.mockedUserDefault.dict count], 1);
    void *bytes = malloc(10);
    NSData *data = [NSData dataWithBytes:bytes length:10];
    [self.mockedUserDefault.dict setObject:data forKey:@"LastProfigParams"];
    XCTAssertEqual([self.mockedUserDefault.dict count], 2);
    [self.mockedUserDefault.dict setObject:@"test" forKey:@"KEY_TEST"];
    XCTAssertEqual([self.mockedUserDefault.dict count], 3);
    [modelLayer removeDeprecatedProfigUserDefaultKeys];
    XCTAssertEqual([self.mockedUserDefault.dict count], 2);
}

- (void)testIsAdOptin {
    [self storeInstanceTokenFormIOS13WithEmptyIDFA];
    OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:14];
    self.identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:emptyIdfa];
    OGCAdIdentifierManager *modelLayer = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:processInfo log:self.log];
    NSString *instanceTokenID = [modelLayer getInstanceToken];
    XCTAssertEqual(instanceTokenID.length, 36);
    OGCInstanceToken *storedToken = [NSKeyedUnarchiver unarchiveObjectWithData:[self.dataLayer getInstanceToken]];
    XCTAssertNotNil(storedToken.instanceTokenID);
    
    [self storeInstanceTokenFormIOS13WithEmptyIDFA];
    processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:14];
    self.identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:idfa1];
    modelLayer = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:processInfo log:self.log];
    instanceTokenID = [modelLayer getInstanceToken];
    XCTAssertEqual(instanceTokenID.length, 36);
    storedToken = [NSKeyedUnarchiver unarchiveObjectWithData:[self.dataLayer getInstanceToken]];
    XCTAssertNotNil(storedToken.instanceTokenID);
}

- (void)testUpdateInstanceToken {
    [self storeInstanceTokenFormIOS13WithIDFA];
    OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:14];
    self.identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:idfa1];
    OGCAdIdentifierManager *modelLayer = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:processInfo log:self.log];
    NSString *instanceTokenID = [modelLayer getInstanceToken];
    XCTAssertEqual(instanceTokenID.length, 36);
    [modelLayer updateInstanceToken];
    XCTAssertEqual([modelLayer getInstanceToken].length, 36);
}

- (void)testRetrievedGPPConsentString {
   [self.mockedUserDefault unlockUserDefault];
   [self.mockedUserDefault setObject:[@"2-3" dataUsingEncoding:NSUTF8StringEncoding] forKey:@"IABGPP_GppSID"];
   [self.mockedUserDefault setObject:[@"DBABM~CPXxRfAPXxRfAAfKABENB-CgAAAAAAAAAAYgAAAAAAAA" dataUsingEncoding:NSUTF8StringEncoding] forKey:@"IABGPP_HDR_GppString"];
   [self.mockedUserDefault setObject:[@"CPokAsAPokAsABEACBENC7CgAP_AAH_AAAwIAAAAAAAA" dataUsingEncoding:NSUTF8StringEncoding] forKey:@"IABTCF_TCString"];
   OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:13];
   OGCAdIdentifierManager *modelLayer = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:processInfo log:self.log];
   XCTAssertTrue([[modelLayer retrieveGPPSID] isEqualToString: @"2-3"]);
   XCTAssertTrue([[modelLayer retrieveGPPConsentString] isEqualToString: @"DBABM~CPXxRfAPXxRfAAfKABENB-CgAAAAAAAAAAYgAAAAAAAA"]);
   XCTAssertTrue([[modelLayer retrieveTCFConsentString] isEqualToString: @"CPokAsAPokAsABEACBENC7CgAP_AAH_AAAwIAAAAAAAA"]);
}

- (void)testWhenCallingGppConsentGettersThenProperInternalMethodAreForwarded {
    OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:13];
    OGCAdIdentifierDataLayer* dataLayer = OCMPartialMock([[OGCAdIdentifierDataLayer alloc] initWithUserDefaults:self.mockedUserDefault]);
    OGCAdIdentifierManager *modelLayer = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer
                                                                                 andDataLayer:dataLayer
                                                                               andProcessInfo:processInfo
                                                                                          log:self.log];
    [modelLayer retrieveGPPSID];
    OCMVerify([dataLayer getGPPSID]);
    [modelLayer retrieveGPPConsentString];
    OCMVerify([dataLayer getGPPConsentString]);
    [modelLayer retrieveTCFConsentString];
    OCMVerify([dataLayer getTCFConsentString]);
    [modelLayer retrieveDataPrivacy];
    OCMVerify([dataLayer retrieveDataPrivacy]);
}

@end


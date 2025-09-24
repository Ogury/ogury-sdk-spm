//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGCInternal.h"
#import "OGCAdIdentifierManager.h"
#import "OGCInstanceToken.h"
#import "NSString+OGCHash.h"
#import "OGCAdIdentifierDataLayer.h"
#import "OGCAdIdentifierPrivacyLayer.h"
#import "OGCNSUserDefaultsMock.h"
#import "OGCASIdentifierManagerMock.h"
#import <OCMock/OCMock.h>
#import "OGCLog.h"
#import "OguryLogLevel.h"
#import "OGCSetLogLevelNotificationManager.h"

static NSString * const InternalEmptyIdfa = @"00000000-0000-0000-0000-000000000000";
static NSString * const InternalIdfa = @"11000000-1111-3333-1598-000000000000";
static NSString * const InternalIdfv = @"11000000-1111-3333-1598-000000000000";
static NSString * const InternalSalt = @"1234567890";
static NSString * const InternalTokenId = @"00000000-1111-3333-1598-000000000000";

@interface OGCInternalTests : XCTestCase

@property (nonatomic, strong) OGCAdIdentifierDataLayer *dataLayer;
@property (nonatomic, strong) OGCNSUserDefaultsMock *mockedUserDefault;
@property (nonatomic, strong) OGCAdIdentifierPrivacyLayer *privacyLayer;
@property (nonatomic, strong) OGCASIdentifierManagerMock *identifierManagerMock;
@property (nonatomic, strong) OGCLog *log;
@property (nonatomic, strong) OGCInternal *internal;

@end

@interface OGCInstanceToken ()

@property (nonatomic, strong, readwrite, nullable) NSDate *expirationDate;
@property (readwrite, copy, nullable) NSString *idfaHash;
@property (readwrite, copy, nullable) NSString *salt;

- (id)initWithInstanceToken:(NSString *)instanceTokenID andProcessInfo:(NSProcessInfo *)processInfo;

@end

@interface OGCInternal ()

@property (nonatomic, strong) OGCAdIdentifierManager *adIdentifierManager;

- (id)initWithAdIdentifierManager:(OGCAdIdentifierManager *)adIdentifierManager log:(OGCLog *)log logNotificationManager:(OGCSetLogLevelNotificationManager *)logNotificationManager;

@end

@interface OGCAdIdentifierDataLayer ()

- (id)initWithUserDefaults:(NSUserDefaults *)userDefault;

@end

@interface OGCAdIdentifierPrivacyLayer ()

- (id)initAdIdentifierManager:(ASIdentifierManager *)identifierManager;

@end

@interface OGCAdIdentifierManager ()

- (id)initWithPrivacyLayer:(OGCAdIdentifierPrivacyLayer *)privacyLayer andDataLayer:(OGCAdIdentifierDataLayer *)dataLayer andProcessInfo:(NSProcessInfo *)processInfo log:(OGCLog *)log;

@end


@implementation OGCInternalTests

#pragma mark - Methods

- (void)setUp {
    self.log = OCMClassMock([OGCLog class]);
    self.mockedUserDefault = [[OGCNSUserDefaultsMock alloc] init];
    self.identifierManagerMock = [[OGCASIdentifierManagerMock alloc] init];
    self.dataLayer = [[OGCAdIdentifierDataLayer alloc] initWithUserDefaults:self.mockedUserDefault];
    self.privacyLayer = [[OGCAdIdentifierPrivacyLayer alloc] initAdIdentifierManager:self.identifierManagerMock];
}

- (void)tearDown {
    self.privacyLayer = nil;
    self.mockedUserDefault = nil;
    self.dataLayer = nil;
    self.identifierManagerMock = nil;
    self.mockedUserDefault = nil;
}

- (void)storeInstanceTokenWithIDFA {
    OGCInstanceToken *instanceToken = [[OGCInstanceToken alloc] initWithInstanceToken:InternalTokenId];
    [self.dataLayer storeInstanceToken:[NSKeyedArchiver archivedDataWithRootObject:instanceToken]];
}

- (void)storeInstanceTokenWithEmptyIDFA {
    OGCInstanceToken *instanceToken = [[OGCInstanceToken alloc] initWithInstanceToken:InternalTokenId];
    [self.dataLayer storeInstanceToken:[NSKeyedArchiver archivedDataWithRootObject:instanceToken]];
}

#pragma mark - Tests

- (void)testSetLogLevel {
    OGCAdIdentifierManager *adIdentifierManager = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:[NSProcessInfo processInfo] log:self.log];
    OGCInternal *internalInstance = [[OGCInternal alloc] initWithAdIdentifierManager:adIdentifierManager log:self.log logNotificationManager:[[OGCSetLogLevelNotificationManager alloc] init]];

    [internalInstance setLogLevel:OguryLogLevelOff];

    OCMVerify([self.log setLogLevel:OguryLogLevelOff]);
}

- (void)testLogNotificationManager {
    id receiver = OCMClassMock([OGCSetLogLevelNotificationManager class]);
    
    OGCAdIdentifierManager *adIdentifierManager = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:[NSProcessInfo processInfo] log:self.log];
    OGCInternal *internalInstance = [[OGCInternal alloc] initWithAdIdentifierManager:adIdentifierManager log:self.log logNotificationManager:receiver];

    // no action required since receiver is directly activated in class init
    
    OCMVerify([receiver registerToNotification]);
}

- (void)testGetVersion {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];

    XCTAssertEqualObjects([[OGCInternal shared] getVersion], bundle.infoDictionary[@"CFBundleShortVersionString"]);
}

- (void)testShared {
    OGCInternal *coreInternalInstance = OGCInternal.shared;

    XCTAssertNotNil(coreInternalInstance);
    XCTAssertNotNil(coreInternalInstance.adIdentifierManager);
    XCTAssertEqualObjects([OGCInternal shared], coreInternalInstance);
    XCTAssertEqualObjects([OGCInternal shared].adIdentifierManager, coreInternalInstance.adIdentifierManager);
}

- (void)testGetAdIdentifier {
    [self storeInstanceTokenWithIDFA];
    self.identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:InternalIdfa];
    OGCAdIdentifierManager *adIdentifierManager = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:[NSProcessInfo processInfo] log:self.log];
    OGCInternal *coreInternalInstance = [[OGCInternal alloc] initWithAdIdentifierManager:adIdentifierManager log:self.log logNotificationManager:[[OGCSetLogLevelNotificationManager alloc] init]];

    XCTAssertNotNil(coreInternalInstance);
    XCTAssertNotNil(coreInternalInstance.adIdentifierManager);
    XCTAssertEqual([coreInternalInstance getAdIdentifier].length, 36);
    XCTAssertEqualObjects([coreInternalInstance getAdIdentifier], InternalIdfa);
}

- (void)testVendorIdentifier {
    OGCAdIdentifierManager *adIdentifierManager = OCMPartialMock([[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer
                                                                                                         andDataLayer:self.dataLayer
                                                                                                       andProcessInfo:[NSProcessInfo processInfo]
                                                                                                                  log:self.log]);
    OGCInternal *coreInternalInstance = OCMPartialMock([[OGCInternal alloc] initWithAdIdentifierManager:adIdentifierManager
                                                                                                    log:self.log
                                                                                 logNotificationManager:[[OGCSetLogLevelNotificationManager alloc] init]]);
    OCMStub([adIdentifierManager getVendorIdentifier]).andReturn(InternalIdfv);
    XCTAssertTrue([[coreInternalInstance getVendorIdentifier] isEqualToString:InternalIdfv]);
}

- (void)testGetInstanceToken {
    [self storeInstanceTokenWithIDFA];
    self.identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:InternalIdfa];
    OGCAdIdentifierManager *adIdentifierManager = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:[NSProcessInfo processInfo] log:self.log];
    OGCInternal *coreInternalInstance = [[OGCInternal alloc] initWithAdIdentifierManager:adIdentifierManager log:self.log logNotificationManager:[[OGCSetLogLevelNotificationManager alloc] init]];

    XCTAssertNotNil(coreInternalInstance);
    XCTAssertNotNil(coreInternalInstance.adIdentifierManager);
    XCTAssertEqual([coreInternalInstance getInstanceToken].length, 36);
    XCTAssertEqualObjects([coreInternalInstance getInstanceToken], InternalTokenId);
}

- (void)testIsAdOptin {
    [self storeInstanceTokenWithIDFA];
    self.identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:InternalIdfa];
    OGCAdIdentifierManager *adIdentifierManager = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:[NSProcessInfo processInfo] log:self.log];
    OGCInternal *coreInternalInstance = [[OGCInternal alloc] initWithAdIdentifierManager:adIdentifierManager log:self.log logNotificationManager:[[OGCSetLogLevelNotificationManager alloc] init]];

    XCTAssertNotNil(coreInternalInstance);
    XCTAssertNotNil(coreInternalInstance.adIdentifierManager);
    XCTAssertEqual([coreInternalInstance getAdIdentifier].length, 36);
    XCTAssertEqualObjects([coreInternalInstance getAdIdentifier], InternalIdfa);
    XCTAssertTrue([coreInternalInstance isAdOptin]);

    [self storeInstanceTokenWithEmptyIDFA];
    self.identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:InternalEmptyIdfa];
    adIdentifierManager = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:[NSProcessInfo processInfo] log:self.log];
    coreInternalInstance = [[OGCInternal alloc] initWithAdIdentifierManager:adIdentifierManager log:self.log logNotificationManager:[[OGCSetLogLevelNotificationManager alloc] init]];

    XCTAssertNotNil(coreInternalInstance);
    XCTAssertNotNil(coreInternalInstance.adIdentifierManager);
    XCTAssertEqual([coreInternalInstance getAdIdentifier].length, 36);
    XCTAssertEqualObjects([coreInternalInstance getAdIdentifier], InternalEmptyIdfa);
    XCTAssertFalse([coreInternalInstance isAdOptin]);
}

- (void)testStoreAndRetrievePrivacyData {
   
    OGCAdIdentifierManager *adIdentifierManager = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:[NSProcessInfo processInfo] log:self.log];
    OGCInternal *coreInternalInstance = [[OGCInternal alloc] initWithAdIdentifierManager:adIdentifierManager log:self.log logNotificationManager:[[OGCSetLogLevelNotificationManager alloc] init]];
   
    [coreInternalInstance setPrivacyData:@"testValue" string:@"testKey"];
    XCTAssertEqual([[coreInternalInstance retrieveDataPrivacy] count], 1);
    [coreInternalInstance setPrivacyData:@"testValue" string:@"testKey"];
    XCTAssertEqual([[coreInternalInstance retrieveDataPrivacy] count], 1);
   
    [coreInternalInstance setPrivacyData:@"testValueBool" boolean:false];
    XCTAssertEqual([[coreInternalInstance retrieveDataPrivacy] count], 2);
    [coreInternalInstance setPrivacyData:@"testValueBool" boolean:false];
    XCTAssertEqual([[coreInternalInstance retrieveDataPrivacy] count], 2);
   
    [coreInternalInstance setPrivacyData:@"testValueInt" integer:12];
    XCTAssertEqual([[coreInternalInstance retrieveDataPrivacy] count], 3);
    [coreInternalInstance setPrivacyData:@"testValueInt" integer:12];
    XCTAssertEqual([[coreInternalInstance retrieveDataPrivacy] count], 3);
}

- (void)testStoreAndRetrievePrivacyDataBool {
   
    OGCAdIdentifierManager *adIdentifierManager = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:[NSProcessInfo processInfo] log:self.log];
    OGCInternal *coreInternalInstance = [[OGCInternal alloc] initWithAdIdentifierManager:adIdentifierManager log:self.log logNotificationManager:[[OGCSetLogLevelNotificationManager alloc] init]];
   
    [coreInternalInstance setPrivacyData:@"testValueBool" boolean:false];
    XCTAssertEqual([[coreInternalInstance retrieveDataPrivacy] count], 1);
    [coreInternalInstance setPrivacyData:@"testValueBool" boolean:false];
    XCTAssertEqual([[coreInternalInstance retrieveDataPrivacy] count], 1);

}

- (void)testStoreAndRetrievePrivacyDataInt {
   
    OGCAdIdentifierManager *adIdentifierManager = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:[NSProcessInfo processInfo] log:self.log];
    OGCInternal *coreInternalInstance = [[OGCInternal alloc] initWithAdIdentifierManager:adIdentifierManager log:self.log logNotificationManager:[[OGCSetLogLevelNotificationManager alloc] init]];
   
    [coreInternalInstance setPrivacyData:@"testValueInt" integer:12];
    XCTAssertEqual([[coreInternalInstance retrieveDataPrivacy] count], 1);
    [coreInternalInstance setPrivacyData:@"testValueInt" integer:12];
    XCTAssertEqual([[coreInternalInstance retrieveDataPrivacy] count], 1);

}

- (void)testStoreAndRetrievePrivacyDataString {
   
    OGCAdIdentifierManager *adIdentifierManager = [[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer andDataLayer:self.dataLayer andProcessInfo:[NSProcessInfo processInfo] log:self.log];
    OGCInternal *coreInternalInstance = [[OGCInternal alloc] initWithAdIdentifierManager:adIdentifierManager log:self.log logNotificationManager:[[OGCSetLogLevelNotificationManager alloc] init]];
   
    [coreInternalInstance setPrivacyData:@"testValue" string:@"testKey"];
    XCTAssertEqual([[coreInternalInstance retrieveDataPrivacy] count], 1);
    [coreInternalInstance setPrivacyData:@"testValue" string:@"testKey"];
    XCTAssertEqual([[coreInternalInstance retrieveDataPrivacy] count], 1);

}

- (void)testWhenCallingGppConsentGettersThenProperInternalMethodAreForwarded {
    OGCAdIdentifierManager *adIdentifierManager = OCMPartialMock([[OGCAdIdentifierManager alloc] initWithPrivacyLayer:self.privacyLayer
                                                                                                         andDataLayer:self.dataLayer
                                                                                                       andProcessInfo:[NSProcessInfo processInfo]
                                                                                                                  log:self.log]);
    OGCInternal *coreInternalInstance = OCMPartialMock([[OGCInternal alloc] initWithAdIdentifierManager:adIdentifierManager
                                                                                                    log:self.log
                                                                                 logNotificationManager:[[OGCSetLogLevelNotificationManager alloc] init]]);
    [coreInternalInstance gppConsentString];
    OCMVerify([adIdentifierManager retrieveGPPConsentString]);
    [coreInternalInstance gppSID];
    OCMVerify([adIdentifierManager retrieveGPPSID]);
    [coreInternalInstance tcfConsentString];
    OCMVerify([adIdentifierManager retrieveTCFConsentString]);
}

@end

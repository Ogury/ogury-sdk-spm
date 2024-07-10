//
// Copyright (c) 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "OGAInternal+Testing.h"
#import "OGALog.h"
#import "OGASetLogLevelNotificationManager.h"

@interface OGAInternalTests : XCTestCase

@property(nonatomic, strong) OGAPersistentEventBus *persistentEventBus;
@property(nonatomic, strong) OGABroadcastEventBus *broadcastEventBus;
@property(nonatomic, strong) OGAAssetKeyManager *assetKeyManager;
@property(nonatomic, strong) OGAProfigManager *profigManager;
@property(nonatomic, strong) OGAEnvironmentManager *environment;
@property(nonatomic, strong) OGAReachability *internetReachability;
@property(nonatomic, strong) OGAAdManager *adManager;
@property(nonatomic, strong) OGASetLogLevelNotificationManager *logNotificationManager;
@property(nonatomic, strong) OGAWebViewUserAgentService *webViewUserAgentService;
@property(nonatomic, strong) OGAInternal *internal;
@property(nonatomic, strong) OGALog *log;

@end
@interface OGAInternal ()

@property(nonatomic, strong) OGAAssetKeyManager *assetKeyManager;
- (void)maxWebViewUserAgentRetryReached;
- (void)receivedWebViewUserAgent:(NSString *)userAgent;
- (void)syncProfig;

@end

@interface OGAAssetKeyManager ()
@property(nonatomic, assign) BOOL assetKeyHasBeenSet;
@property(nonatomic, copy, readwrite, nullable) NSString *assetKey;
@end

@implementation OGAInternalTests

- (void)setUp {
    self.persistentEventBus = OCMClassMock([OGAPersistentEventBus class]);
    self.broadcastEventBus = OCMClassMock([OGABroadcastEventBus class]);
    self.assetKeyManager = OCMClassMock([OGAAssetKeyManager class]);
    self.profigManager = OCMClassMock([OGAProfigManager class]);
    self.environment = OCMClassMock([OGAEnvironmentManager class]);
    self.internetReachability = OCMClassMock([OGAReachability class]);
    self.adManager = OCMClassMock([OGAAdManager class]);
    self.log = OCMClassMock([OGALog class]);
    self.logNotificationManager = OCMClassMock([OGASetLogLevelNotificationManager class]);
    self.webViewUserAgentService = OCMClassMock([OGAWebViewUserAgentService class]);
    self.internal = OCMPartialMock([[OGAInternal alloc] initWithPersistentEventBus:self.persistentEventBus
                                                                 broadcastEventBus:self.broadcastEventBus
                                                                   assetKeyManager:self.assetKeyManager
                                                                     profigManager:self.profigManager
                                                                environmentManager:self.environment
                                                              internetReachability:self.internetReachability
                                                                         adManager:self.adManager
                                                                               log:self.log
                                                            logNotificationManager:self.logNotificationManager
                                                           webViewUserAgentService:self.webViewUserAgentService]);
}

- (void)testStartWithAssetKey {
    OguryPersistentEventBus *persistentEventBus = OCMClassMock([OguryPersistentEventBus class]);
    OguryEventBus *broadcastEventBus = OCMClassMock([OguryEventBus class]);
    OCMStub([self.assetKeyManager configureAssetKey:[OCMArg any]]).andReturn(YES);

    [self.internal startWithAssetKey:@"OGY-XXXXXXXX" persistentEventBus:persistentEventBus broadcastEventBus:broadcastEventBus];

    OCMVerify([self.assetKeyManager configureAssetKey:@"OGY-XXXXXXXX"]);
    OCMVerify([self.persistentEventBus setCorePersistentEventBus:persistentEventBus]);
    OCMVerify([self.broadcastEventBus setCoreBroadcastEventBus:broadcastEventBus]);
    OCMVerify([self.internetReachability startNotifier]);
    OCMVerify([self.webViewUserAgentService syncWebViewUserAgent]);
    OCMVerify([self.profigManager registerToBroadcastEventBus]);
    OCMVerify([self.adManager registerToPersistentEventBus]);
}

- (void)testStartWithAssetKey_cannotReconfigureAssetKey {
    OguryPersistentEventBus *persistentEventBus = OCMClassMock([OguryPersistentEventBus class]);
    OguryEventBus *broadcastEventBus = OCMClassMock([OguryEventBus class]);
    OCMStub([self.assetKeyManager configureAssetKey:[OCMArg any]]).andReturn(NO);
    OCMReject([self.internetReachability startNotifier]);
    OCMReject([self.profigManager syncProfigWithCompletion:[OCMArg any]]);

    [self.internal startWithAssetKey:@"OGY-XXXXXXXX" persistentEventBus:persistentEventBus broadcastEventBus:broadcastEventBus];
}

- (void)testSetLogLevel {
    [self.internal setLogLevel:OguryLogLevelOff];
    OCMVerify([self.log setLogLevel:OguryLogLevelOff]);
}

- (void)testActivateNotificationReceiver {
    id receiver = OCMClassMock([OGASetLogLevelNotificationManager class]);
    id internal = [[OGAInternal alloc] initWithPersistentEventBus:self.persistentEventBus
                                                broadcastEventBus:self.broadcastEventBus
                                                  assetKeyManager:self.assetKeyManager
                                                    profigManager:self.profigManager
                                               environmentManager:self.environment
                                             internetReachability:self.internetReachability
                                                        adManager:self.adManager
                                                              log:self.log
                                           logNotificationManager:receiver
                                          webViewUserAgentService:self.webViewUserAgentService];

    // no action required since receiver is directly activated in class init
    XCTAssertNotNil(internal);
    OCMVerify([receiver registerToNotification]);
}

- (void)testResetSDK {
    [self.internal resetSDK];

    OCMVerify([self.assetKeyManager reset]);
    OCMVerify([self.profigManager resetProfig]);
    OCMVerify([self.webViewUserAgentService reset]);
}

- (void)testChangeServerEnvironment {
    [self.internal changeServerEnvironment:@"DEVC"];

    OCMVerify([self.environment updateWith:@"DEVC"]);
}

- (void)testGetVersion {
    XCTAssertTrue([self.internal.getVersion isEqualToString:OGA_SDK_VERSION]);
}

- (void)testDefineMediationName {
    [self.internal defineMediationName:@"name"];

    OCMVerify([self.adManager defineMediationName:@"name"]);
}

- (void)testDefineSDKType {
    [self.internal defineSDKType:1];

    OCMVerify([self.adManager defineSDKType:1]);
}

- (void)testMaxWebViewUserAgentRetryReached {
    OCMStub([self.internal syncProfig]);
    [self.internal maxWebViewUserAgentRetryReached];
    OCMVerify([self.internal syncProfig]);
    OCMVerify([self.log log:OguryLogLevelWarning message:@"Ogury Ads is unable to retreive webview User Agent."]);
}

- (void)testReceivedWebViewUserAgent {
    OCMStub([self.internal syncProfig]);
    [self.internal receivedWebViewUserAgent:@"USER_AGENT"];
    OCMVerify([self.internal syncProfig]);
    OCMStub([self.internal syncProfig]);
}

//- (void)testWhenStartingSDKForTheFirstTimeThenSDKShoudNotBeReset {
//    OguryPersistentEventBus *persistentEventBus = OCMClassMock([OguryPersistentEventBus class]);
//    OguryEventBus *broadcastEventBus = OCMClassMock([OguryEventBus class]);
//    OCMStub(self.assetKeyManager.assetKey).andReturn(nil);
//    OCMStub(self.assetKeyManager.assetKeyHasBeenSet).andReturn(NO);
//    [self.internal startWithAssetKey:@"OGY-XXXXXXXX" persistentEventBus:persistentEventBus broadcastEventBus:broadcastEventBus];
//    OCMReject([self.internal resetSDK]);
//}
//
//- (void)testWhenStartingSDKForTheSecondTimeWithTheSameAssetKeyThenSDKShoudNotBeReset {
//    OguryPersistentEventBus *persistentEventBus = OCMClassMock([OguryPersistentEventBus class]);
//    OguryEventBus *broadcastEventBus = OCMClassMock([OguryEventBus class]);
//    OCMStub(self.assetKeyManager.assetKey).andReturn(nil);
//    OCMStub(self.assetKeyManager.assetKeyHasBeenSet).andReturn(NO);
//    [self.internal startWithAssetKey:@"OGY-XXXXXXXX" persistentEventBus:persistentEventBus broadcastEventBus:broadcastEventBus];
//    [self.internal startWithAssetKey:@"OGY-XXXXXXXX" persistentEventBus:persistentEventBus broadcastEventBus:broadcastEventBus];
//    OCMReject([self.internal resetSDK]);
//}
//
//- (void)testWhenStartingSDKForTheSecondTimeWithADifferentAssetKeyThenSDKShoudNotBeReset {
//    OguryPersistentEventBus *persistentEventBus = OCMClassMock([OguryPersistentEventBus class]);
//    OguryEventBus *broadcastEventBus = OCMClassMock([OguryEventBus class]);
//    OGAAssetKeyManager* assetKeyManager = OCMPartialMock([OGAAssetKeyManager new]);
//    OCMStub(self.internal.assetKeyManager).andReturn(assetKeyManager);
//    [self.internal startWithAssetKey:@"OGY-XXXXXXXX" persistentEventBus:persistentEventBus broadcastEventBus:broadcastEventBus];
//    [self.internal startWithAssetKey:@"OGY-YYYYYYYY" persistentEventBus:persistentEventBus broadcastEventBus:broadcastEventBus];
//    OCMVerify([self.internal resetSDK]);
//}

@end

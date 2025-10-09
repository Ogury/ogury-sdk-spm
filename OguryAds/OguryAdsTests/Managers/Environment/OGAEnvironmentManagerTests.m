//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAEnvironmentManager.h"
#import "OGAAdLogMessage.h"
#import <OCMock/OCMock.h>
#import "OguryError+utility.h"
#import "OGALog.h"
#import "OGAEnvironmentConstants.h"
#import "OGAEnvironmentURLBuilder.h"
#import "OGAAdLogMessage.h"

@interface OGAEnvironmentManager (Test)

@property(nonatomic, assign) OGAEnvironment environment;
@property(nonatomic, strong) OGAEnvironmentURLBuilder *environmentURLBuilder;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) NSNotificationCenter *notificationCenter;

- (instancetype)initWithEnvironment:(OGAEnvironment)environment
              environmentURLBuilder:(OGAEnvironmentURLBuilder *)environmentURLBuilder
                 notificationCenter:(NSNotificationCenter *)notificationCenter
                                log:(OGALog *)log;

+ (OGAEnvironment)environmentToEnum:(NSString *)environment;

- (void)updateWith:(NSString *)environment;

- (void)updateURLs;

+ (OGAEnvironment)getDefaultEnvironment;

@end

@interface OGAEnvironmentManagerTests : XCTestCase

@property(nonatomic, strong) OGAEnvironmentManager *environmentManager;
@property(nonatomic, strong) OGAEnvironmentURLBuilder *environmentURLBuilder;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) NSNotificationCenter *notificationCenter;

@end

@implementation OGAEnvironmentManagerTests

- (void)setUp {
    self.log = OCMClassMock([OGALog class]);
    self.environmentURLBuilder = OCMClassMock([OGAEnvironmentURLBuilder class]);
    self.notificationCenter = OCMClassMock([NSNotificationCenter class]);
    self.environmentManager = OCMPartialMock([[OGAEnvironmentManager alloc] initWithEnvironment:OGAEnvironmentDevC
                                                                          environmentURLBuilder:self.environmentURLBuilder
                                                                             notificationCenter:self.notificationCenter
                                                                                            log:self.log]);
}

- (void)testShared {
    OGAEnvironmentManager *environmentManager = [OGAEnvironmentManager shared];
    XCTAssertNotNil(environmentManager);
    XCTAssertEqual(environmentManager, [OGAEnvironmentManager shared]);
}

- (void)testWhenUpdatingEnvironmentWithAnUnknownValueThenProdEnvironmentShouldBeUsedInstead {
    [self.environmentManager updateWith:@"notAnEnvironment"];
    XCTAssertEqual(self.environmentManager.environment, OGAEnvironmentProd);
}

- (void)testGetDefaultEnvironment {
    OGAEnvironment environment = [OGAEnvironmentManager getDefaultEnvironment];
    XCTAssertEqual(environment, OGAEnvironmentProd);
}

- (void)testWhenRetrievingDefaultEnvironmentWithAnUnknownValueThenProdEnvironmentShouldBeReturnedInstead {
    id environmentManagerMock = OCMClassMock([OGAEnvironmentManager class]);
    OCMStub(ClassMethod([environmentManagerMock environmentToEnum:[OCMArg any]])).andReturn(NSNotFound);
    OGAEnvironment environment = [OGAEnvironmentManager getDefaultEnvironment];
    XCTAssertEqual(environment, OGAEnvironmentProd);
}

- (void)testEnvironmentToEnumFail {
    OGAEnvironment environment = [OGAEnvironmentManager environmentToEnum:@"notAnEnvironment"];
    XCTAssertEqual(environment, NSNotFound);
}

- (void)testEnvironmentToEnum {
    OGAEnvironment environment = [OGAEnvironmentManager environmentToEnum:@"DEVC"];
    XCTAssertEqual(environment, OGAEnvironmentDevC);
}

- (void)testWhenUpdatingEnvironmentThenUrlsAreUpdatedAndNotificationIsSent {
    [self.environmentManager updateWith:@"STAGING"];
    OCMVerify([self.environmentManager updateURLs]);
    XCTAssertEqual(self.environmentManager.environment, OGAEnvironmentStaging);
    OCMVerify([self.notificationCenter postNotificationName:OGAEnvironmentChanged object:nil userInfo:nil]);
}

- (void)testWhenUpdatingEnvironmentWithAnUnknownValueThenAllCallsAreMadeWithDefaultEnvironmentAndLogMessageIsAdded {
    [self.environmentManager updateWith:@"notAnEnvironment"];
    OCMVerify([self.environmentManager updateURLs]);
    XCTAssertEqual(self.environmentManager.environment, OGAEnvironmentProd);
    OGAAdLogMessage *message = [[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                                      adConfiguration:nil
                                                              logType:OguryLogTypeInternal
                                                              message:@"wrong environment submitted (notAnEnvironment), setting environment to production"
                                                                 tags:nil];
    OCMVerify([self.log log:message]);
    OCMVerify([self.notificationCenter postNotificationName:OGAEnvironmentChanged object:nil userInfo:nil]);
}

- (void)testUpdateURLs {
    NSURL *adSyncURL = OCMClassMock([NSURL class]);
    OCMStub([self.environmentURLBuilder buildAdSyncURL]).andReturn(adSyncURL);
    NSURL *launchURL = OCMClassMock([NSURL class]);
    OCMStub([self.environmentURLBuilder buildLaunchURL]).andReturn(launchURL);
    NSURL *preCacheURL = OCMClassMock([NSURL class]);
    OCMStub([self.environmentURLBuilder buildPreCacheURL]).andReturn(preCacheURL);
    NSURL *profigURL = OCMClassMock([NSURL class]);
    OCMStub([self.environmentURLBuilder buildProfigURL]).andReturn(profigURL);
    NSURL *trackURL = OCMClassMock([NSURL class]);
    OCMStub([self.environmentURLBuilder buildTrackURL]).andReturn(trackURL);
    NSURL *adHistoryURL = OCMClassMock([NSURL class]);
    OCMStub([self.environmentURLBuilder buildAdHistoryURL]).andReturn(adHistoryURL);
    NSURL *monitoringURL = OCMClassMock([NSURL class]);
    OCMStub([self.environmentURLBuilder buildMonitoringURL]).andReturn(monitoringURL);
    [self.environmentManager updateURLs];
    XCTAssertEqual(self.environmentManager.adSyncURL, adSyncURL);
    XCTAssertEqual(self.environmentManager.launchURL, launchURL);
    XCTAssertEqual(self.environmentManager.preCacheURL, preCacheURL);
    XCTAssertEqual(self.environmentManager.profigURL, profigURL);
    XCTAssertEqual(self.environmentManager.trackURL, trackURL);
    XCTAssertEqual(self.environmentManager.adHistoryURL, adHistoryURL);
    XCTAssertEqual(self.environmentManager.monitoringURL, monitoringURL);
}

- (void)testCallingInternalInitializedThenAllSetUpMethodsAreCalled {
    OGALog *log = OCMClassMock([OGALog class]);
    OGAEnvironmentURLBuilder *environmentURLBuilder = OCMClassMock([OGAEnvironmentURLBuilder class]);
    NSNotificationCenter *notificationCenter = OCMClassMock([NSNotificationCenter class]);
    OGAEnvironmentManager *environmentManager = OCMPartialMock([[OGAEnvironmentManager alloc] initWithEnvironment:OGAEnvironmentStaging
                                                                                            environmentURLBuilder:environmentURLBuilder
                                                                                               notificationCenter:notificationCenter
                                                                                                              log:log]);
    XCTAssertNotNil(environmentManager);
    XCTAssertEqual(environmentManager.environmentURLBuilder, environmentURLBuilder);
    XCTAssertEqual(environmentManager.notificationCenter, notificationCenter);
    XCTAssertEqual(environmentManager.log, log);
    XCTAssertEqual(environmentManager.environment, OGAEnvironmentStaging);
}

@end

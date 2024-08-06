//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGALog.h"
#import <OCMock/OCMock.h>
#import "OGAProfigDao.h"
#import "OGANSUserDefaultsMock.h"
#import "OGAProfigFullResponse+Parser.h"

@interface OGAProfigDaoTests : XCTestCase

@property(nonatomic, strong) OGANSUserDefaultsMock *mockedUserDefault;
@property(nonatomic, strong) OGALog *log;
@property(atomic, strong) NSURLResponse *urlResponse;

@end

@interface OGAProfigDao ()

- (id)initWithUserDefaults:(NSUserDefaults *)userDefault log:(OGALog *)log;
- (OGAProfigDao *)load;
- (NSOperationQueue *)daoQueue;
- (void)handleMigrationIfNeeded;

@end

@implementation OGAProfigDaoTests

- (void)setUp {
    self.mockedUserDefault = [[OGANSUserDefaultsMock alloc] init];
    self.log = OCMClassMock([OGALog class]);
    self.urlResponse = OCMClassMock([NSURLResponse class]);
}

- (void)tearDown {
    self.mockedUserDefault = nil;
}

- (void)testInit {
    OGAProfigDao *profigDao = [[OGAProfigDao alloc] init];
    XCTAssertNotNil(profigDao);
}

- (void)testLoad {
    OGAProfigDao *profigDao = [[OGAProfigDao alloc] initWithUserDefaults:self.mockedUserDefault log:self.log];
    XCTAssertNotNil(profigDao);
    [profigDao load];
    XCTAssertNotNil(profigDao.profigParams);
    XCTAssertNil(profigDao.profigFullResponse);
    XCTAssertNil(profigDao.lastProfigSyncDate);
    XCTAssertNil(profigDao.profigInstanceToken);

    NSString *profigJson = [[NSBundle bundleForClass:[self class]] pathForResource:@"testProfigJSON1" ofType:@"json"];
    NSData *profigJsonData = [NSData dataWithContentsOfFile:profigJson];
    OGAProfigFullResponse *profigResponse = [OGAProfigFullResponse parseProfigResponseWithData:profigJsonData urlResponse:self.urlResponse];

    self.mockedUserDefault.dict[LAST_INSTANCE_TOKEN_PROFIG_PARAM_IDLESS] = @"instance_token";
    self.mockedUserDefault.dict[@"fullProfigResponseIdLessJsonKey"] = [profigResponse toJSONString];
    self.mockedUserDefault.dict[PROFIG_LAST_PROFIG_SYNC_IDLESS] = [NSDate dateWithTimeIntervalSince1970:9000];
    [profigDao load];

    XCTAssertNotNil(profigDao.profigParams);
    XCTAssertNotNil(profigDao.profigFullResponse);
    XCTAssertNotNil(profigDao.lastProfigSyncDate);
    XCTAssertNotNil(profigDao.profigInstanceToken);
    XCTAssertEqual([[profigDao.profigParams allKeys] count], 4);
    XCTAssertEqualObjects(profigDao.profigInstanceToken, @"instance_token");
    XCTAssertEqualObjects(profigDao.lastProfigSyncDate, [NSDate dateWithTimeIntervalSince1970:9000]);
    XCTAssertEqualObjects(profigDao.profigFullResponse.webviewLoadTimeout, profigResponse.webviewLoadTimeout);
    XCTAssertEqualObjects(profigDao.profigFullResponse.maxProfigApiCallsPerDay, profigResponse.maxProfigApiCallsPerDay);
    XCTAssertEqualObjects(profigDao.profigFullResponse.webviewLoadTimeout, profigResponse.webviewLoadTimeout);
    XCTAssertEqualObjects(profigDao.profigFullResponse.adExpirationTime, profigResponse.adExpirationTime);
    XCTAssertEqualObjects(profigDao.profigFullResponse.showCloseButtonDelay, profigResponse.showCloseButtonDelay);
    XCTAssertEqualObjects(profigDao.profigFullResponse.retryInterval, profigResponse.retryInterval);
    XCTAssertTrue(profigDao.profigFullResponse.closeAdWhenLeavingApp == profigResponse.closeAdWhenLeavingApp);
    XCTAssertEqualObjects(profigDao.profigFullResponse.webviewLoadTimeout, profigResponse.webviewLoadTimeout);
    XCTAssertEqualObjects(profigDao.profigFullResponse.adExpirationTime, profigResponse.adExpirationTime);
    XCTAssertEqualObjects(profigDao.profigFullResponse.showCloseButtonDelay, profigResponse.showCloseButtonDelay);
}

- (void)testSync {
    OGAProfigDao *profigDao = [[OGAProfigDao alloc] initWithUserDefaults:self.mockedUserDefault log:self.log];
    XCTAssertNotNil(profigDao);
    XCTAssertNotNil(profigDao.profigParams);
    XCTAssertNil(profigDao.profigFullResponse);
    XCTAssertNil(profigDao.lastProfigSyncDate);
    XCTAssertNil(profigDao.profigInstanceToken);

    NSString *profigJson = [[NSBundle bundleForClass:[self class]] pathForResource:@"testProfigJSON1" ofType:@"json"];
    NSData *profigJsonData = [NSData dataWithContentsOfFile:profigJson];
    OGAProfigFullResponse *profigResponse = [OGAProfigFullResponse parseProfigResponseWithData:profigJsonData urlResponse:self.urlResponse];
    profigDao.profigFullResponse = profigResponse;

    profigDao.profigInstanceToken = @"instance_token";
    profigDao.lastProfigSyncDate = [NSDate dateWithTimeIntervalSince1970:9000];
    [profigDao sync];

    XCTAssertNotNil(profigDao.profigParams);
    XCTAssertNotNil(profigDao.profigFullResponse);
    XCTAssertNotNil(profigDao.lastProfigSyncDate);
    XCTAssertNotNil(profigDao.profigInstanceToken);
    XCTAssertEqual([[profigDao.profigParams allKeys] count], 4);
    XCTAssertEqualObjects(profigDao.profigInstanceToken, @"instance_token");
    XCTAssertEqualObjects(profigDao.lastProfigSyncDate, [NSDate dateWithTimeIntervalSince1970:9000]);
    XCTAssertEqualObjects(profigDao.profigFullResponse.webviewLoadTimeout, profigResponse.webviewLoadTimeout);
    XCTAssertEqualObjects(profigDao.profigFullResponse.maxProfigApiCallsPerDay, profigResponse.maxProfigApiCallsPerDay);
    XCTAssertEqualObjects(profigDao.profigFullResponse.webviewLoadTimeout, profigResponse.webviewLoadTimeout);
    XCTAssertEqualObjects(profigDao.profigFullResponse.adExpirationTime, profigResponse.adExpirationTime);
    XCTAssertEqualObjects(profigDao.profigFullResponse.showCloseButtonDelay, profigResponse.showCloseButtonDelay);
    XCTAssertEqualObjects(profigDao.profigFullResponse.retryInterval, profigResponse.retryInterval);
    XCTAssertTrue(profigDao.profigFullResponse.closeAdWhenLeavingApp == profigResponse.closeAdWhenLeavingApp);
    XCTAssertEqualObjects(profigDao.profigFullResponse.webviewLoadTimeout, profigResponse.webviewLoadTimeout);
    XCTAssertEqualObjects(profigDao.profigFullResponse.adExpirationTime, profigResponse.adExpirationTime);
    XCTAssertEqualObjects(profigDao.profigFullResponse.showCloseButtonDelay, profigResponse.showCloseButtonDelay);
}

- (void)testReset {
    NSUserDefaults *userDefaults = OCMClassMock([NSUserDefaults class]);
    OGAProfigDao *profigDao = [[OGAProfigDao alloc] initWithUserDefaults:userDefaults log:self.log];
    NSString *profigJson = [[NSBundle bundleForClass:[self class]] pathForResource:@"testProfigJSON1" ofType:@"json"];
    NSData *profigJsonData = [NSData dataWithContentsOfFile:profigJson];
    OGAProfigFullResponse *profigResponse = [OGAProfigFullResponse parseProfigResponseWithData:profigJsonData urlResponse:self.urlResponse];
    profigDao.profigFullResponse = profigResponse;
    [profigDao reset];

    XCTAssertEqualObjects(profigDao.profigFullResponse.retryInterval, @0);
    OCMVerify([userDefaults removeObjectForKey:FULL_PROFIG_RESPONSE_JSON_IDLESS]);
    OCMVerify([userDefaults removeObjectForKey:PROFIG_LAST_PROFIG_SYNC_IDLESS]);
}

- (void)testUpdateWithFullProfig {
    OGAProfigDao *profigDao = [[OGAProfigDao alloc] initWithUserDefaults:self.mockedUserDefault log:self.log];
    XCTAssertNotNil(profigDao);
    XCTAssertNotNil(profigDao.profigParams);
    XCTAssertNil(profigDao.profigFullResponse);
    XCTAssertNil(profigDao.lastProfigSyncDate);
    XCTAssertNil(profigDao.profigInstanceToken);

    NSString *profigJson = [[NSBundle bundleForClass:[self class]] pathForResource:@"testProfigJSON1" ofType:@"json"];
    NSData *profigJsonData = [NSData dataWithContentsOfFile:profigJson];
    OGAProfigFullResponse *profigResponse = [OGAProfigFullResponse parseProfigResponseWithData:profigJsonData urlResponse:self.urlResponse];

    profigDao.profigInstanceToken = @"instance_token";
    profigDao.lastProfigSyncDate = [NSDate dateWithTimeIntervalSince1970:9000];
    [profigDao updateWithFullProfig:profigResponse];

    XCTAssertNotNil(profigDao.profigParams);
    XCTAssertNotNil(profigDao.profigFullResponse);
    XCTAssertNotNil(profigDao.lastProfigSyncDate);
    XCTAssertNotNil(profigDao.profigInstanceToken);
    XCTAssertEqual([[profigDao.profigParams allKeys] count], 4);
    XCTAssertNotEqualObjects(profigDao.profigInstanceToken, @"instance_token");
    XCTAssertNotEqualObjects(profigDao.lastProfigSyncDate, [NSDate dateWithTimeIntervalSince1970:9000]);
    XCTAssertEqualObjects(profigDao.profigFullResponse.webviewLoadTimeout, profigResponse.webviewLoadTimeout);
    XCTAssertEqualObjects(profigDao.profigFullResponse.maxProfigApiCallsPerDay, profigResponse.maxProfigApiCallsPerDay);
    XCTAssertEqualObjects(profigDao.profigFullResponse.webviewLoadTimeout, profigResponse.webviewLoadTimeout);
    XCTAssertEqualObjects(profigDao.profigFullResponse.adExpirationTime, profigResponse.adExpirationTime);
    XCTAssertEqualObjects(profigDao.profigFullResponse.showCloseButtonDelay, profigResponse.showCloseButtonDelay);
    XCTAssertEqualObjects(profigDao.profigFullResponse.retryInterval, profigResponse.retryInterval);
    XCTAssertTrue(profigDao.profigFullResponse.closeAdWhenLeavingApp == profigResponse.closeAdWhenLeavingApp);
    XCTAssertEqualObjects(profigDao.profigFullResponse.webviewLoadTimeout, profigResponse.webviewLoadTimeout);
    XCTAssertEqualObjects(profigDao.profigFullResponse.adExpirationTime, profigResponse.adExpirationTime);
    XCTAssertEqualObjects(profigDao.profigFullResponse.showCloseButtonDelay, profigResponse.showCloseButtonDelay);
}

- (void)testDaoQueue {
    OGAProfigDao *profigDao = [[OGAProfigDao alloc] initWithUserDefaults:self.mockedUserDefault log:self.log];
    NSOperationQueue *queue = [profigDao daoQueue];
    XCTAssertNotNil(profigDao);
    XCTAssertNotNil(queue);
}

- (void)testWhenProfigIsSavedAndRetrievedThenAllFieldsAreSet {
    NSString *profigJson = [[NSBundle bundleForClass:[self class]] pathForResource:@"testProfigJSON1_permission" ofType:@"json"];
    NSData *profigJsonData = [NSData dataWithContentsOfFile:profigJson];
    OGAProfigFullResponse *profig = [OGAProfigFullResponse parseProfigResponseWithData:profigJsonData urlResponse:self.urlResponse];
    OGAProfigDao *profigDao = [[OGAProfigDao alloc] init];
    [profigDao updateWithFullProfig:profig];
    XCTAssertEqualObjects(profigDao.profigFullResponse, profig);
    [profigDao sync];
    // just for the operationQueue to dequeue saving
    [NSThread sleepForTimeInterval:1];
    NSString *savedProfigJson = [[NSUserDefaults standardUserDefaults] stringForKey:@"fullProfigResponseIdLessJsonKey"];
    XCTAssertNotNil(savedProfigJson);
    OGAProfigFullResponse *retrievedProfig = [[OGAProfigFullResponse alloc] initWithString:savedProfigJson error:nil];
    XCTAssertNotNil(retrievedProfig);
    XCTAssertEqualObjects(profig, retrievedProfig);
    [profigDao load];
    XCTAssertEqualObjects(profigDao.profigFullResponse, profig);
}

- (void)testWhenProfigWithErrorIsSavedAndRetrievedThenAllFieldsAreSet {
    NSString *profigJson = [[NSBundle bundleForClass:[self class]] pathForResource:@"testProfigError" ofType:@"json"];
    NSData *profigJsonData = [NSData dataWithContentsOfFile:profigJson];
    OGAProfigFullResponse *profig = [OGAProfigFullResponse parseProfigResponseWithData:profigJsonData urlResponse:self.urlResponse];
    OGAProfigDao *profigDao = [[OGAProfigDao alloc] init];
    [profigDao updateWithFullProfig:profig];
    XCTAssertEqualObjects(profigDao.profigFullResponse, profig);
    [profigDao sync];
    // just for the operationQueue to dequeue saving
    [NSThread sleepForTimeInterval:1];
    NSString *savedProfigJson = [[NSUserDefaults standardUserDefaults] stringForKey:@"fullProfigResponseIdLessJsonKey"];
    XCTAssertNotNil(savedProfigJson);
    OGAProfigFullResponse *retrievedProfig = [[OGAProfigFullResponse alloc] initWithString:savedProfigJson error:nil];
    XCTAssertNotNil(retrievedProfig);
    XCTAssertEqualObjects(profig.errorType, retrievedProfig.errorType);
    XCTAssertEqualObjects(profig.errorMessage, retrievedProfig.errorMessage);
    XCTAssertEqualObjects(profig.retryInterval, retrievedProfig.retryInterval);
    [profigDao load];
    XCTAssertEqualObjects(profigDao.profigFullResponse.errorType, profig.errorType);
    XCTAssertEqualObjects(profigDao.profigFullResponse.errorMessage, profig.errorMessage);
    XCTAssertEqualObjects(profigDao.profigFullResponse.retryInterval, profig.retryInterval);
}

- (void)testWhenOldProfigIsSavedThenMigrationShouldOccur {
    OGANSUserDefaultsMock *mockedUD = OCMPartialMock([[OGANSUserDefaultsMock alloc] init]);
    OCMStub([mockedUD stringForKey:PROFIG_FULL_PROFIG_RESPONSE_JSON]).andReturn(@"");
    OGAProfigDao *profigDao = [[OGAProfigDao alloc] initWithUserDefaults:mockedUD log:self.log];
    XCTAssertTrue([profigDao shouldMigrateToIdless]);
}

- (void)testWhenOldProfigIsNotSavedThenMigrationShoulNotdOccur {
    OGANSUserDefaultsMock *mockedUD = OCMPartialMock([[OGANSUserDefaultsMock alloc] init]);
    OCMStub([mockedUD stringForKey:PROFIG_FULL_PROFIG_RESPONSE_JSON]).andReturn(nil);
    OGAProfigDao *profigDao = [[OGAProfigDao alloc] initWithUserDefaults:mockedUD log:self.log];
    XCTAssertFalse([profigDao shouldMigrateToIdless]);
}

- (void)testWhenOldProfigIsSavedThenItShouldBeDeletedUponMigration {
    OGANSUserDefaultsMock *mockedUD = OCMPartialMock([[OGANSUserDefaultsMock alloc] init]);
    OCMStub([mockedUD stringForKey:PROFIG_FULL_PROFIG_RESPONSE_JSON]).andReturn(@"");
    OGAProfigDao *profigDao = [[OGAProfigDao alloc] initWithUserDefaults:mockedUD log:self.log];
    [profigDao handleMigrationIfNeeded];
    OCMVerify([mockedUD removeObjectForKey:@"fullProfigResponseJsonKey"]);
}

- (void)testWhenOldProfigIsNotSavedThenItShouldBeDeletedUponMigration {
    OGANSUserDefaultsMock *mockedUD = OCMPartialMock([[OGANSUserDefaultsMock alloc] init]);
    OCMStub([mockedUD stringForKey:PROFIG_FULL_PROFIG_RESPONSE_JSON]).andReturn(nil);
    OGAProfigDao *profigDao = [[OGAProfigDao alloc] initWithUserDefaults:mockedUD log:self.log];
    [profigDao handleMigrationIfNeeded];
    OCMReject([mockedUD removeObjectForKey:@"fullProfigResponseJsonKey"]);
}

@end

//
//  Copyright © 2015 - 25/07/2022 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGWModules.h"
#import "OGWSetLogLevelNotificationManager.h"
#import "OGWWrapper.h"
#import "OGWErrorMessage.h"
#import "OguryError+OGWWrapper.h"

@interface OGWWrapper (Testing)


@property(nonatomic, strong) OGWModules *modules;
@property(nonatomic, strong) NSUserDefaults *userDefault;

- (instancetype)initWithModules:(OGWModules *)modules
         logNotificationManager:(OGWSetLogLevelNotificationManager *)logNotificationManager
                    userDefault:(NSUserDefaults *)userDefault;

@end

@interface OGWWrapperTests : XCTestCase

@end

@implementation OGWWrapperTests

- (void)testLogNotificationRegister {
    id modules = OCMClassMock([OGWModules class]);
    id receiver = OCMClassMock([OGWSetLogLevelNotificationManager class]);
    id userDefault = OCMClassMock([NSUserDefaults class]);
    
    id wrapperInstant = [[OGWWrapper alloc] initWithModules:modules
                                     logNotificationManager:receiver
                                                userDefault:userDefault];
    
    // no action need since the register is triggered in OGWWrapper's init
    XCTAssertNotNil(wrapperInstant);
    OCMVerify([receiver registerToNotification]);
}

- (void)testStartWithConfigurationCompletionHandlerNoModuleFound {
    OguryConfiguration *configuration = OCMClassMock([OguryConfiguration class]);
    id modules = OCMClassMock([OGWModules class]);
    id receiver = OCMClassMock([OGWSetLogLevelNotificationManager class]);
    id userDefault = OCMClassMock([NSUserDefaults class]);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Completion handler called"];
    OGWWrapper *wrapperInstant = OCMPartialMock([[OGWWrapper alloc] initWithModules:modules logNotificationManager:receiver userDefault:userDefault]);
    [wrapperInstant startWithConfiguration:configuration completionHandler:^(BOOL success, OguryError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(error.localizedDescription, OGWErrorNoSdkModuleFoundMessage);
        XCTAssertEqual(error.code, OGWErrorNoSdkModuleFound);
        XCTAssertFalse(success);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testStartWithConfigurationCompletionHandlerModuleFound {
    OguryConfiguration *configuration = OCMClassMock([OguryConfiguration class]);
    id modules = OCMClassMock([OGWModules class]);
    id receiver = OCMClassMock([OGWSetLogLevelNotificationManager class]);
    id userDefault = OCMClassMock([NSUserDefaults class]);
    OGWWrapper *wrapperInstant = OCMPartialMock([[OGWWrapper alloc] initWithModules:modules logNotificationManager:receiver userDefault:userDefault]);
    OCMStub(wrapperInstant.modules).andReturn([[OGWModules alloc] init]);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Completion handler called"];
    [wrapperInstant startWithConfiguration:configuration completionHandler:^(BOOL success, OguryError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertTrue(success);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

@end

//
//  Copyright © 2015 - 25/07/2022 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGWModulesManager.h"
#import "OGWSetLogLevelNotificationManager.h"
#import "OGWWrapper.h"
#import "OGWErrorMessage.h"
#import "OguryError+OGWWrapper.h"
#import "OGWLog.h"

@interface OGWWrapper (Testing)

@property(nonatomic, strong) OGWModulesManager *modulesManager;
@property(nonatomic, strong) NSUserDefaults *userDefault;
@property(nonatomic, strong) OGWLog *log;
@property(nonatomic, strong) OGWSetLogLevelNotificationManager *logNotificationManager;

- (instancetype)initWithModules:(OGWModulesManager *)modules
         logNotificationManager:(OGWSetLogLevelNotificationManager *)logNotificationManager
                    userDefault:(NSUserDefaults *)userDefault
                            log:(OGWLog *)log;

@end

@interface OGWWrapperTests : XCTestCase

@property(nonatomic, strong) OGWModulesManager *modulesManager;
@property(nonatomic, strong) NSUserDefaults *userDefault;
@property(nonatomic, strong) id log;
@property(nonatomic, strong) OGWSetLogLevelNotificationManager *logNotificationManager;
@property(nonatomic, strong) NSString *assetKey;
@property(nonatomic, strong) OGWWrapper *wrapper;

@end

@implementation OGWWrapperTests

- (void)setUp {
    self.modulesManager = OCMClassMock([OGWModulesManager class]);
    self.userDefault = OCMClassMock([NSUserDefaults class]);
    self.log = OCMClassMock([OGWLog class]);
    self.logNotificationManager = OCMClassMock([OGWSetLogLevelNotificationManager class]);
    self.assetKey = @"TestAssetKey";
    self.wrapper = OCMPartialMock([[OGWWrapper alloc] initWithModules:self.modulesManager
                                               logNotificationManager:self.logNotificationManager
                                                          userDefault:self.userDefault
                                                                  log:self.log]);
}

- (void)testLogNotificationRegister {
    XCTAssertNotNil(self.wrapper);
    OCMVerify([self.logNotificationManager registerToNotification]);
}

- (void)testStartWithNoModulesPresent {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Completion handler called"];
    OCMExpect([self.log logAssetKey:OguryLogLevelError
                                   assetKey:self.assetKey
                                    message:@"No Ogury module found in your application."]);
        
    [self.wrapper startWith:self.assetKey completionHandler:^(BOOL success, OguryError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(error.localizedDescription, OGWErrorNoSdkModuleFoundMessage);
        XCTAssertEqual(error.code, OguryStartErrorCodeNoModuleFound);
        XCTAssertFalse(success);
        [expectation fulfill]; 
    }];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    OCMVerifyAll(self.log);
}

- (void)testStartWithAllModulesSucceeding {
    OGWModule *module1 = OCMClassMock([OGWModule class]);
    OGWModule *module2 = OCMClassMock([OGWModule class]);
    NSArray *modules = @[module1, module2];
    OCMStub([module1 isPresent]).andReturn(YES);
    OCMStub([module2 isPresent]).andReturn(YES);
    OCMStub([module1 className]).andReturn(@"Module1");
    OCMStub([module2 className]).andReturn(@"Module2");
    OCMStub(self.modulesManager.modules).andReturn(modules);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Completion handler called"];
    
    [[self.log expect] logAssetKeyFormat:OguryLogLevelDebug
                                assetKey:self.assetKey
                                  format:@"Module [%@] initialization..." ,@"Module1"];
    [[self.log expect] logAssetKeyFormat:OguryLogLevelDebug
                                assetKey:self.assetKey
                                  format:@"Module [%@] initialization..." ,@"Module2"];
    [[self.log expect] logAssetKeyFormat:OguryLogLevelDebug
                                assetKey:self.assetKey
                                  format:@"Ogury Start() ended succesfully for modules :%@" ,@"\nModule1\nModule2"];
    
    OCMStub([module1 startWith:self.assetKey
                     completionHandler:([OCMArg invokeBlockWithArgs:@(YES), [NSNull null], nil])]);
    OCMStub([module2 startWith:self.assetKey
                     completionHandler:([OCMArg invokeBlockWithArgs:@(YES), [NSNull null], nil])]);
    [self.wrapper startWith:self.assetKey completionHandler:^(BOOL success, OguryError * _Nullable error) {
        XCTAssertTrue(success);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
    OCMVerifyAll(self.log);
}

- (void)testStartWithModulesFailing {
    OGWModule *module1 = OCMClassMock([OGWModule class]);
    OGWModule *module2 = OCMClassMock([OGWModule class]);
    NSArray *modules = @[module1, module2];
    OCMStub([module1 isPresent]).andReturn(YES);
    OCMStub([module2 isPresent]).andReturn(YES);
    OCMStub([module1 className]).andReturn(@"Module1");
    OCMStub([module2 className]).andReturn(@"Module2");
    OCMStub(self.modulesManager.modules).andReturn(modules);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Completion handler called"];
    
    [[self.log expect] logAssetKeyFormat:OguryLogLevelDebug
                                assetKey:self.assetKey
                                  format:@"Module [%@] initialization..." ,@"Module1"];
    [[self.log expect] logAssetKeyFormat:OguryLogLevelDebug
                                assetKey:self.assetKey
                                  format:@"Module [%@] initialization..." ,@"Module2"];
    
    OguryError *error1 = [OguryError errorWithDomain:@"OguryErrorDomain"
                                                code:3001
                                            userInfo:@{NSLocalizedDescriptionKey: @"Module1 failed"}];
    OguryError *error2 = [OguryError errorWithDomain:@"OguryErrorDomain"
                                                code:6002
                                            userInfo:@{NSLocalizedDescriptionKey: @"Module2 failed to start."}];
    
    OCMStub([module1 startWith:self.assetKey
                     completionHandler:([OCMArg invokeBlockWithArgs:@(NO), error1, nil])]);
    OCMStub([module2 startWith:self.assetKey
                     completionHandler:([OCMArg invokeBlockWithArgs:@(NO), error2, nil])]);
    
    
    [[self.log expect] logAssetKeyFormat:OguryLogLevelError
                                assetKey:self.assetKey
                                  format:@"Error found during the Ogury Start() call :%@" ,@"\nModule1 failed\nModule2 failed"];
        
    [self.wrapper startWith:self.assetKey completionHandler:^(BOOL success, OguryError * _Nullable error) {
        XCTAssertFalse(success);
        XCTAssertNotNil(error);
        XCTAssertTrue([error.localizedDescription containsString:error1.localizedDescription]);
        XCTAssertTrue([error.localizedDescription containsString:error2.localizedDescription]);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
    OCMVerifyAll(self.log);
}

- (void)testStartWithSomeModulesSucceedingSomeFailing {
    OGWModule *module1 = OCMClassMock([OGWModule class]);
    OGWModule *module2 = OCMClassMock([OGWModule class]);
    OGWModule *module3 = OCMClassMock([OGWModule class]);
    NSArray *modules = @[module1, module2, module3];
    OCMStub([module1 isPresent]).andReturn(YES);
    OCMStub([module2 isPresent]).andReturn(YES);
    OCMStub([module3 isPresent]).andReturn(YES);
    OCMStub([module1 className]).andReturn(@"Module1");
    OCMStub([module2 className]).andReturn(@"Module2");
    OCMStub([module3 className]).andReturn(@"Module3");
    OCMStub(self.modulesManager.modules).andReturn(modules);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Completion handler called"];
    
    [[self.log expect] logAssetKeyFormat:OguryLogLevelDebug
                                assetKey:self.assetKey
                                  format:@"Module [%@] initialization..." ,@"Module1"];
    [[self.log expect] logAssetKeyFormat:OguryLogLevelDebug
                                assetKey:self.assetKey
                                  format:@"Module [%@] initialization..." ,@"Module2"];
    [[self.log expect] logAssetKeyFormat:OguryLogLevelDebug
                                assetKey:self.assetKey
                                  format:@"Module [%@] initialization..." ,@"Module3"];
    
    OguryError *errorModule3 = [OguryError errorWithDomain:@"OguryErrorDomain"
                                                code:9002
                                            userInfo:@{NSLocalizedDescriptionKey: @"Module3 failed"}];
    
    [[self.log expect] logAssetKeyFormat:OguryLogLevelError
                                assetKey:self.assetKey
                                  format:@"Error found during the Ogury Start() call :%@" ,[OCMArg any]];
    
    
    
    OCMStub([module1 startWith:self.assetKey
                     completionHandler:([OCMArg invokeBlockWithArgs:@(YES), [NSNull null], nil])]);
    OCMStub([module2 startWith:self.assetKey
                     completionHandler:([OCMArg invokeBlockWithArgs:@(YES), [NSNull null], nil])]);
    OCMStub([module3 startWith:self.assetKey
                     completionHandler:([OCMArg invokeBlockWithArgs:@(NO), errorModule3, nil])]);
    
    [self.wrapper startWith:self.assetKey completionHandler:^(BOOL success, OguryError * _Nullable error) {
        XCTAssertFalse(success);
        XCTAssertNotNil(error);
        XCTAssertTrue([error.localizedDescription containsString:errorModule3.localizedDescription]);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
    OCMVerifyAll(self.log);
}

- (void)testStartWithCompletionHandlerNil {
    OGWModule *module = OCMClassMock([OGWModule class]);
    NSArray *modules = @[module];
    OCMStub([module isPresent]).andReturn(YES);
    OCMStub([module className]).andReturn(@"Module");
    OCMStub(self.modulesManager.modules).andReturn(modules);
    
    [[self.log expect] logAssetKeyFormat:OguryLogLevelDebug
                                assetKey:self.assetKey
                                  format:@"Module [%@] initialization..." ,@"Module"];
    
    OCMStub([module startWith:self.assetKey
                     completionHandler:([OCMArg invokeBlockWithArgs:@(YES), [NSNull null], nil])]);
    
    [self.wrapper startWith:self.assetKey completionHandler:nil];
    OCMVerifyAll(self.log);
}

@end

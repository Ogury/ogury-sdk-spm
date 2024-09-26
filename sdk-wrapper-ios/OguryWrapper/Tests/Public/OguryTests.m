//
//  OguryTests.m
//

#import <XCTest/XCTest.h>
#import "Ogury.h"
#import "OGWWrapper.h"
#import "OGWLog.h"
#import <OCMock/OCMock.h>

@interface OguryTests : XCTestCase

@property (nonatomic, strong) id mockOGWWrapper;
@property (nonatomic, strong) id mockOGWLog;
@property (nonatomic, strong) id mockOGCInternal;

@end

@implementation OguryTests

- (void)setUp {
    self.mockOGWWrapper = OCMClassMock([OGWWrapper class]);
    OCMStub([self.mockOGWWrapper shared]).andReturn(self.mockOGWWrapper);
    self.mockOGWLog = OCMClassMock([OGWLog class]);
    OCMStub([self.mockOGWLog shared]).andReturn(self.mockOGWLog);
    self.mockOGCInternal = OCMClassMock([OGCInternal class]);
    OCMStub([self.mockOGCInternal shared]).andReturn(self.mockOGCInternal);
}

- (void)testStartWithConfiguration {
    id mockOgury = OCMClassMock([Ogury class]);
    OguryConfiguration *mockConfiguration = OCMClassMock([OguryConfiguration class]);
    OCMExpect([mockOgury startWithConfiguration:mockConfiguration completionHandler:nil]);
    [Ogury startWithConfiguration:mockConfiguration];
    OCMVerifyAll(mockOgury);
}

- (void)testStartWithConfigurationCompletionHandler {
    OguryConfiguration *mockConfiguration = OCMClassMock([OguryConfiguration class]);
    StartCompletionBlock mockCompletionHandler = ^(BOOL success, NSError *error) {};
    OCMExpect([self.mockOGWWrapper startWithConfiguration:mockConfiguration completionHandler:mockCompletionHandler]);
    [Ogury startWithConfiguration:mockConfiguration completionHandler:mockCompletionHandler];
    OCMVerifyAll(self.mockOGWWrapper);
}

- (void)testSetLogLevel {
    OCMExpect([self.mockOGWWrapper setLogLevel:OguryLogLevelAll]);
    OCMExpect([self.mockOGWLog setLogLevel:OguryLogLevelAll]);
    [Ogury setLogLevel:OguryLogLevelAll];
    OCMVerifyAll(self.mockOGWWrapper);
    OCMVerifyAll(self.mockOGWLog);
}

- (void)testSdkVersion {
    XCTAssertEqual([Ogury sdkVersion], SDK_VERSION);
}

- (void)testRegisterAttributionForSKAdNetwork {
    OCMExpect([self.mockOGWWrapper registerAttributionForSKAdNetwork]);
    [Ogury registerAttributionForSKAdNetwork];
    OCMVerifyAll(self.mockOGWWrapper);
}

- (void)testStorePrivacyDataBoolean {
    OCMExpect([self.mockOGCInternal setPrivacyData:@"key" boolean:true]);
    [Ogury setPrivacyData:@"key" boolean:true];
    OCMVerifyAll(self.mockOGCInternal);
}

- (void)testStorePrivacyDataInteger {
    NSInteger value = 10;
    OCMExpect([self.mockOGCInternal setPrivacyData:@"key" integer:value]);
    [Ogury setPrivacyData:@"key" integer:value];
    OCMVerifyAll(self.mockOGCInternal);
}

- (void)testStorePrivacyDataString {
    NSString *value = @"value";
    OCMExpect([self.mockOGCInternal setPrivacyData:@"key" string:value]);
    [Ogury setPrivacyData:@"key" string:value];
    OCMVerifyAll(self.mockOGCInternal);
}

@end

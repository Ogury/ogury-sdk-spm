//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGALog.h"
#import <OguryCore/OguryLog.h>
#import <OguryCore/OguryOSLogger.h>
#import "OGAAdConfiguration.h"

@import OguryAds.Private;

@interface OGALog ()

@property(nonatomic, strong) OguryLog *oguryLog;

- (NSString *)formatError:(NSError *)error;
@property(nonatomic, copy, nullable) void (^testCompletionBlock)(NSString *, OguryLogLevel);

@end

@interface OGALogTests : XCTestCase

@property(nonatomic, strong) NSError *expectedError;
@property(nonatomic, strong) OGAAdConfiguration *adConfig;
@property(nonatomic, strong) NSString *webviewId;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) OguryLog *oguryLog;
@property(nonatomic, strong) OGADelegateDispatcher *delegateDispatcher;

@end

@implementation OGALogTests

- (void)setUp {
    self.expectedError = [NSError errorWithDomain:@"domain.test" code:404 userInfo:nil];
    self.delegateDispatcher = OCMClassMock([OGADelegateDispatcher class]);
    self.adConfig = [[OGAAdConfiguration alloc] initWithType:OguryAdsTypeInterstitial
                                                    adUnitId:@"test"
                                          delegateDispatcher:self.delegateDispatcher
                                      viewControllerProvider:^UIViewController *_Nonnull {
                                          return OCMClassMock([UIViewController class]);
                                          ;
                                      }];
    self.webviewId = @"webviewId";
    self.log = OCMPartialMock([[OGALog alloc] init]);
    self.oguryLog = OCMClassMock([OguryLog class]);
    OCMStub(self.log.oguryLog).andReturn(self.oguryLog);
}

- (void)testInit {
    XCTAssertNotNil(self.log);
}

- (void)testShared {
    XCTAssertNotNil([OGALog shared]);
    XCTAssertNotNil([OGALog shared].oguryLog);
}

- (void)testSetLogLevel {
    [self.log setLogLevel:OguryLogLevelAll];
    OCMVerify([self.log setLogLevel:OguryLogLevelAll]);
}

- (void)testLog {
    OGAAdLogMessage *message = [[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                                      adConfiguration:nil
                                                              logType:OguryLogTypeInternal
                                                              message:@"test"
                                                                 tags:nil];
    [self.log log:message];
    OCMVerify([self.oguryLog logMessage:message]);
}

@end

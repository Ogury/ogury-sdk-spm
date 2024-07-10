//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAMraidVerificationOperation.h"
#import "OCMock.h"

@interface OGAMraidVerificationOperation (Test)

@end

@interface OGAMraidVerificationOperationTests : XCTestCase

@property(nonatomic, strong) OGAMraidVerificationOperation *verificationOperation;
@property(nonatomic, strong) OGAMraidBaseView *baseView;
@property(nonatomic, strong) XCTestExpectation *expectation;

@end

@implementation OGAMraidVerificationOperationTests

- (void)setUp {
    self.baseView = OCMClassMock(OGAMraidBaseView.class);

    self.expectation = [self expectationWithDescription:@"wait to remove webview"];

    self.verificationOperation = OCMPartialMock([[OGAMraidVerificationOperation alloc] initWithBaseView:self.baseView
                                                                                      completionHandler:^(BOOL i) {
                                                                                          [self.expectation fulfill];
                                                                                      }]);
}

- (void)testMain {
    [self.verificationOperation main];

    [self waitForExpectations:@[ self.expectation ] timeout:1];
}

@end

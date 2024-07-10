//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "OGAInternetConnectionChecker.h"
#import "OGAReachability.h"

@interface OGAInternetConnectionChecker (Testing)

- (instancetype)initWithInternetReachability:(OGAReachability *)internetReachability;
- (void)updateReachabilityStatus;
@property(nonatomic, strong) OGAReachability *internetReachability;

@end

@interface OGAInternetConnectionCheckerTests : XCTestCase

@property(nonatomic, strong) OGAReachability *internetReachability;

@property(nonatomic, strong) OGAInternetConnectionChecker *checker;

@end

@implementation OGAInternetConnectionCheckerTests

- (void)setUp {
    self.internetReachability = OCMClassMock([OGAReachability class]);
    self.checker = [[OGAInternetConnectionChecker alloc] initWithInternetReachability:self.internetReachability];
}

#pragma mark - Methods

- (void)testCheckForSequence_withInternetConnection {
    OCMStub(self.internetReachability.currentReachabilityStatus).andReturn(ReachableViaWiFi);

    OguryError *error;
    XCTAssertTrue([self.checker checkForSequence:OCMClassMock([OGAAdSequence class]) error:&error]);

    XCTAssertNil(error);
}

- (void)testCheckForSequence_noInternetConnection {
    OGAInternetConnectionChecker *check = OCMPartialMock([[OGAInternetConnectionChecker alloc] initWithInternetReachability:self.internetReachability]);
    OCMStub([check updateReachabilityStatus]).andDo(^(NSInvocation *invocation) {
        check.internetReachability = self.internetReachability;
    });
    OguryError *error;
    XCTAssertFalse([check checkForSequence:OCMClassMock([OGAAdSequence class]) error:&error]);

    XCTAssertEqual(error.code, OguryCoreErrorTypeNoInternetConnection);
}

@end

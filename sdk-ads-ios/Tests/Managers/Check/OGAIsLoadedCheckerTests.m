//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "OGAAdManager.h"
#import "OGAIsLoadedChecker.h"

@interface OGAIsLoadedCheckerTests : XCTestCase

@property(nonatomic, strong) OGAAdManager *adManager;

@property(nonatomic, strong) OGAIsLoadedChecker *checker;

@end

@implementation OGAIsLoadedCheckerTests

- (void)setUp {
    self.adManager = OCMClassMock([OGAAdManager class]);
    self.checker = [[OGAIsLoadedChecker alloc] init];
    self.checker.adManager = self.adManager;
}

#pragma mark - Methods

- (void)testCheckForSequence_sequenceIsLoaded {
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    OCMStub([self.adManager isLoaded:sequence]).andReturn(YES);

    OguryError *error;
    XCTAssertTrue([self.checker checkForSequence:sequence error:&error]);

    XCTAssertNil(error);
}

- (void)testCheckForSequence_sequenceIsNotLoaded {
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    OCMStub([self.adManager isLoaded:sequence]).andReturn(NO);

    OguryError *error;
    XCTAssertFalse([self.checker checkForSequence:sequence error:&error]);

    XCTAssertEqual(error.code, OguryAdErrorCodeNoAdLoaded);
}

@end

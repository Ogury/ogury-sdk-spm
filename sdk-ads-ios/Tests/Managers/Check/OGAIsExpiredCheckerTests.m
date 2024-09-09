//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGAIsExpiredChecker.h"
#import "OGAAdManager.h"
#import "OGAAdSequence.h"

@interface OGAIsExpiredCheckerTests : XCTestCase

@property(nonatomic, strong) OGAAdManager *adManager;

@end

@implementation OGAIsExpiredCheckerTests

#pragma mark - Methods

- (void)setUp {
    self.adManager = OCMClassMock(OGAAdManager.self);
}

- (void)testShouldReturnFalseIfSequenceIsNotExpired {
    OGAAdSequence *sequence = OCMClassMock(OGAAdSequence.self);

    OCMStub([self.adManager isLoaded:sequence]).andReturn(YES);
    OCMStub([self.adManager isExpired:sequence]).andReturn(NO);

    OGAIsExpiredChecker *checker = OCMPartialMock([[OGAIsExpiredChecker alloc] initWithAdManager:self.adManager]);

    OguryError *error;

    XCTAssertTrue([checker checkForSequence:sequence error:&error]);
    XCTAssertNil(error);
}

- (void)testShouldReturnTrueIfSequenceIsExpired {
    OGAAdSequence *sequence = OCMClassMock(OGAAdSequence.self);

    OCMStub([self.adManager isLoaded:sequence]).andReturn(YES);
    OCMStub([self.adManager isExpired:sequence]).andReturn(YES);

    OGAIsExpiredChecker *checker = OCMPartialMock([[OGAIsExpiredChecker alloc] initWithAdManager:self.adManager]);

    OguryError *error;

    XCTAssertFalse([checker checkForSequence:sequence error:&error]);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, OguryAdsErrorTypeAdExpired);
}

@end

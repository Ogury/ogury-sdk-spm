//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "OGAAd+ImpressionSource.h"

@interface OGAAd_ImpressionSourceTests : XCTestCase

@property(nonatomic, strong) OGAAd *ad;

@end

@implementation OGAAd_ImpressionSourceTests

- (void)setUp {
    self.ad = OCMPartialMock([[OGAAd alloc] init]);
}

- (void)testIsImpressionSourceFormat {
    OCMStub([self.ad impressionSource]).andReturn(@"format");
    XCTAssertTrue([self.ad isImpressionSourceFormat]);
}

- (void)testIsImpressionSourceSDK {
    OCMStub([self.ad impressionSource]).andReturn(@"sdk");
    XCTAssertTrue([self.ad isImpressionSourceSDK]);
}

- (void)testIsImpressionSourceDefault {
    OCMStub([self.ad impressionSource]).andReturn(@"Casablanca");
    XCTAssertTrue([self.ad isImpressionSourceFormat]);
}

- (void)testIsImpressionSourceNil {
    OCMStub([self.ad impressionSource]).andReturn(nil);
    XCTAssertTrue([self.ad isImpressionSourceFormat]);
}

@end

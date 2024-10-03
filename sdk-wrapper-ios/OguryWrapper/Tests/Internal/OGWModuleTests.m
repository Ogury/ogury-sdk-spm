//
//  Copyright © 2022-present Ogury. All rights reserved.
//

#import <OguryCore/OGCInternal.h>
#import <XCTest/XCTest.h>
#import "OGWModule.h"
#import "OGWModuleClassMock.h"
#import "OguryCore/OguryCore.h"
#import <OCMock/OCMock.h>


@interface OGWModuleTests : XCTestCase

@end

@interface OGWModule ()

@property(nonatomic, retain, nullable) id module;

@end

@implementation OGWModuleTests

- (void)testLog {
   OGWModule *module = [[OGWModule alloc] initWithClassName:@"OGWModuleClassMock"];
   XCTAssertEqual(OGWModuleClassMock.shared.storedLogLevel, OguryLogLevelError);  // default
   [module setLogLevel:OguryLogLevelDebug];
   XCTAssertEqual(OGWModuleClassMock.shared.storedLogLevel, OguryLogLevelDebug);  // expected
}

- (void)testStartWithAndCompletionHandler {
    OGWModule *module = OCMPartialMock([[OGWModule alloc] initWithClassName:@"OGWModuleClassMock"]);
    NSString *assetKey = @"test";
    XCTAssertNil(OGWModuleClassMock.shared.storedAssetKey);
    XCTestExpectation *expectation = [self expectationWithDescription:@"Completion handler called"];
    [module startWith:assetKey completionHandler:^(BOOL success, OguryError * _Nullable error) {
        XCTAssertTrue(success);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    XCTAssertEqual(OGWModuleClassMock.shared.storedAssetKey, assetKey);
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

@end

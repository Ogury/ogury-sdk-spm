//
//  Copyright © 2022-present Ogury. All rights reserved.
//

#import <OguryCore/OGCInternal.h>
#import <XCTest/XCTest.h>
#import "OGWModule.h"
#import "OGWModuleClassMock.h"
#import "OguryCore/OguryCore.h"

@interface OGWModuleTests : XCTestCase

@end

@implementation OGWModuleTests

- (void)testLog {
   OGWModule *module = [[OGWModule alloc] initWithClassName:@"OGWModuleClassMock"];
   XCTAssertEqual(OGWModuleClassMock.shared.storedLogLevel, OguryLogLevelError);  // default

   [module setLogLevel:OguryLogLevelDebug];

   XCTAssertEqual(OGWModuleClassMock.shared.storedLogLevel, OguryLogLevelDebug);  // expected
}

- (void)testStartWithAssetKey {
   OGWModule *module = [[OGWModule alloc] initWithClassName:@"OGWModuleClassMock"];
   NSString *assetKey = @"test";
   XCTAssertNil(OGWModuleClassMock.shared.storedAssetKey);
   [module startWithAssetKey:assetKey];
   XCTAssertEqual(OGWModuleClassMock.shared.storedAssetKey, assetKey);
}

@end

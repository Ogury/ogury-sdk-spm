//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAAdExposure.h"

@interface OGAAdExposureTests : XCTestCase

@end

@implementation OGAAdExposureTests

#pragma mark - Methods

- (void)testShouldInstantiate {
    OGAAdExposure *element = [[OGAAdExposure alloc] init];

    XCTAssertEqual(element.visibleRectangle.origin.x, 0);
    XCTAssertEqual(element.visibleRectangle.origin.y, 0);
    XCTAssertEqual(element.visibleRectangle.size.width, 0);
    XCTAssertEqual(element.visibleRectangle.size.height, 0);
    XCTAssertNil(element.occlusionRectangles);
    XCTAssertEqual(element.exposurePercentage, 0);
}

- (void)testShouldInstantiateFullExposure {
    OGAAdExposure *element = [OGAAdExposure fullExposure];

    XCTAssertEqual(element.visibleRectangle.origin.x, 0);
    XCTAssertEqual(element.visibleRectangle.origin.y, 0);
    XCTAssertEqual(element.visibleRectangle.size.width, 0);
    XCTAssertEqual(element.visibleRectangle.size.height, 0);
    XCTAssertNil(element.occlusionRectangles);
    XCTAssertEqual(element.exposurePercentage, 100);
}

- (void)testShouldInstantiateZeroExposure {
    OGAAdExposure *element = [OGAAdExposure zeroExposure];

    XCTAssertEqual(element.visibleRectangle.origin.x, 0);
    XCTAssertEqual(element.visibleRectangle.origin.y, 0);
    XCTAssertEqual(element.visibleRectangle.size.width, 0);
    XCTAssertEqual(element.visibleRectangle.size.height, 0);
    XCTAssertNil(element.occlusionRectangles);
    XCTAssertEqual(element.exposurePercentage, 0);
}

@end

//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAThumbnailAdCachedPositionObject.h"

@interface OGAThumbnailAdCachedPositionObjectTests : XCTestCase

@property(strong, nonatomic) OGAThumbnailAdCachedPositionObject *thumbnailAdCachedPositionObject;

@end

@implementation OGAThumbnailAdCachedPositionObjectTests

- (void)testInitWithOguryOffsetRatio {
    OGAThumbnailAdCachedPositionObject *thumbnailAdCachedPositionObject = [[OGAThumbnailAdCachedPositionObject alloc] initWithOguryOffsetRatio:OguryOffsetMake(10, 11) rectCorner:OguryRectCornerTopLeft];
    XCTAssertEqual(thumbnailAdCachedPositionObject.offsetRatio.x, 10);
    XCTAssertEqual(thumbnailAdCachedPositionObject.offsetRatio.y, 11);
    XCTAssertEqual(thumbnailAdCachedPositionObject.rectCorner, OguryRectCornerTopLeft);
}

- (void)testSupportsSecureCoding {
    XCTAssertTrue([OGAThumbnailAdCachedPositionObject supportsSecureCoding]);
}

@end

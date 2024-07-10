//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OgurySdk/OguryConfigurationBuilder.h>

@interface OguryConfigurationBuilderTests : XCTestCase

@end

@implementation OguryConfigurationBuilderTests

- (void)testBuild {
    OguryConfigurationBuilder *builder = [[OguryConfigurationBuilder alloc] initWithAssetKey:@"OGY-XXXXXXXX"];
    
    OguryConfiguration *config = [builder build];
    
    XCTAssertEqualObjects(config.assetKey, @"OGY-XXXXXXXX");
}

@end

//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "OGAPreCacheEvent.h"
#import <OCMock/OCMock.h>
#import "OGAAd.h"

@interface OGAPreCacheEventTests : XCTestCase

@property(nonatomic, copy) NSString *adUnit;
@property(nonatomic, strong) OGAAdPrivacyConfiguration *privacyConfiguration;

@end

@implementation OGAPreCacheEventTests

- (void)setUp {
    self.adUnit = @"adUnit_id";
    self.privacyConfiguration = OCMClassMock([OGAAdPrivacyConfiguration class]);
}

- (void)testInitWithAdUnitId {
    OGAPreCacheEvent *preCacheEvent = [[OGAPreCacheEvent alloc] initWithAdvertId:nil
                                                                        adUnitId:self.adUnit
                                                            privacyConfiguration:self.privacyConfiguration
                                                                       eventType:OGAMetricsEventLoad];
    preCacheEvent.trackURL = [NSURL URLWithString:@"www.ogury.co"];
    XCTAssertNotNil(preCacheEvent);
    XCTAssertTrue([preCacheEvent.timestampDiff isEqualToString:@"0"]);
    XCTAssertEqualObjects(preCacheEvent.trackURL.absoluteString, @"www.ogury.co");
}

- (void)testToDictionary {
    OGAPreCacheEvent *preCacheEvent = [[OGAPreCacheEvent alloc] initWithAdvertId:nil
                                                                        adUnitId:self.adUnit
                                                            privacyConfiguration:self.privacyConfiguration
                                                                       eventType:OGAMetricsEventLoad];
    NSDictionary *dict = [preCacheEvent toDictionary];
    XCTAssertEqualObjects(dict[@"type"], @"LOAD");
    XCTAssertEqualObjects(dict[@"timestamp_diff"], @"0");
}

@end

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGAScreen.h"

@interface OGAScreen ()

@end

@interface OGAScreenTests : XCTestCase

@property(nonatomic, strong) OGAScreen *screen;

@end

@implementation OGAScreenTests

- (void)setUp {
    [super setUp];
    self.screen = [[OGAScreen alloc] init];
}

- (void)testInit {
    XCTAssertNotNil(self.screen.height);
    XCTAssertNotNil(self.screen.width);
    XCTAssertNotNil(self.screen.density);
}

- (void)testMapped {
    NSDictionary *mapped = [self.screen mapped];
    XCTAssertEqualObjects(mapped[@"density"], self.screen.density);
    XCTAssertEqualObjects(mapped[@"height"], self.screen.height);
    XCTAssertEqualObjects(mapped[@"width"], self.screen.width);
}

@end

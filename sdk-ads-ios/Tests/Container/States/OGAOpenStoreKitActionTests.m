//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAOpenStoreKitAction.h"
#import <OCMock/OCMock.h>
#import "OGAAdContainer.h"

@interface OGAOpenStoreKitActionTests : XCTestCase

@end

@implementation OGAOpenStoreKitActionTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testShouldInstantiate {
    OGAOpenStoreKitAction *action = [[OGAOpenStoreKitAction alloc] init];

    XCTAssertNotNil(action);
}

- (void)testShouldPerformActionOnDisplayerClose {
    OGAOpenStoreKitAction *action = [[OGAOpenStoreKitAction alloc] init];

    OGAAdContainer *mockContainer = OCMClassMock(OGAAdContainer.self);

    [action performAction:mockContainer error:nil];

    OCMVerify([mockContainer performAction:action.name error:nil]);
}

@end

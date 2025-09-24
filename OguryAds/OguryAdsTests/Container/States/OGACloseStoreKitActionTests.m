//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGACloseSKAction.h"
#import <OCMock/OCMock.h>
#import "OGAAdContainer.h"

@interface OGACloseStoreKitActionTests : XCTestCase

@end

@implementation OGACloseStoreKitActionTests

- (void)testShouldInstantiate {
    OGACloseSKAction *action = [[OGACloseSKAction alloc] init];
    XCTAssertNotNil(action);
}

- (void)testShouldPerformActionOnDisplayerCloseFullscreen {
    OGACloseSKAction *action = [[OGACloseSKAction alloc] init];
    OGAAdContainer *mockContainer = OCMClassMock(OGAAdContainer.self);
    OCMStub(mockContainer.previousStateType).andReturn(OGAAdContainerStateTypeFullScreenOverlay);
    [action performAction:mockContainer error:nil];
    OCMVerify([mockContainer performAction:@"closeStoreKitToFullscreen" error:nil]);
}

- (void)testShouldPerformActionOnDisplayer {
    OGACloseSKAction *action = [[OGACloseSKAction alloc] init];
    OGAAdContainer *mockContainer = OCMClassMock(OGAAdContainer.self);
    [action performAction:mockContainer error:nil];
    OCMVerify([mockContainer performAction:action.name error:nil]);
}

@end

//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGACloseAdAction.h"
#import <OCMock/OCMock.h>
#import "OGAAdContainer.h"
#import "OGANextAd.h"

@interface OGACloseAdActionTests : XCTestCase

@end

@implementation OGACloseAdActionTests

#pragma mark - Methods

- (void)testShouldInstantiate {
    OGANextAd *nextAd = [[OGANextAd alloc] init];
    nextAd.showNextAd = @(YES);

    OGACloseAdAction *action = [[OGACloseAdAction alloc] initWithNextAd:nextAd];

    XCTAssertNotNil(action);
    XCTAssertTrue(action.nextAd.showNextAd);
}

- (void)testShouldPerformActionOnDisplayer {
    OGACloseAdAction *action = [[OGACloseAdAction alloc] init];

    OGAAdContainer *mockContainer = OCMClassMock(OGAAdContainer.self);

    [action performAction:mockContainer error:nil];

    OCMVerify([mockContainer performAction:action.name error:nil]);
}

@end

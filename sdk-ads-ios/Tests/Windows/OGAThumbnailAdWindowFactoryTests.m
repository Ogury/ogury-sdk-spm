//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAThumbnailAdWindowFactory.h"
#import "OGAMRAIDAdDisplayer.h"
#import "OGAThumbnailAdViewController.h"
#import <OCMock/OCMock.h>

@interface OGAThumbnailAdWindowFactory (Test)

@property(strong, nonatomic, nullable) OGAThumbnailAdWindow *thumbnailAdWindow;

@end

@interface OGAThumbnailAdWindowFactoryTests : XCTestCase

@property(nonatomic, strong, nullable) id<OGAAdDisplayer> displayer;
@property(nonatomic, strong) OGAThumbnailAdWindowFactory *thumbnailWindowFactory;

@end

@implementation OGAThumbnailAdWindowFactoryTests

- (void)setUp {
    self.displayer = OCMClassMock([OGAMRAIDAdDisplayer class]);
    self.thumbnailWindowFactory = [[OGAThumbnailAdWindowFactory alloc] init];
}

- (void)testInitAndRetrieve {
    OGAThumbnailAdWindow *window1 = [self.thumbnailWindowFactory createThumbnailAdWindowWithDisplayer:self.displayer];
    OGAThumbnailAdWindow *window2 = [self.thumbnailWindowFactory createThumbnailAdWindowWithDisplayer:self.displayer];

    XCTAssertEqual(window1, window2);
    XCTAssertNotNil(window1);
}

- (void)testCreateThumbnailWindowWithDisplayer {
    OGAThumbnailAdWindow *thumbnailWindow = [self.thumbnailWindowFactory createThumbnailAdWindowWithDisplayer:self.displayer];
    XCTAssertNotNil(thumbnailWindow);
}

- (void)testInitAndGetWindow {
    OGAThumbnailAdWindow *window1 = [self.thumbnailWindowFactory createThumbnailAdWindowWithDisplayer:self.displayer];
    OGAThumbnailAdWindow *window2 = [self.thumbnailWindowFactory getThumbnailAdWindowIfExist];

    XCTAssertEqual(window1, window2);
    XCTAssertNotNil(window2);
}

@end

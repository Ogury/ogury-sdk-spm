//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "OGAAdSequenceRetainController.h"

@interface OGAAdSequenceRetainController (Testing)

@property(nonatomic, strong) NSMapTable<OGAAdSequence *, NSHashTable *> *controllersRetainingSequenceMap;

@end

@interface OGAAdSequenceRetainControllerTests : XCTestCase

@property(nonatomic, retain) OGAAdSequenceRetainController *sequenceRetainController;

@end

@implementation OGAAdSequenceRetainControllerTests

- (void)setUp {
    self.sequenceRetainController = [[OGAAdSequenceRetainController alloc] init];
}

- (void)testShared {
    XCTAssertNotNil([OGAAdSequenceRetainController shared]);
}

- (void)testRetainSequenceFromController {
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    OGAAdController *controller = OCMClassMock([OGAAdController class]);

    [self.sequenceRetainController retainSequence:sequence fromController:controller];

    NSEnumerator *it = [self.sequenceRetainController.controllersRetainingSequenceMap objectForKey:sequence].objectEnumerator;
    XCTAssertNotNil(it);
    XCTAssertEqual(it.nextObject, controller);
    XCTAssertNil(it.nextObject);
}

- (void)testRetainSequenceFromController_deduplicateRetainCalls {
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    OGAAdController *controller = OCMClassMock([OGAAdController class]);

    [self.sequenceRetainController retainSequence:sequence fromController:controller];
    [self.sequenceRetainController retainSequence:sequence fromController:controller];

    NSEnumerator *it = [self.sequenceRetainController.controllersRetainingSequenceMap objectForKey:sequence].objectEnumerator;
    XCTAssertNotNil(it);
    XCTAssertEqual(it.nextObject, controller);
    XCTAssertNil(it.nextObject);
}

- (void)testReleaseSequenceFromController_releaseOnceControllerListIsEmpty {
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    OGAAdController *controller = OCMClassMock([OGAAdController class]);
    [self.sequenceRetainController retainSequence:sequence fromController:controller];

    [self.sequenceRetainController releaseSequence:sequence fromController:controller];

    XCTAssertNil([self.sequenceRetainController.controllersRetainingSequenceMap objectForKey:sequence]);
}

- (void)testReleaseSequenceFromController_doNotReleaseIfAtLeastOneControllerInTheList {
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    OGAAdController *controllerOne = OCMClassMock([OGAAdController class]);
    OGAAdController *controllerTwo = OCMClassMock([OGAAdController class]);
    [self.sequenceRetainController retainSequence:sequence fromController:controllerOne];
    [self.sequenceRetainController retainSequence:sequence fromController:controllerTwo];

    [self.sequenceRetainController releaseSequence:sequence fromController:controllerTwo];

    NSEnumerator *it = [self.sequenceRetainController.controllersRetainingSequenceMap objectForKey:sequence].objectEnumerator;
    XCTAssertNotNil(it);
    XCTAssertEqual(it.nextObject, controllerOne);
    XCTAssertNil(it.nextObject);
}

- (void)testReleaseSequenceFromController_doNotReleaseIfProvidedControllerNotInTheList {
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    OGAAdController *controllerOne = OCMClassMock([OGAAdController class]);
    [self.sequenceRetainController retainSequence:sequence fromController:controllerOne];

    [self.sequenceRetainController releaseSequence:sequence fromController:OCMClassMock([OGAAdController class])];

    NSEnumerator *it = [self.sequenceRetainController.controllersRetainingSequenceMap objectForKey:sequence].objectEnumerator;
    XCTAssertNotNil(it);
    XCTAssertEqual(it.nextObject, controllerOne);
    XCTAssertNil(it.nextObject);
}

@end

//
// Copyright (c) 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "OguryAdError.h"
#import "OGAAssetKeyManager.h"
#import "OguryAdError+Internal.h"

@interface OGAAssetKeyManagerTests : XCTestCase
@property OGAAssetKeyManager *assetKeyManager;
@end

@interface OGAAssetKeyManager ()
@property(nonatomic, assign) BOOL assetKeyHasBeenSet;
@property(nonatomic, copy, readwrite, nullable) NSString *assetKey;
@end

@interface OGAAssetKeyManager ()
- (BOOL)sdkIsReady;
@end

@implementation OGAAssetKeyManagerTests

NSString *const TestAssetKey = @"OGY-XXXXXXXX";
NSString *const AnotherTestAssetKey = @"OGY-XXXXXXXX2";

#pragma mark - Methods

- (void)setUp {
    self.assetKeyManager = [[OGAAssetKeyManager alloc] init];
}

- (void)testConfigureAssetKey {
    XCTAssertTrue([self.assetKeyManager configureAssetKey:TestAssetKey]);
    XCTAssertEqual(self.assetKeyManager.assetKey, TestAssetKey);
}

- (void)testConfigureAssetKey_cannotChangeAssetKeyOnceSet {
    XCTAssertTrue([self.assetKeyManager configureAssetKey:TestAssetKey]);
    XCTAssertFalse([self.assetKeyManager configureAssetKey:AnotherTestAssetKey]);
    XCTAssertEqual(self.assetKeyManager.assetKey, TestAssetKey);
}

- (void)testCheckAssetKey_errorIfInitNotCalled {
    OguryError *error = nil;
    XCTAssertFalse([self.assetKeyManager checkAssetKeyIsValid:&error type:OguryAdErrorTypeLoad]);
    XCTAssertEqualObjects(error, [OguryAdError sdkNotInitializedFrom:OguryAdErrorTypeLoad]);
}

- (void)testCheckAssetKey_errorIfInvalidAssetKey {
    [self.assetKeyManager configureAssetKey:@""];

    OguryError *error = nil;
    XCTAssertFalse([self.assetKeyManager checkAssetKeyIsValid:&error type:OguryAdErrorTypeLoad]);
    XCTAssertEqualObjects(error, [OguryAdError sdkNotProperlyInitializedFrom:OguryAdErrorTypeLoad]);
}

- (void)testCheckAssetKey {
    [self.assetKeyManager configureAssetKey:TestAssetKey];

    OguryError *error = nil;
    XCTAssertTrue([self.assetKeyManager checkAssetKeyIsValid:&error type:OguryAdErrorTypeLoad]);
    XCTAssertNil(error);
}

- (void)testWhenAssetKeyHasNotBeenSetThenResetshouldNotOccur {
    self.assetKeyManager.assetKeyHasBeenSet = NO;
    self.assetKeyManager.assetKey = @"ASSET_KEY";
    XCTAssertFalse([self.assetKeyManager shouldResetSDKFor:@"ASSET_KEY"]);
    XCTAssertFalse([self.assetKeyManager shouldResetSDKFor:@""]);
}

- (void)testWhenAssetKeyHasBeenSetResetWithSameAssetKeyShouldNotTriggerReset {
    self.assetKeyManager.assetKeyHasBeenSet = YES;
    self.assetKeyManager.assetKey = @"ASSET_KEY";
    XCTAssertFalse([self.assetKeyManager shouldResetSDKFor:@"ASSET_KEY"]);
}

- (void)testWhenAssetKeyHasBeenSetResetWithDifferentAssetKeyShouldTriggerReset {
    self.assetKeyManager.assetKeyHasBeenSet = YES;
    self.assetKeyManager.assetKey = @"ASSET_KEY";
    XCTAssertTrue([self.assetKeyManager shouldResetSDKFor:@"NEXT_ASSET_KEY"]);
}

- (void)testWhenInitializingSUTThenStateIsIdle {
    XCTAssertEqual(self.assetKeyManager.sdkState, OgurySDKStateIdle);
}

- (void)testWhenStartingSDKThenStateUpdatesToStarting {
    [self.assetKeyManager configureAssetKey:@""];
    XCTAssertEqual(self.assetKeyManager.sdkState, OgurySDKStateStarting);
}

- (void)testWhenCallingSDKStartedThenStateIsUpdatedOnlyWhenNeeded {
    [self.assetKeyManager sdkIsReady];
    XCTAssertNotEqual(self.assetKeyManager.sdkState, OgurySDKStateReady);
    [self.assetKeyManager configureAssetKey:@""];
    [self.assetKeyManager sdkIsReady];
    XCTAssertEqual(self.assetKeyManager.sdkState, OgurySDKStateReady);
}

@end

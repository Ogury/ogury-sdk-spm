//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAThumbnailAdViewController+CachedPosition.h"
#import "OGAThumbnailAdViewController+Testing.h"
#import "OGAThumbnailAdViewController+Position.h"
#import "OGAAdDisplayerUpdateExposureInformation.h"
#import "OGAMRAIDAdDisplayer.h"
#import <OCMock/OCMock.h>
#import "OGALog.h"
#import "OGAAdDisplayerUpdateScreenSizeInformation.h"
#import "OGAAdDisplayerUpdateCurrentAppOrientationInformation.h"
#import "OGAAdDisplayerUpdateCurrentPositionInformation.h"
#import "OGAAdConfiguration.h"
#import "OGAThumbnailAdCachedPositionObject.h"

@interface OGAThumbnailAdViewController_CachedPositionTests : XCTestCase

@property(strong, nonatomic) id<OGAAdDisplayer> displayer;
@property(strong, nonatomic) OGAAdExposureController *exposerController;
@property(strong, nonatomic) OGAThumbnailAdViewController *thumbnailController;
@property(strong, nonatomic) OGAThumbnailAdWindow *window;
@property(strong, nonatomic) OGAThumbnailAdRestrictionsManager *restrictionManager;
@property(strong, nonatomic) NSNotificationCenter *center;
@property(strong, nonatomic) OGAAd *ad;
@property(strong, nonatomic) OGAThumbnailAdResponse *thumbnailAdResponse;
@property(strong, nonatomic) OGAAdConfiguration *config;
@property(strong, nonatomic) OGASizeSafeAreaController *safeAreaController;
@property(strong, nonatomic) OGAAdImpressionManager *impressionManager;
@property(strong, nonatomic) NSUserDefaults *userDefaults;
@property(nonatomic, strong) OGAThumbnailAdCachedPositionObject *cachedThumbnailAdPosition;
@property(nonatomic, strong) OGADeviceService *deviceService;
@property(nonatomic, strong) OGALog *log;

@end

@interface OGAThumbnailAdViewController ()

@property(nonatomic) CGSize thumbnailSize;
@property(nonatomic) CGPoint thumbnailPosition;
@property(nonatomic) BOOL keyboardOnScreen;
@property(nonatomic) CGRect keyboardRect;
@property(nonatomic, assign) OguryOffset offsetRatio;
@property(nonatomic, assign) OguryRectCorner rectCorner;
@property(nonatomic, strong) NSUserDefaults *userDefaults;
@property(nonatomic, strong) NSString *customThumbnailCachedPositionKey;
@property(nonatomic, strong) OGAThumbnailAdCachedPositionObject *cachedThumbnailAdPosition;
@property(nonatomic, strong) OGADeviceService *deviceService;

- (void)cacheThumbnailAdPosition;

- (BOOL)updateToCachedThumbnailAdPositionWithAdUnitId:(NSString *)adUnitId;

- (void)applyCachedThumbnailAdPosition;

- (void)cacheThumbnailAdPositionWithOffsetRatio:(OguryOffset)offsetRatio rectCorner:(OguryRectCorner)rectCorner;

- (void)defineCustomThumbnailAdCachedPositionKeyWithAdUnitId:(NSString *)adUnitId;

- (void)fetchCachedThumbnailAdPosition;

- (OguryOffset)retrieveOffsetRatio;

- (OguryRectCorner)retrieveRectCorner;

- (BOOL)hasCachedPositionForThumbnailAdWithAdUnitId:(NSString *)adUnitId;

- (void)applyCachedThumbnailAdPositionToCurrentPosition;

@end

@implementation OGAThumbnailAdViewController_CachedPositionTests

- (void)setUp {
    self.displayer = OCMClassMock([OGAMRAIDAdDisplayer class]);
    self.exposerController = OCMClassMock([OGAAdExposureController class]);
    self.window = OCMClassMock([OGAThumbnailAdWindow class]);
    self.restrictionManager = OCMClassMock([OGAThumbnailAdRestrictionsManager class]);
    self.center = OCMClassMock([NSNotificationCenter class]);
    self.ad = OCMClassMock([OGAAd class]);
    self.thumbnailAdResponse = OCMClassMock([OGAThumbnailAdResponse class]);
    self.config = OCMClassMock([OGAAdConfiguration class]);
    self.safeAreaController = OCMClassMock([OGASizeSafeAreaController class]);
    self.impressionManager = OCMClassMock([OGAAdImpressionManager class]);
    self.userDefaults = OCMClassMock([NSUserDefaults class]);
    self.deviceService = OCMClassMock([OGADeviceService class]);
    self.log = OCMClassMock([OGALog class]);

    OCMStub([self.safeAreaController getUsableFullscreenFrameWithWindow:[OCMArg any]]).andReturn(CGRectMake(0, 0, 100, 100));
    OCMStub([self.config corner]).andReturn(OguryRectCornerTopLeft);
    OCMStub([self.config offset]).andReturn(OguryOffsetMake(10, 10));
    OCMStub([self.ad thumbnailAdResponse]).andReturn(self.thumbnailAdResponse);
    OCMStub([self.displayer ad]).andReturn(self.ad);
    OCMStub([self.ad adConfiguration]).andReturn(self.config);

    OGAThumbnailAdViewController *thumbnailController = [[OGAThumbnailAdViewController alloc] initWithWindow:self.window
                                                                                          restrictionManager:self.restrictionManager
                                                                                          notificationCenter:self.center
                                                                                          safeAreaController:self.safeAreaController
                                                                                           impressionManager:self.impressionManager
                                                                                               deviceService:self.deviceService
                                                                                                userDefaults:self.userDefaults
                                                                                                         log:self.log];
    self.thumbnailController = OCMPartialMock(thumbnailController);

    [self.thumbnailController setupExposureController:self.exposerController];
    self.thumbnailController.displayer = self.displayer;
    self.thumbnailController.thumbnailSize = CGSizeMake(24, 24);
    self.thumbnailController.offsetRatio = OguryOffsetMake(10, 10);
    self.thumbnailController.rectCorner = OguryRectCornerTopLeft;
    self.cachedThumbnailAdPosition = OCMClassMock([OGAThumbnailAdCachedPositionObject class]);
    OCMStub(self.cachedThumbnailAdPosition.offsetRatio).andReturn(OguryOffsetMake(50, 50));
    OCMStub(self.cachedThumbnailAdPosition.rectCorner).andReturn(OguryRectCornerTopLeft);
    self.thumbnailController.cachedThumbnailAdPosition = self.cachedThumbnailAdPosition;
}

- (void)testCacheThumbnailAdPosition {
    OCMStub(self.thumbnailController.offsetRatio).andReturn(OguryOffsetMake(50, 50));
    OCMStub(self.thumbnailController.rectCorner).andReturn(OguryRectCornerTopLeft);
    OCMStub([self.thumbnailController cacheThumbnailAdPositionWithOffsetRatio:OguryOffsetMake(50, 50) rectCorner:OguryRectCornerTopLeft]);
    [self.thumbnailController cacheThumbnailAdPosition];
    OCMVerify([self.thumbnailController cacheThumbnailAdPositionWithOffsetRatio:OguryOffsetMake(50, 50) rectCorner:OguryRectCornerTopLeft]);
}

- (void)testUpdateToCachedThumbnailAdPositionWithAdUnitIdFalse {
    OCMStub([self.thumbnailController hasCachedPositionForThumbnailAdWithAdUnitId:@"ad_unit"]).andReturn(NO);
    XCTAssertFalse([self.thumbnailController updateToCachedThumbnailAdPositionWithAdUnitId:@"ad_unit"]);
}

- (void)testApplyCachedThumbnailAdPosition {
    OCMStub([self.thumbnailController initThumbnailSize]);
    OCMStub([self.thumbnailController applyCachedThumbnailAdPositionToCurrentPosition]);
    OCMStub([self.thumbnailController applyOffsetToPosition]);
    OCMStub([self.thumbnailController checkThumbnailCorrectPosition]);
    OCMStub([self.thumbnailController updateOffsetRatio]);
    [self.thumbnailController applyCachedThumbnailAdPosition];
    OCMVerify([self.thumbnailController initThumbnailSize]);
    OCMVerify([self.thumbnailController applyCachedThumbnailAdPositionToCurrentPosition]);
    OCMVerify([self.thumbnailController applyOffsetToPosition]);
    OCMVerify([self.thumbnailController checkThumbnailCorrectPosition]);
    OCMVerify([self.thumbnailController updateOffsetRatio]);
}

- (void)testUpdateToCachedThumbnailAdPositionWithAdUnitIdTrue {
    OCMStub([self.thumbnailController hasCachedPositionForThumbnailAdWithAdUnitId:@"ad_unit"]).andReturn(YES);
    XCTAssertTrue([self.thumbnailController updateToCachedThumbnailAdPositionWithAdUnitId:@"ad_unit"]);
    OCMVerify([self.thumbnailController applyCachedThumbnailAdPosition]);
}

- (void)testHasCachedPositionForThumbnailAdWithAdUnitIdTrue {
    OCMStub([self.thumbnailController defineCustomThumbnailAdCachedPositionKeyWithAdUnitId:@"ad_unit"]);
    OCMStub([self.thumbnailController fetchCachedThumbnailAdPosition]);
    XCTAssertTrue([self.thumbnailController hasCachedPositionForThumbnailAdWithAdUnitId:@"ad_unit"]);
}

- (void)testHasCachedPositionForThumbnailAdWithAdUnitIdFalse {
    OCMStub([self.thumbnailController defineCustomThumbnailAdCachedPositionKeyWithAdUnitId:@"ad_unit"]);
    OCMStub([self.thumbnailController fetchCachedThumbnailAdPosition]);
    self.thumbnailController.cachedThumbnailAdPosition = nil;
    XCTAssertFalse([self.thumbnailController hasCachedPositionForThumbnailAdWithAdUnitId:@"ad_unit"]);
}

- (void)testApplyCachedThumbnailAdPositionToCurrentPositionOguryTopLeft {
    self.cachedThumbnailAdPosition = OCMClassMock([OGAThumbnailAdCachedPositionObject class]);
    OCMStub(self.cachedThumbnailAdPosition.offsetRatio).andReturn(OguryOffsetMake(50, 30));
    OCMStub(self.cachedThumbnailAdPosition.rectCorner).andReturn(OguryRectCornerTopLeft);
    self.thumbnailController.cachedThumbnailAdPosition = self.cachedThumbnailAdPosition;
    [self.thumbnailController applyCachedThumbnailAdPositionToCurrentPosition];
    OCMVerify([self.thumbnailController setRectCorner:OguryRectCornerTopLeft]);
    OCMVerify([self.thumbnailController setOffsetRatio:OguryOffsetMake(50, 30)]);
}

- (void)testApplyCachedThumbnailAdPositionToCurrentPositionOguryTopRight {
    self.cachedThumbnailAdPosition = OCMClassMock([OGAThumbnailAdCachedPositionObject class]);
    OCMStub(self.cachedThumbnailAdPosition.offsetRatio).andReturn(OguryOffsetMake(30, 50));
    OCMStub(self.cachedThumbnailAdPosition.rectCorner).andReturn(OguryRectCornerTopRight);
    self.thumbnailController.cachedThumbnailAdPosition = self.cachedThumbnailAdPosition;
    [self.thumbnailController applyCachedThumbnailAdPositionToCurrentPosition];
    OCMVerify([self.thumbnailController setRectCorner:OguryRectCornerTopRight]);
    OCMVerify([self.thumbnailController setOffsetRatio:OguryOffsetMake(30, 50)]);
}

- (void)testApplyCachedThumbnailAdPositionToCurrentPositionBottomRight {
    self.cachedThumbnailAdPosition = OCMClassMock([OGAThumbnailAdCachedPositionObject class]);
    OCMStub(self.cachedThumbnailAdPosition.offsetRatio).andReturn(OguryOffsetMake(130, 130));
    OCMStub(self.cachedThumbnailAdPosition.rectCorner).andReturn(OguryRectCornerBottomRight);
    self.thumbnailController.cachedThumbnailAdPosition = self.cachedThumbnailAdPosition;
    [self.thumbnailController applyCachedThumbnailAdPositionToCurrentPosition];
    OCMVerify([self.thumbnailController setRectCorner:OguryRectCornerBottomRight]);
    OCMVerify([self.thumbnailController setOffsetRatio:OguryOffsetMake(130, 130)]);
}

- (void)testApplyCachedThumbnailAdPositionToCurrentPositionBottomLeft {
    self.cachedThumbnailAdPosition = OCMClassMock([OGAThumbnailAdCachedPositionObject class]);
    OCMStub(self.cachedThumbnailAdPosition.offsetRatio).andReturn(OguryOffsetMake(70, 70));
    OCMStub(self.cachedThumbnailAdPosition.rectCorner).andReturn(OguryRectCornerBottomLeft);
    self.thumbnailController.cachedThumbnailAdPosition = self.cachedThumbnailAdPosition;
    [self.thumbnailController applyCachedThumbnailAdPositionToCurrentPosition];
    OCMVerify([self.thumbnailController setRectCorner:OguryRectCornerBottomLeft]);
    OCMVerify([self.thumbnailController setOffsetRatio:OguryOffsetMake(70, 70)]);
}

- (void)testCacheThumbnailAdPositionWithOffsetRatioOguryTopLeft {
    id classMock = OCMClassMock([NSKeyedArchiver class]);
    OCMStub(ClassMethod([classMock archivedDataWithRootObject:[OCMArg any]]));
    [self.thumbnailController cacheThumbnailAdPositionWithOffsetRatio:OguryOffsetMake(130, 50) rectCorner:OguryRectCornerTopLeft];
    XCTAssertNotNil(self.thumbnailController.cachedThumbnailAdPosition);
    XCTAssertEqual(self.thumbnailController.cachedThumbnailAdPosition.offsetRatio.x, 130);
    XCTAssertEqual(self.thumbnailController.cachedThumbnailAdPosition.offsetRatio.y, 50);
    XCTAssertEqual(self.thumbnailController.cachedThumbnailAdPosition.rectCorner, OguryRectCornerTopLeft);
}

- (void)testCacheThumbnailAdPositionWithOffsetRatioOguryTopRight {
    id classMock = OCMClassMock([NSKeyedArchiver class]);
    OCMStub(ClassMethod([classMock archivedDataWithRootObject:[OCMArg any]]));
    [self.thumbnailController cacheThumbnailAdPositionWithOffsetRatio:OguryOffsetMake(70, 40) rectCorner:OguryRectCornerTopRight];
    XCTAssertNotNil(self.thumbnailController.cachedThumbnailAdPosition);
    XCTAssertEqual(self.thumbnailController.cachedThumbnailAdPosition.offsetRatio.x, 70);
    XCTAssertEqual(self.thumbnailController.cachedThumbnailAdPosition.offsetRatio.y, 40);
    XCTAssertEqual(self.thumbnailController.cachedThumbnailAdPosition.rectCorner, OguryRectCornerTopRight);
}

- (void)testCacheThumbnailAdPositionWithOffsetRatioOguryBottomLeft {
    id classMock = OCMClassMock([NSKeyedArchiver class]);
    OCMStub(ClassMethod([classMock archivedDataWithRootObject:[OCMArg any]]));
    [self.thumbnailController cacheThumbnailAdPositionWithOffsetRatio:OguryOffsetMake(30, 60) rectCorner:OguryRectCornerBottomLeft];
    XCTAssertNotNil(self.thumbnailController.cachedThumbnailAdPosition);
    XCTAssertEqual(self.thumbnailController.cachedThumbnailAdPosition.offsetRatio.x, 30);
    XCTAssertEqual(self.thumbnailController.cachedThumbnailAdPosition.offsetRatio.y, 60);
    XCTAssertEqual(self.thumbnailController.cachedThumbnailAdPosition.rectCorner, OguryRectCornerBottomLeft);
}

- (void)testCacheThumbnailAdPositionWithOffsetRatioOguryBottomRight {
    id classMock = OCMClassMock([NSKeyedArchiver class]);
    OCMStub(ClassMethod([classMock archivedDataWithRootObject:[OCMArg any]]));
    [self.thumbnailController cacheThumbnailAdPositionWithOffsetRatio:OguryOffsetMake(20, 90) rectCorner:OguryRectCornerBottomRight];
    XCTAssertNotNil(self.thumbnailController.cachedThumbnailAdPosition);
    XCTAssertEqual(self.thumbnailController.cachedThumbnailAdPosition.offsetRatio.x, 20);
    XCTAssertEqual(self.thumbnailController.cachedThumbnailAdPosition.offsetRatio.y, 90);
    XCTAssertEqual(self.thumbnailController.cachedThumbnailAdPosition.rectCorner, OguryRectCornerBottomRight);
}

- (void)testDefineCustomThumbnailCachedPositionKeyWithAdUnitId {
    [self.thumbnailController defineCustomThumbnailAdCachedPositionKeyWithAdUnitId:@"ad_unit"];
    XCTAssertEqualObjects(self.thumbnailController.customThumbnailCachedPositionKey, @"OGAThumbnailCachedPositionKey_ad_unit");
}

- (void)testFetchCachedThumbnailAdPositionFromUserDefaults {
    [self.thumbnailController fetchCachedThumbnailAdPosition];
    OCMVerify([self.thumbnailController.userDefaults objectForKey:[OCMArg any]]);
}

- (void)testFetchCachedThumbnailAdPosition {
    id classMock = OCMClassMock([NSKeyedUnarchiver class]);
    OCMStub(ClassMethod([classMock unarchiveObjectWithData:[OCMArg any]]));
    OCMStub([self.userDefaults objectForKey:[OCMArg any]]).andReturn([@"testData" dataUsingEncoding:NSUTF8StringEncoding]);
    [self.thumbnailController fetchCachedThumbnailAdPosition];
    OCMVerify(ClassMethod([classMock unarchiveObjectWithData:[OCMArg any]]));
}

@end

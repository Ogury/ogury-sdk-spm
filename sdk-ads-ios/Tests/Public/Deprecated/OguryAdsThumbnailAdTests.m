//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OguryAds/OguryAdsThumbnailAd.h>

#import <OCMock/OCMock.h>
#import "OGAThumbnailAdInternalAPI.h"
#import "OguryAdsThumbnailAdDelegateDispatcher.h"
#import "OGAThumbnailAdConstants.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

NSString *const OguryAdsThumbnailAdTestsAdUnitId = @"AD-UNIT-ID";
OguryRectCorner const OguryAdsThumbnailAdTestsRectCorner = OguryBottomLeft;
CGFloat const OguryAdsThumbnailAdTestsOffsetX = 50;
CGFloat const OguryAdsThumbnailAdTestsOffsetY = 100;

@interface OguryAdsThumbnailAd (Testing)

- (instancetype)initWithAdUnitID:(NSString *_Nullable)adUnitID internalAPI:(OGAThumbnailAdInternalAPI *)internalAPI delegateDispatcher:(OguryAdsThumbnailAdDelegateDispatcher *)delegateDispatcher;

- (void)loadWithCampaignId:(NSString *)campaignId thumbnailSize:(CGSize)thumbnailSize;

@end

@interface OguryAdsThumbnailAdTests : XCTestCase

@property(nonatomic, strong) OguryAdsThumbnailAdDelegateDispatcher *delegateDispatcher;
@property(nonatomic, strong) OGAThumbnailAdInternalAPI *internalAPI;
@property(nonatomic, strong) OguryAdsThumbnailAd *thumbnailAd;

@end

@implementation OguryAdsThumbnailAdTests

- (void)setUp {
    self.internalAPI = OCMClassMock([OGAThumbnailAdInternalAPI class]);
    self.delegateDispatcher = OCMClassMock([OguryAdsThumbnailAdDelegateDispatcher class]);

    OguryAdsThumbnailAd *thumbnailAd = [[OguryAdsThumbnailAd alloc] initWithAdUnitID:OguryAdsThumbnailAdTestsAdUnitId
                                                                         internalAPI:self.internalAPI
                                                                  delegateDispatcher:self.delegateDispatcher];
    self.thumbnailAd = OCMPartialMock(thumbnailAd);
}

- (void)testLoad_withThumbnailSize {
    CGSize thumbnailSize = CGSizeMake(180, 180);

    [self.thumbnailAd load:thumbnailSize];

    OCMVerify([self.thumbnailAd loadWithCampaignId:nil thumbnailSize:thumbnailSize]);
}

- (void)testLoad {
    [self.thumbnailAd load];

    OCMVerify([self.thumbnailAd loadWithCampaignId:nil thumbnailSize:CGSizeMake(OGAThumbnailDefaultWidth, OGAThumbnailDefaultHeight)]);
}

- (void)testShowWithOguryRectCornerMargin {
    OguryOffset margin = OguryOffsetMake(OguryAdsThumbnailAdTestsOffsetX, OguryAdsThumbnailAdTestsOffsetY);

    [self.thumbnailAd showWithOguryRectCorner:OguryAdsThumbnailAdTestsRectCorner margin:margin];

    OCMVerify([self.internalAPI showWithOguryRectCorner:OguryAdsThumbnailAdTestsRectCorner margin:margin]);
}

- (void)testShow_withPosition {
    CGPoint position = CGPointMake(OguryAdsThumbnailAdTestsOffsetX, OguryAdsThumbnailAdTestsOffsetY);

    [self.thumbnailAd show:position];

    OCMVerify([self.thumbnailAd showWithOguryRectCorner:OguryTopLeft margin:OguryOffsetMake(OguryAdsThumbnailAdTestsOffsetX, OguryAdsThumbnailAdTestsOffsetY)]);
}

- (void)testShow {
    [self.thumbnailAd show];

    OCMVerify([self.thumbnailAd showWithOguryRectCorner:OguryBottomRight margin:OguryOffsetMake(OGAThumbnailDefaultXOffset, OGAThumbnailDefaultYOffset)]);
}

- (void)testShowInSceneWithOguryRectCornerMargin API_AVAILABLE(ios(13.0)) {
    UIWindowScene *windowScene = OCMClassMock([UIWindowScene class]);
    OguryOffset margin = OguryOffsetMake(OguryAdsThumbnailAdTestsOffsetX, OguryAdsThumbnailAdTestsOffsetY);

    [self.thumbnailAd showInScene:windowScene withOguryRectCorner:OguryAdsThumbnailAdTestsRectCorner margin:margin];

    OCMVerify([self.internalAPI showInScene:windowScene withOguryRectCorner:OguryAdsThumbnailAdTestsRectCorner margin:margin]);
}

- (void)testShowInSceneAtPosition:(CGPoint)position API_AVAILABLE(ios(13.0)) {
    UIWindowScene *windowScene = OCMClassMock([UIWindowScene class]);
    CGPoint margin = CGPointMake(OguryAdsThumbnailAdTestsOffsetX, OguryAdsThumbnailAdTestsOffsetY);

    [self.thumbnailAd showInScene:windowScene atPosition:margin];

    OCMVerify([self.thumbnailAd showInScene:windowScene withOguryRectCorner:OguryTopLeft margin:OguryOffsetMake(OGAThumbnailDefaultXOffset, OGAThumbnailDefaultYOffset)]);
}

- (void)testShowInScene:(UIWindowScene *)scene API_AVAILABLE(ios(13.0)) {
    UIWindowScene *windowScene = OCMClassMock([UIWindowScene class]);

    [self.thumbnailAd showInScene:windowScene];

    OCMVerify([self.thumbnailAd showInScene:windowScene withOguryRectCorner:OguryBottomRight margin:OguryOffsetMake(OGAThumbnailDefaultXOffset, OGAThumbnailDefaultYOffset)]);
}

- (void)testSetBlacklistViewControllers {
    NSArray<NSString *> *viewControllers = OCMClassMock([NSArray class]);

    [self.thumbnailAd setBlacklistViewControllers:viewControllers];

    [self.internalAPI setBlacklistViewControllers:viewControllers];
}

- (void)testSetWhitelistBundleIdentifiers {
    NSArray<NSString *> *bundleIdentifiers = OCMClassMock([NSArray class]);

    [self.thumbnailAd setWhitelistBundleIdentifiers:bundleIdentifiers];

    [self.internalAPI setWhitelistBundleIdentifiers:bundleIdentifiers];
}

@end

#pragma clang diagnostic pop

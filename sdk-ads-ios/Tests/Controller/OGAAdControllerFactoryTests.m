//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "OGAAdControllerFactory.h"
#import "OGAAdControllerFactory+Testing.h"
#import "OGAAdController.h"
#import "OGAAdConfiguration.h"
#import "OGAAdSequence.h"
#import "OGAAdSequenceCoordinator.h"
#import "OGAAdContainerBuilder+Testing.h"
#import "OGAExpirationContext.h"

@interface OGAAdControllerFactoryTests : XCTestCase

@property(nonatomic, strong) OGAAdControllerFactory *factory;

@end

@implementation OGAAdControllerFactoryTests

#pragma mark - Constants

static NSString *const defaultCampaignId = @"";
static NSString *const defaultAdUnitId = @"";
static NSString *const defaultUserId = @"";

#pragma mark - Methods

- (void)setUp {
    self.factory = OCMPartialMock([[OGAAdControllerFactory alloc] init]);
}

- (void)testShouldCreateControllersForSequence {
    OGAAdConfiguration *configuration = OCMPartialMock([[OGAAdConfiguration alloc] init]);
    OCMStub([configuration webviewLoadTimeout]).andReturn(@3);

    OGAAdSequence *sequence = [[OGAAdSequence alloc] initWithAdConfiguration:configuration];

    NSArray<OGAAd *> *ads = @[
        OCMClassMock([OGAAd class]),
        OCMClassMock([OGAAd class]),
        OCMClassMock([OGAAd class]),
    ];

    [self.factory createControllersForSequence:sequence ads:ads configuration:configuration];

    XCTAssertEqual(sequence.coordinator.adControllers.count, 3);
}

- (void)testShouldCreateControllerForAd {
    OGAAd *ad = [[OGAAd alloc] init];

    OGAAdSequence *sequence = OCMClassMock(OGAAdSequence.self);

    OGAAdConfiguration *configuration = OCMPartialMock([[OGAAdConfiguration alloc] init]);
    OCMStub([configuration webviewLoadTimeout]).andReturn(@3);

    OGAAdController *controller = [self.factory createControllerForAd:ad sequence:sequence configuration:configuration];

    XCTAssertNotNil(controller);
}

- (void)testAddTransitionsForAd_interstitialAd {
    OGAAd *ad = [[OGAAd alloc] init];
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OGAAdContainerBuilder *builder = OCMClassMock([OGAAdContainerBuilder class]);
    OCMStub(configuration.adType).andReturn(OguryAdsTypeInterstitial);

    [self.factory addTransitionsForAd:ad configuration:configuration builder:builder];

    OCMVerify([self.factory addTransitionsForFullscreenAd:ad configuration:configuration builder:builder]);
}

- (void)testAddTransitionsForAd_RewardedAd {
    OGAAd *ad = [[OGAAd alloc] init];
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OGAAdContainerBuilder *builder = OCMClassMock([OGAAdContainerBuilder class]);
    OCMStub(configuration.adType).andReturn(OguryAdsTypeOptinVideo);

    [self.factory addTransitionsForAd:ad configuration:configuration builder:builder];

    OCMVerify([self.factory addTransitionsForFullscreenAd:ad configuration:configuration builder:builder]);
}

- (void)testAddTransitionsForAd_bannerAd {
    OGAAd *ad = [[OGAAd alloc] init];
    ad.bannerAdResponse = [[OGABannerAdResponse alloc] init];
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OGAAdContainerBuilder *builder = OCMClassMock([OGAAdContainerBuilder class]);
    OCMStub(configuration.adType).andReturn(OguryAdsTypeBanner);

    [self.factory addTransitionsForAd:ad configuration:configuration builder:builder];

    OCMVerify([self.factory addTransitionsForBannerAd:ad configuration:configuration builder:builder]);
}

- (void)testAddTransitionsForAd_fullscreenAsAsNextAdOfBannerAd {
    OGAAd *ad = [[OGAAd alloc] init];
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OGAAdContainerBuilder *builder = OCMClassMock([OGAAdContainerBuilder class]);
    OCMStub(configuration.adType).andReturn(OguryAdsTypeBanner);

    [self.factory addTransitionsForAd:ad configuration:configuration builder:builder];

    OCMVerify([self.factory addTransitionsForFullscreenAd:ad configuration:configuration builder:builder]);
}

- (void)testAddTransitionsForAd_thumbnailAd {
    OGAAd *ad = [[OGAAd alloc] init];
    ad.thumbnailAdResponse = [[OGAThumbnailAdResponse alloc] init];
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OGAAdContainerBuilder *builder = OCMClassMock([OGAAdContainerBuilder class]);
    OCMStub(configuration.adType).andReturn(OguryAdsTypeThumbnailAd);

    [self.factory addTransitionsForAd:ad configuration:configuration builder:builder];

    OCMVerify([self.factory addTransitionsForThumbnailAd:ad configuration:configuration builder:builder]);
}

- (void)testAddTransitionsForAd_fullscreenAsAsNextAdOfThumbnailAd {
    OGAAd *ad = [[OGAAd alloc] init];
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OGAAdContainerBuilder *builder = OCMClassMock([OGAAdContainerBuilder class]);
    OCMStub(configuration.adType).andReturn(OguryAdsTypeThumbnailAd);

    [self.factory addTransitionsForAd:ad configuration:configuration builder:builder];

    OCMVerify([self.factory addTransitionsForWindowedFullscreenAd:ad configuration:configuration builder:builder]);
}

- (void)testAddTransitionsForFullscreenAd {
    OGAAd *ad = [[OGAAd alloc] init];
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    id<OGAAdDisplayer> displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));
    OGAAdContainerBuilder *builder = [[OGAAdContainerBuilder alloc] initWithDisplayer:displayer];

    [self.factory addTransitionsForFullscreenAd:ad configuration:configuration builder:builder];

    XCTAssertEqual(builder.transitions.count, 20);
}

- (void)testAddTransitionsForBannerAd {
    OGAAd *ad = [[OGAAd alloc] init];
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    id<OGAAdDisplayer> displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));
    OGAAdContainerBuilder *builder = [[OGAAdContainerBuilder alloc] initWithDisplayer:displayer];

    [self.factory addTransitionsForBannerAd:ad configuration:configuration builder:builder];

    XCTAssertEqual(builder.transitions.count, 10);
}

- (void)testAddTransitionsForThumbnailAd {
    OGAAd *ad = [[OGAAd alloc] init];
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    id<OGAAdDisplayer> displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));
    OGAAdContainerBuilder *builder = [[OGAAdContainerBuilder alloc] initWithDisplayer:displayer];

    [self.factory addTransitionsForThumbnailAd:ad configuration:configuration builder:builder];

    XCTAssertEqual(builder.transitions.count, 11);
}

- (void)testAddTransitionsForWindowedFullscreenAd {
    OGAAd *ad = [[OGAAd alloc] init];
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    id<OGAAdDisplayer> displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));
    OGAAdContainerBuilder *builder = [[OGAAdContainerBuilder alloc] initWithDisplayer:displayer];

    [self.factory addTransitionsForWindowedFullscreenAd:ad configuration:configuration builder:builder];

    XCTAssertEqual(builder.transitions.count, 7);
}

- (void)testProfigExpirationDate {
    OGAAd *ad = OCMPartialMock([[OGAAd alloc] init]);
    OCMStub([ad expirationTime]).andReturn(nil);
    OGAAdSequence *sequence = OCMClassMock(OGAAdSequence.self);
    OGAAdConfiguration *configuration = OCMPartialMock([[OGAAdConfiguration alloc] init]);
    OCMStub([sequence configuration]).andReturn(configuration);
    OCMStub([configuration webviewLoadTimeout]).andReturn(@3);
    OGAExpirationContext *expirationContext = [[OGAExpirationContext alloc] initFrom:OGAdExpirationSourceProfig withExpirationTime:@1200];
    configuration.expirationContext = expirationContext;
    OGAAdController *controller = [self.factory createControllerForAd:ad sequence:sequence configuration:configuration];
    XCTAssertEqual(controller.expirationContext.expirationTime.intValue, 1200);
    XCTAssertEqual(configuration.expirationContext.expirationSource, OGAdExpirationSourceProfig);
}

- (void)testAdExpirationDate {
    OGAAd *ad = OCMPartialMock([[OGAAd alloc] init]);
    OCMStub([ad expirationTime]).andReturn(@2000);
    OGAAdSequence *sequence = OCMClassMock(OGAAdSequence.self);
    OGAAdConfiguration *configuration = OCMPartialMock([[OGAAdConfiguration alloc] init]);
    OCMStub([sequence configuration]).andReturn(configuration);
    OCMStub([configuration webviewLoadTimeout]).andReturn(@3);
    OGAExpirationContext *expirationContext = [[OGAExpirationContext alloc] initFrom:OGAdExpirationSourceProfig withExpirationTime:@1200];
    configuration.expirationContext = expirationContext;
    OGAAdController *controller = [self.factory createControllerForAd:ad sequence:sequence configuration:configuration];
    XCTAssertEqual(controller.expirationContext.expirationTime.intValue, 2000);
    XCTAssertEqual(controller.expirationContext.expirationSource, OGAdExpirationSourceAd);
}

@end

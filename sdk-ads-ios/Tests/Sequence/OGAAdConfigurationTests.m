//
//  Copyright © 2019 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "OGAAdConfiguration.h"
#import "OguryBannerAdDelegateDispatcher.h"
#import "OguryAdsBannerSize.h"

NSString *const OGAAdConfigurationTestsAdUnitId = @"ad-unit-id";
NSString *const OGAAdConfigurationTestsCampaignId = @"campaign-id";
NSString *const OGAAdConfigurationTestsCreativeId = @"creative-id";
NSString *const OGAAdConfigurationTestsDspCreativeId = @"dsp-creative-id";
NSString *const OGAAdConfigurationTestsDspRegion = @"region";
NSString *const OGAAdConfigurationTestsUserId = @"user-id";
NSString *const OGAEncodedAdMarkup = @"encoded-adMarkup";

@interface OGAAdConfiguration ()

- (instancetype)initWithType:(OguryAdsADType)type
                    adUnitId:(NSString *)adUnitId
          delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher
      viewControllerProvider:(OGAViewControllerProvider)viewControllerProvider
                viewProvider:(OGAViewProvider _Nullable)viewProvider
                      locale:(NSLocale *)locale;

@end

@interface OGAAdConfigurationTests : XCTestCase

@property(nonatomic, strong) OGADelegateDispatcher *delegateDispatcher;

@end

@implementation OGAAdConfigurationTests

- (void)setUp {
    self.delegateDispatcher = OCMClassMock([OGADelegateDispatcher class]);
}

- (void)testCopyWithZone {
    NSArray<NSString *> *blackListViewControllers = @[ @"blacklisted" ];
    NSArray<NSString *> *whitelistBundleIdentifiers = @[ @"whitelisted" ];

    OGADelegateDispatcher *delegateDispatcher = OCMClassMock([OGADelegateDispatcher class]);
    OGAViewControllerProvider viewControllerProvider = ^UIViewController * {
        return nil;
    };
    OGAViewProvider viewProvider = ^UIView * {
        return nil;
    };
    NSLocale *locale = OCMClassMock([NSLocale class]);
    OGAAdConfiguration *configuration = [[OGAAdConfiguration alloc] initWithType:OguryAdsTypeInterstitial
                                                                        adUnitId:OGAAdConfigurationTestsAdUnitId
                                                              delegateDispatcher:delegateDispatcher
                                                          viewControllerProvider:viewControllerProvider
                                                                    viewProvider:viewProvider
                                                                          locale:locale];
    configuration.size = CGSizeMake(180, 120);
    configuration.campaignId = OGAAdConfigurationTestsCampaignId;
    configuration.userId = OGAAdConfigurationTestsUserId;
    configuration.creativeId = OGAAdConfigurationTestsCreativeId;
    configuration.adDsp = [[OGAAdDsp alloc] initWithCreativeId:OGAAdConfigurationTestsDspCreativeId region:OGAAdConfigurationTestsDspRegion];
    configuration.corner = OguryBottomLeft;
    configuration.offset = OguryOffsetMake(50, 20);
    configuration.encodedAdMarkup = OGAEncodedAdMarkup;
    configuration.isHeaderBidding = true;
    configuration.blackListViewControllers = [NSArray arrayWithArray:blackListViewControllers];
    configuration.whitelistBundleIdentifiers = [NSArray arrayWithArray:whitelistBundleIdentifiers];
    OGAAdConfiguration *copiedConfiguration = [configuration copyWithZone:nil];

    XCTAssertNotEqual(configuration, copiedConfiguration);
    XCTAssertEqual(copiedConfiguration.adType, OguryAdsTypeInterstitial);
    XCTAssertEqual(copiedConfiguration.adUnitId, OGAAdConfigurationTestsAdUnitId);
    XCTAssertEqual(copiedConfiguration.creativeId, OGAAdConfigurationTestsCreativeId);
    XCTAssertEqual(copiedConfiguration.delegateDispatcher, delegateDispatcher);
    XCTAssertEqual(copiedConfiguration.viewControllerProvider, viewControllerProvider);
    XCTAssertEqual(copiedConfiguration.viewProvider, viewProvider);
    XCTAssertTrue(CGSizeEqualToSize(copiedConfiguration.size, CGSizeMake(180, 120)));
    XCTAssertEqualObjects(copiedConfiguration.campaignId, OGAAdConfigurationTestsCampaignId);
    XCTAssertEqualObjects(copiedConfiguration.userId, OGAAdConfigurationTestsUserId);
    XCTAssertEqual(copiedConfiguration.corner, OguryBottomLeft);
    XCTAssertEqual(copiedConfiguration.offset.x, 50);
    XCTAssertEqual(copiedConfiguration.offset.y, 20);
    XCTAssertEqual(copiedConfiguration.locale, locale);
    XCTAssertEqual(copiedConfiguration.encodedAdMarkup, OGAEncodedAdMarkup);
    XCTAssertEqual(copiedConfiguration.isHeaderBidding, true);
    XCTAssertEqualObjects(copiedConfiguration.blackListViewControllers, blackListViewControllers);
    XCTAssertEqualObjects(copiedConfiguration.whitelistBundleIdentifiers, whitelistBundleIdentifiers);
    XCTAssertEqual(copiedConfiguration.adDsp.creativeId, OGAAdConfigurationTestsDspCreativeId);
    XCTAssertEqual(copiedConfiguration.adDsp.region, OGAAdConfigurationTestsDspRegion);
}

- (void)testGetAdTypeString_interstitialAd {
    OGAAdConfiguration *configuration = [[OGAAdConfiguration alloc] initWithType:OguryAdsTypeInterstitial adUnitId:OGAAdConfigurationTestsAdUnitId delegateDispatcher:self.delegateDispatcher viewControllerProvider:nil viewProvider:nil];

    XCTAssertEqualObjects(configuration.getAdTypeString, @"interstitial");
}

- (void)testGetAdTypeString_RewardedAd {
    OGAAdConfiguration *configuration = [[OGAAdConfiguration alloc] initWithType:OguryAdsTypeRewardedAd adUnitId:OGAAdConfigurationTestsAdUnitId delegateDispatcher:self.delegateDispatcher viewControllerProvider:nil viewProvider:nil];

    XCTAssertEqualObjects(configuration.getAdTypeString, @"optin_video");
}

- (void)testGetAdTypeString_thumbnailAd {
    OGAAdConfiguration *configuration = [[OGAAdConfiguration alloc] initWithType:OguryAdsTypeThumbnailAd adUnitId:OGAAdConfigurationTestsAdUnitId delegateDispatcher:self.delegateDispatcher viewControllerProvider:nil viewProvider:nil];

    XCTAssertEqualObjects(configuration.getAdTypeString, @"overlay_thumbnail");
}

- (void)testGetAdTypeString_bannerAd_smallBanner {
    OGAAdConfiguration *configuration = [[OGAAdConfiguration alloc] initWithType:OguryAdsTypeBanner adUnitId:OGAAdConfigurationTestsAdUnitId delegateDispatcher:self.delegateDispatcher viewControllerProvider:nil viewProvider:nil];
    configuration.size = [[OguryAdsBannerSize small_banner_320x50] getSize];

    XCTAssertEqualObjects(configuration.getAdTypeString, @"banner_320x50");
}

- (void)testGetAdTypeString_bannerAd_mpu {
    OGAAdConfiguration *configuration = [[OGAAdConfiguration alloc] initWithType:OguryAdsTypeBanner adUnitId:OGAAdConfigurationTestsAdUnitId delegateDispatcher:self.delegateDispatcher viewControllerProvider:nil viewProvider:nil];
    configuration.size = [[OguryAdsBannerSize mrec_300x250] getSize];

    XCTAssertEqualObjects(configuration.getAdTypeString, @"medium_rectangle");
}

- (void)testGetAdTypeString_bannerAd_unrecognizedSize {
    OGAAdConfiguration *configuration = [[OGAAdConfiguration alloc] initWithType:OguryAdsTypeBanner adUnitId:OGAAdConfigurationTestsAdUnitId delegateDispatcher:self.delegateDispatcher viewControllerProvider:nil viewProvider:nil];
    configuration.size = CGSizeZero;

    XCTAssertEqualObjects(configuration.getAdTypeString, @"");
}

- (void)testShouldReturnBannerView {
    OguryBannerAdDelegateDispatcher *delegateDispatcher = OCMClassMock([OguryBannerAdDelegateDispatcher class]);

    UIViewController *viewController = [[UIViewController alloc] init];
    UIView *bannerView = [[UIView alloc] init];

    OGAAdConfiguration *config = [[OGAAdConfiguration alloc] initWithType:OguryAdsTypeBanner
        adUnitId:@""
        delegateDispatcher:delegateDispatcher
        viewControllerProvider:^UIViewController *_Nonnull {
            return viewController;
        }
        viewProvider:^UIView *_Nonnull {
            return bannerView;
        }];

    XCTAssertNotNil(config.viewControllerProvider());
    XCTAssertEqual(config.viewControllerProvider(), viewController);

    XCTAssertNotNil(config.viewProvider());
    XCTAssertEqual(config.viewProvider(), bannerView);
}

@end

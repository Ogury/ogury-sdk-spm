//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAThumbnailAdRestrictionsManager.h"
#import "OGAApplicationViewControllersManager.h"
#import <OCMock/OCMock.h>

@interface OGAThumbnailAdRestrictionsManager ()

@property(nonatomic, strong) NSArray *permanentWhitelistedBundles;
@property(nonatomic, strong) NSArray *permanentBlackListedViewControllersClassNames;
@property(nonatomic, strong) OGAApplicationViewControllersManager *applicationViewControllersManager;

- (instancetype)initWithPermanentWhitelistedBundles:(NSArray *)permanentWhitelistedBundles permanentBlackListedViewControllers:(NSArray *)permanentBlackListedViewControllers applicationViewControllersManager:(OGAApplicationViewControllersManager *)applicationViewControllersManager;

- (NSString *)processViewControllerName:(NSString *)name;

- (BOOL)isbundleWhiteListed:(NSString *)bundle publisherWhitelist:(NSArray<NSString *> *)whiteListBundles;

- (BOOL)checkBundleRestrictionFor:(NSArray<NSString *> *)whiteListBundles;

- (BOOL)shouldRestrict:(NSArray<NSString *> *_Nullable)viewControllers whiteListBundles:(NSArray<NSString *> *_Nullable)whiteListBundles;

- (NSArray *)getDefaultWhitelistedBundles;

- (NSArray *)getDefaultBlackListedViewControllers;

@end

@interface OGAThumbnailAdRestrictionsManagerTests : XCTestCase

@property(nonatomic, strong) OGAThumbnailAdRestrictionsManager *thumbnailAdRestrictionsManager;
@property(nonatomic, strong) NSArray *permanentWhitelistedBundles;
@property(nonatomic, strong) NSArray *permanentBlackListedViewControllers;
@property(nonatomic, strong) NSArray *publisherWhitelist;
@property(nonatomic, strong) OGAApplicationViewControllersManager *applicationViewControllersManager;

@end

@implementation OGAThumbnailAdRestrictionsManagerTests

- (void)setUp {
    self.permanentWhitelistedBundles = @[ @"Whitelisted1", @"Whitelisted2" ];
    self.permanentBlackListedViewControllers = @[ @"BlackListed1", @"BlackListed2" ];
    self.applicationViewControllersManager = OCMClassMock([OGAApplicationViewControllersManager class]);
    self.thumbnailAdRestrictionsManager = OCMPartialMock([[OGAThumbnailAdRestrictionsManager alloc] initWithPermanentWhitelistedBundles:self.permanentWhitelistedBundles permanentBlackListedViewControllers:self.permanentBlackListedViewControllers applicationViewControllersManager:self.applicationViewControllersManager]);
}

- (void)testShouldRestrictBundleYes {
    NSArray *viewControllers = @[ @"VC1", @"VC2" ];
    NSArray *bundles = @[ @"bundle1", @"bundle2" ];
    OCMStub([self.applicationViewControllersManager getVisibleBundles]).andReturn(bundles);
    OCMStub([self.applicationViewControllersManager getVisibleViewControllers]).andReturn(viewControllers);
    OCMStub([self.thumbnailAdRestrictionsManager checkBundleRestrictionFor:[OCMArg any]]).andReturn(true);
    XCTAssertTrue([self.thumbnailAdRestrictionsManager shouldRestrict:@[ @"VC3" ] whiteListBundles:@[ @"bundle3" ]]);
}

- (void)testShouldRestrictBundleNo_Vc_No {
    NSArray *viewControllers = @[ @"VC1", @"VC2" ];
    NSArray *bundles = @[ @"bundle1", @"bundle2" ];
    OCMStub([self.applicationViewControllersManager getVisibleBundles]).andReturn(bundles);
    OCMStub([self.applicationViewControllersManager getVisibleViewControllers]).andReturn(viewControllers);
    OCMStub([self.thumbnailAdRestrictionsManager checkBundleRestrictionFor:[OCMArg any]]).andReturn(false);
    XCTAssertFalse([self.thumbnailAdRestrictionsManager shouldRestrict:@[ @"VC3" ] whiteListBundles:@[ @"bundle3" ]]);
}

- (void)testShouldRestrictBundleNo_Vc_Yes {
    NSArray *viewControllers = @[ @"VC1", @"VC2" ];
    NSArray *bundles = @[ @"bundle1", @"bundle2" ];
    OCMStub([self.applicationViewControllersManager getVisibleBundles]).andReturn(bundles);
    OCMStub([self.applicationViewControllersManager getVisibleViewControllers]).andReturn(viewControllers);
    OCMStub([self.thumbnailAdRestrictionsManager checkBundleRestrictionFor:[OCMArg any]]).andReturn(false);
    XCTAssertTrue([self.thumbnailAdRestrictionsManager shouldRestrict:@[ @"VC1" ] whiteListBundles:@[ @"bundle3" ]]);
}

- (void)testCheckBundleRestrictionForFalse {
    NSArray *bundles = @[ @"bundle1", @"bundle2" ];
    OCMStub([self.applicationViewControllersManager getVisibleBundles]).andReturn(bundles);
    XCTAssertTrue([self.thumbnailAdRestrictionsManager checkBundleRestrictionFor:@[ @"bundle3" ]]);
}

- (void)testCheckBundleRestrictionForTrue {
    NSArray *bundles = @[ @"bundle1", @"bundle2" ];
    OCMStub([self.applicationViewControllersManager getVisibleBundles]).andReturn(bundles);
    XCTAssertTrue([self.thumbnailAdRestrictionsManager checkBundleRestrictionFor:@[ @"bundle1" ]]);
}

- (void)testIsbundleWhiteListPermanent {
    XCTAssertTrue([self.thumbnailAdRestrictionsManager isbundleWhiteListed:@"Whitelisted1" publisherWhitelist:@[ @"Whitelisted3" ]]);
}

- (void)testIsbundleWhiteListPublisher {
    XCTAssertTrue([self.thumbnailAdRestrictionsManager isbundleWhiteListed:@"Whitelisted3" publisherWhitelist:@[ @"Whitelisted3" ]]);
}

- (void)testIsbundleWhiteListNotlisted {
    XCTAssertFalse([self.thumbnailAdRestrictionsManager isbundleWhiteListed:@"Whitelisted4" publisherWhitelist:@[ @"Whitelisted3" ]]);
}

- (void)testProcessViewControllerName2 {
    XCTAssertEqualObjects([self.thumbnailAdRestrictionsManager processViewControllerName:@"Bundle.VC1"], @"VC1");
}

- (void)testProcessViewControllerName1 {
    XCTAssertEqualObjects([self.thumbnailAdRestrictionsManager processViewControllerName:@"Bundle"], @"Bundle");
}

- (void)testProcessViewControllerName3 {
    XCTAssertEqualObjects([self.thumbnailAdRestrictionsManager processViewControllerName:@"Bundle1.bundle2.VC1"], @"VC1");
}

- (void)testProcessViewControllerNameNil {
    XCTAssertEqualObjects([self.thumbnailAdRestrictionsManager processViewControllerName:nil], nil);
}

- (void)testGetDefaultBlackListedViewControllers;
{
    NSArray *blackList = [self.thumbnailAdRestrictionsManager getDefaultBlackListedViewControllers];
    XCTAssertTrue([blackList containsObject:@"OGAFullscreenViewController"]);
    XCTAssertTrue([blackList containsObject:@"OguryConsentViewController"]);
    XCTAssertEqual(blackList.count, 2);
}

- (void)testGetDefaultWhitelistedBundles;
{
    NSArray *whiteList = [self.thumbnailAdRestrictionsManager getDefaultWhitelistedBundles];
    XCTAssertTrue([whiteList containsObject:@"com.apple"]);
    XCTAssertTrue([whiteList containsObject:@"com.unity3d"]);
    XCTAssertTrue([whiteList containsObject:@"com.ogury.AdsCardLibrary"]);
    XCTAssertTrue([whiteList containsObject:NSBundle.mainBundle.bundleIdentifier]);
    XCTAssertEqual(whiteList.count, 4);
}

@end

//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGAAdLandingPagePrefetcher.h"
#import "OGAAd.h"
#import "OGAAdUnit.h"

static NSString *const DefaultAdIdentifier = @"1e5482e2-9239-4a47-9384-1a2d661a791e";

@interface OGAAdLandingPagePrefetcher (Testing)

#pragma mark - Properties

@property(nonatomic, strong) NSMutableDictionary<NSString *, UIView *> *landingPages;

@end

@interface OGAAdLandingPagePrefetcherTests : XCTestCase

#pragma mark - Properties

@property(nonatomic, strong) OGAAdLandingPagePrefetcher *element;

@end

@implementation OGAAdLandingPagePrefetcherTests

#warning FIXME : Enable this Tests in Shema.

#pragma mark - Methods

- (void)setUp {
    self.element = OGAAdLandingPagePrefetcher.shared;

    [self.element.landingPages removeAllObjects];
}

#pragma mark - Tests

- (void)testShouldPrefetchLandingPageForAd {
    // FIX ME: unit test removed after prefetchLandingPageForAd has been deactivated
    /*
    OGAAd *mockAd = OCMClassMock([OGAAd class]);
    OCMStub(mockAd.identifier).andReturn(DefaultAdIdentifier);
    OCMStub(mockAd.landingPagePrefetchURL).andReturn(@"https://www.google.com");

    XCTAssertEqual(self.element.landingPages.count, 0);

    [self.element prefetchLandingPageForAd:mockAd];

    XCTAssertEqual(self.element.landingPages.count, 1);
     */
}

- (void)testShouldReturnLandingPageForAdWhenPrefetched {
    // FIX ME: unit test removed after prefetchLandingPageForAd has been deactivated
    /*
    OGAAd *mockAd = OCMClassMock([OGAAd class]);
    OCMStub(mockAd.identifier).andReturn(DefaultAdIdentifier);
    OCMStub(mockAd.landingPagePrefetchURL).andReturn(@"https://www.google.com");

    [self.element prefetchLandingPageForAd:mockAd];

    UIView *landingPage = [self.element landingPageForAd:mockAd];

    XCTAssertNotNil(landingPage);
    */
}

- (void)testShouldNotReturnLandingPageForAdIfNoPrefetchHasBeenDone {
    OGAAd *mockAd = OCMClassMock([OGAAd class]);
    OCMStub(mockAd.identifier).andReturn(DefaultAdIdentifier);
    OCMStub(mockAd.landingPagePrefetchURL).andReturn(@"https://www.google.com");

    UIView *landingPage = [self.element landingPageForAd:mockAd];

    XCTAssertNil(landingPage);
}

- (void)testShouldClearPrefetchedLandingPageForAd {
    // FIX ME: unit test removed after prefetchLandingPageForAd has been deactivated
    /*
    OGAAd *mockAd = OCMClassMock([OGAAd class]);
    OCMStub(mockAd.identifier).andReturn(DefaultAdIdentifier);
    OCMStub(mockAd.landingPagePrefetchURL).andReturn(@"https://www.google.com");
    XCTAssertEqual(self.element.landingPages.count, 0);
    [self.element prefetchLandingPageForAd:mockAd];
    XCTAssertEqual(self.element.landingPages.count, 1);
    [self.element clearLandingPageForAd:mockAd];
    XCTAssertEqual(self.element.landingPages.count, 0);
    */
}

@end

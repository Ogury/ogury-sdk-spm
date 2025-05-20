//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import <OCMock/OCMock.h>
#import "OGAAdDisplayer.h"
#import "OGABannerAdViewContainerState.h"
#import "OGABannerAdContainerState+Testing.h"
#import "OGABaseAdContainerState+Testing.h"
#import "OGAAdExposureController.h"
#import "OGAAdConfiguration.h"
#import "OGAAd.h"
#import "OGABannerAdResponse.h"
#import "OGAAdDisplayerUpdateExposureInformation.h"

@interface OGABannerAdContainerStateTests : XCTestCase

@end

@implementation OGABannerAdContainerStateTests

#pragma mark - Methods

- (void)testShouldInstantiate {
    OGABannerAdViewContainerState *state = [[OGABannerAdViewContainerState alloc] init];

    XCTAssertNotNil(state);
    XCTAssertEqualObjects(state.name, @"banner");
    XCTAssertEqual(state.type, OGAAdContainerStateTypeInline);
}

- (void)test_ShouldReturnIsExpandedAsFalse {
    OGABannerAdViewContainerState *state = [[OGABannerAdViewContainerState alloc] init];

    XCTAssertFalse(state.isExpanded);
}

- (void)testShouldDisplay {
    UIView *bannerView = [[UIView alloc] init];

    id<OGAAdDisplayer> displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));

    OGAAd *ad = OCMClassMock(OGAAd.self);

    OCMStub([displayer ad]).andReturn(ad);

    OGABannerAdResponse *bannerAdResponse = OCMClassMock(OGABannerAdResponse.self);

    OCMStub([ad bannerAdResponse]).andReturn(bannerAdResponse);

    OGABannerAdViewContainerState *state = OCMPartialMock([[OGABannerAdViewContainerState alloc]
        initWithViewProvider:^UIView *_Nonnull {
            return bannerView;
        }
        viewControllerProvider:^UIViewController *_Nonnull {
            return nil;
        }]);

    OCMExpect([state centerBannerInFrame]);

    OguryError *error = nil;
    XCTAssertTrue([state display:displayer error:&error]);

    OCMVerify([state centerBannerInFrame]);
    OCMVerify([displayer startOMIDSessionOnShow]);
    OCMVerify([displayer registerForVolumeChange]);
}

- (void)testShouldNotDisplayWithoutBannerRelatedConfiguration {
    UIView *parentView = [[UIView alloc] init];

    UIView *bannerView = [[UIView alloc] init];

    [parentView addSubview:bannerView];

    id<OGAAdDisplayer> displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));

    OCMStub([displayer.ad bannerAdResponse]).andReturn(nil);

    OGABannerAdViewContainerState *state = OCMPartialMock([[OGABannerAdViewContainerState alloc]
        initWithViewProvider:^UIView *_Nonnull {
            return nil;
        }
        viewControllerProvider:^UIViewController *_Nonnull {
            return nil;
        }]);

    state.parentView = parentView;

    OguryError *error = nil;
    XCTAssertFalse([state display:displayer error:&error]);
    XCTAssertNotNil(error);
}

- (void)testShouldNotDisplayWithoutViewProvider {
    id<OGAAdDisplayer> displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));

    OGABannerAdViewContainerState *state = OCMPartialMock([[OGABannerAdViewContainerState alloc]
        initWithViewProvider:^UIView *_Nonnull {
            return nil;
        }
        viewControllerProvider:^UIViewController *_Nonnull {
            return nil;
        }]);

    OguryError *error = nil;
    XCTAssertFalse([state display:displayer error:&error]);
    XCTAssertNotNil(error);
}

- (void)testShouldCleanUp {
    UIView *parentView = [[UIView alloc] init];

    OGABannerAdViewContainerState *state = OCMPartialMock([[OGABannerAdViewContainerState alloc]
        initWithViewProvider:^UIView *_Nonnull {
            return nil;
        }
        viewControllerProvider:^UIViewController *_Nonnull {
            return nil;
        }]);

    state.parentView = parentView;

    [state startViewsObservation];

    OCMExpect([state removeKeyPathObservers]);
    OCMExpect([state.notificationCenter removeObserver:OCMOCK_ANY]);
    OCMExpect([state.displayer.view removeFromSuperview]);
    OCMExpect([state.exposureController stopExposure]);

    [state cleanUp];

    OCMVerify([state.notificationCenter removeObserver:OCMOCK_ANY]);
    OCMVerify([state.displayer.view removeFromSuperview]);
    OCMVerify([state.exposureController stopExposure]);
}

- (void)testShouldObserveDisplayerViewFrameChange {
    id<OGAAdDisplayer> displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));

    UIView *displayerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 512, 512)];

    OCMStub([displayer view]).andReturn(displayerView);

    UIView *bannerView = [[UIView alloc] init];

    OCMStub([displayer view]).andReturn(bannerView);

    OGABannerAdViewContainerState *state = OCMPartialMock([[OGABannerAdViewContainerState alloc]
        initWithViewProvider:^UIView *_Nonnull {
            return bannerView;
        }
        viewControllerProvider:^UIViewController *_Nonnull {
            return nil;
        }]);

    state.bannerView = bannerView;

    [state overrideDisplayer:displayer];

    [state startViewsObservation];

    bannerView.frame = CGRectMake(0, 0, 1024, 1024);

    OCMVerify([state centerBannerInFrame]);
    OCMVerify([state.exposureController computeExposure]);
}

- (void)testShouldStopObservingKeyValuePaths {
    UIView *parentView = OCMPartialMock([[UIView alloc] init]);

    UIView *bannerView = OCMPartialMock([[UIView alloc] init]);

    OGABannerAdViewContainerState *state = OCMPartialMock([[OGABannerAdViewContainerState alloc]
        initWithViewProvider:^UIView *_Nonnull {
            return bannerView;
        }
        viewControllerProvider:^UIViewController *_Nonnull {
            return nil;
        }]);

    [state overrideBannerView:bannerView];
    state.parentView = parentView;

    [state startViewsObservation];

    [state removeKeyPathObservers];

    OCMVerify([bannerView removeObserver:OCMOCK_ANY forKeyPath:@"frame"]);
    OCMVerify([bannerView removeObserver:OCMOCK_ANY forKeyPath:@"alpha"]);
    OCMVerify([bannerView removeObserver:OCMOCK_ANY forKeyPath:@"hidden"]);
    OCMVerify([parentView.layer removeObserver:OCMOCK_ANY forKeyPath:@"bounds"]);
}

- (void)testShouldComputeExposureWithSignificantParentBoundsChange {
    UIView *parentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 512, 512)];

    UIView *bannerView = [[UIView alloc] init];

    [parentView addSubview:bannerView];

    OGABannerAdViewContainerState *state = OCMPartialMock([[OGABannerAdViewContainerState alloc]
        initWithViewProvider:^UIView *_Nonnull {
            return bannerView;
        }
        viewControllerProvider:^UIViewController *_Nonnull {
            return nil;
        }]);

    state.bannerView = bannerView;
    state.parentView = parentView;
    [state startViewsObservation];

    OCMExpect([state.exposureController computeExposure]);

    parentView.bounds = CGRectMake(128, 128, 512, 512);

    OCMVerify([state.exposureController computeExposure]);
}

- (void)testShouldNotComputeExposureWithInsignificantParentBoundsChange {
    UIView *parentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 512, 512)];

    UIView *bannerView = [[UIView alloc] init];

    [parentView addSubview:bannerView];

    OGABannerAdViewContainerState *state = OCMPartialMock([[OGABannerAdViewContainerState alloc]
        initWithViewProvider:^UIView *_Nonnull {
            return bannerView;
        }
        viewControllerProvider:^UIViewController *_Nonnull {
            return nil;
        }]);

    state.bannerView = bannerView;
    state.parentView = parentView;
    [state startViewsObservation];

    parentView.bounds = CGRectMake(2, 2, 512, 512);

    OCMReject([state.exposureController computeExposure]);
}

- (void)testShouldCenterBannerViewInFrame {
    id<OGAAdDisplayer> displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));

    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub(configuration.adType).andReturn(OguryAdsTypeBanner);
    OCMStub(configuration.size).andReturn(CGSizeMake(50, 50));

    OCMStub([displayer configuration]).andReturn(configuration);

    UIView *displayerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];

    OCMStub([displayer view]).andReturn(displayerView);

    UIView *bannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 500, 500)];

    OGABannerAdViewContainerState *state = [[OGABannerAdViewContainerState alloc]
        initWithViewProvider:^UIView *_Nonnull {
            return bannerView;
        }
        viewControllerProvider:^UIViewController *_Nonnull {
            return nil;
        }];

    [state overrideDisplayer:displayer];
    [state overrideBannerView:bannerView];
    [state startViewsObservation];

    [state centerBannerInFrame];

    XCTAssertEqual(displayerView.frame.origin.x, 225);
    XCTAssertEqual(displayerView.frame.origin.y, 225);
}

- (void)testShouldComputeExposureWhenWindowDidBecomeVisible {
    OGABannerAdViewContainerState *state = OCMPartialMock([[OGABannerAdViewContainerState alloc]
        initWithViewProvider:^UIView *_Nonnull {
            return nil;
        }
        viewControllerProvider:^UIViewController *_Nonnull {
            return nil;
        }]);

    OCMExpect([state.exposureController computeExposure]);

    [state windowDidBecomeVisible:OCMOCK_ANY];

    OCMVerify([state.exposureController computeExposure]);
}

- (void)testShouldComputeExposureWhenWindowDidBecomeHidden {
    OGABannerAdViewContainerState *state = OCMPartialMock([[OGABannerAdViewContainerState alloc]
        initWithViewProvider:^UIView *_Nonnull {
            return nil;
        }
        viewControllerProvider:^UIViewController *_Nonnull {
            return nil;
        }]);

    OCMExpect([state.exposureController computeExposure]);

    [state windowDidBecomeHidden:OCMOCK_ANY];

    OCMVerify([state.exposureController computeExposure]);
}

- (void)testShouldComputeExposureWhenWindowDidBecomeKey {
    OGABannerAdViewContainerState *state = OCMPartialMock([[OGABannerAdViewContainerState alloc]
        initWithViewProvider:^UIView *_Nonnull {
            return nil;
        }
        viewControllerProvider:^UIViewController *_Nonnull {
            return nil;
        }]);

    OCMExpect([state.exposureController computeExposure]);

    [state windowDidBecomeKey:OCMOCK_ANY];

    OCMVerify([state.exposureController computeExposure]);
}

- (void)testShouldComputeExposureWhenWindowDidResignKey {
    OGABannerAdViewContainerState *state = OCMPartialMock([[OGABannerAdViewContainerState alloc]
        initWithViewProvider:^UIView *_Nonnull {
            return nil;
        }
        viewControllerProvider:^UIViewController *_Nonnull {
            return nil;
        }]);

    OCMExpect([state.exposureController computeExposure]);

    [state windowDidResignKey:OCMOCK_ANY];

    OCMVerify([state.exposureController computeExposure]);
}

- (void)testShouldSendZeroExposureWhenApplicationWillResignActive {
    id<OGAAdDisplayer> displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));

    OGABannerAdViewContainerState *state = OCMPartialMock([[OGABannerAdViewContainerState alloc]
        initWithViewProvider:^UIView *_Nonnull {
            return nil;
        }
        viewControllerProvider:^UIViewController *_Nonnull {
            return nil;
        }]);

    [state overrideDisplayer:displayer];

    [state applicationWillResignActive];

    OCMVerify([displayer dispatchInformation:[OCMArg isKindOfClass:OGAAdDisplayerUpdateExposureInformation.self]]);
}

- (void)testShouldComputeExposureWhenBannerViewDidMoveToWindow {
    id<OGAAdDisplayer> displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));

    OGAAd *ad = OCMClassMock(OGAAd.self);

    OCMStub(displayer.ad).andReturn(ad);

    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub(configuration.adUnitId).andReturn(@"1234-56789");

    OCMStub(ad.adConfiguration).andReturn(configuration);

    UIView *bannerView = OCMPartialMock([[UIView alloc] initWithFrame:CGRectMake(0, 0, 500, 500)]);
    OCMStub(bannerView.window).andReturn(OCMClassMock(UIWindow.self));

    OGABannerAdViewContainerState *state = OCMPartialMock([[OGABannerAdViewContainerState alloc]
        initWithViewProvider:^UIView *_Nonnull {
            return bannerView;
        }
        viewControllerProvider:^UIViewController *_Nonnull {
            return nil;
        }]);

    [state overrideBannerView:bannerView];
    [state overrideDisplayer:displayer];
    [state startViewsObservation];

    [state bannerViewDidMoveToWindow:[[NSNotification alloc] initWithName:@"" object:@"1234-56789" userInfo:nil]];

    OCMVerify([state.exposureController computeExposure]);
    OCMReject([displayer dispatchInformation:[OCMArg isKindOfClass:OGAAdDisplayerUpdateExposureInformation.self]]);
}

- (void)testShouldSendZeroExposureWhenBannerViewDidMoveToNilWindow {
    id<OGAAdDisplayer> displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));

    OGAAd *ad = OCMClassMock(OGAAd.self);

    OCMStub(displayer.ad).andReturn(ad);

    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub(configuration.adUnitId).andReturn(@"1234-56789");

    OCMStub(ad.adConfiguration).andReturn(configuration);

    UIView *bannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 500, 500)];

    OGABannerAdViewContainerState *state = OCMPartialMock([[OGABannerAdViewContainerState alloc]
        initWithViewProvider:^UIView *_Nonnull {
            return bannerView;
        }
        viewControllerProvider:^UIViewController *_Nonnull {
            return nil;
        }]);

    [state overrideDisplayer:displayer];

    [state bannerViewDidMoveToWindow:[[NSNotification alloc] initWithName:@"" object:@"1234-56789" userInfo:nil]];

    OCMReject([state.exposureController computeExposure]);
    OCMVerify([displayer dispatchInformation:[OCMArg isKindOfClass:OGAAdDisplayerUpdateExposureInformation.self]]);
}

+ (NSArray<UIView *> *)getNestedViews:(int)quantity withScrollViewAtIndex:(int)scrollViewIndex {
    NSMutableArray<UIView *> *nestedViews = [[NSMutableArray alloc] initWithCapacity:quantity];

    for (int currentIndex = 0; currentIndex < quantity; currentIndex++) {
        UIView *newView = (currentIndex == scrollViewIndex) ? [[UIScrollView alloc] init] : [[UIView alloc] init];

        if (nestedViews.count > 0) {
            UIView *parentView = nestedViews[currentIndex - 1];
            if (parentView) {
                [parentView addSubview:newView];
            }
        }

        [nestedViews addObject:newView];
    }

    return nestedViews;
}

@end

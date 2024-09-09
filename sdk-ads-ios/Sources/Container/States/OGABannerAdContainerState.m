//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGABannerAdContainerState.h"
#import "OGAAdDisplayer.h"
#import "OGAAdExposureController.h"
#import "OGAAd.h"
#import "OGAAdConfiguration.h"
#import "OGAAdDisplayerUpdatePlacementInformation.h"
#import "OGAAdDisplayerUpdateStateInformation.h"
#import "OGAAdDisplayerUpdateViewabilityInformation.h"
#import "OGAAdDisplayerUpdateExposureInformation.h"
#import "OGABannerAdInternalAPI.h"
#import "OguryAdsError+Internal.h"

#pragma mark - Constants

static NSString *const OGABannerAdContainerStateKeyValueObservationFrameKey = @"frame";
static NSString *const OGABannerAdContainerStateKeyValueObservationBoundsKey = @"bounds";
static NSString *const OGABannerAdContainerStateKeyValueObservationAlphaKey = @"alpha";
static NSString *const OGABannerAdContainerStateKeyValueObservationHiddenKey = @"hidden";

static int const OGABannerAdContainerStateMaximumNumberOfParentTraversals = 16;

@interface OGABannerAdContainerState ()

#pragma mark - Properties

@property(nonatomic, weak, nullable) UIView *bannerView;
@property(nonatomic, weak, nullable) UIView *parentView;
@property(nonatomic, assign) CGRect previousParentViewControllerBounds;
@property(nonatomic, weak, nullable) UIView *lastKnownParentScrollView;
@property(nonatomic, assign) int numberOfParentTraversals;

@end

@implementation OGABannerAdContainerState

#pragma mark - Properties

@synthesize exposureController = _exposureController;

- (NSString *)name {
    return @"banner";
}

- (OGAAdContainerStateType)type {
    return OGAAdContainerStateTypeInline;
}

#pragma mark - Initialization

- (instancetype)initWithViewProvider:(UIView *_Nonnull (^)(void))viewProvider viewControllerProvider:(UIViewController * (^)(void))viewControllerProvider {
    if (self = [super initWithViewProvider:viewProvider viewControllerProvider:viewControllerProvider]) {
        _exposureController = [[OGAAdExposureController alloc] initWithParentViewControllerProvider:viewControllerProvider];
        _exposureController.delegate = self;
        _numberOfParentTraversals = 0;
    }
    return self;
}

#pragma mark - Methods

- (BOOL)display:(nonnull id<OGAAdDisplayer>)displayer error:(OguryError *_Nullable *_Nullable)error {
    if (![super display:displayer error:error]) {
        return NO;
    }

    if (!self.displayer.ad.bannerAdResponse) {
        if (error) {
            *error = [OguryError createOguryErrorWithCode:OGAInternalUnknownError localizedDescription:@"Missing banner configuration."];
        }

        return NO;
    }

    self.bannerView = self.viewProvider();

    if (!self.bannerView) {
        if (error) {
            *error = [OguryError createOguryErrorWithCode:OGAInternalUnknownError localizedDescription:@"Missing banner view to present."];
        }

        return NO;
    }

    [self.displayer dispatchInformation:[[OGAAdDisplayerUpdatePlacementInformation alloc] initWithPlacement:OGAAdDisplayerPlacementInline]];
    [self.displayer dispatchInformation:[[OGAAdDisplayerUpdateExposureInformation alloc] initWithExposure:[OGAAdExposure zeroExposure]]];

    [self.bannerView addSubview:self.displayer.view];
    [self.displayer startOMIDSessionOnShow];

    self.exposureController.exposedView = self.bannerView;
    self.exposureController.exposedWindow = self.bannerView.window;

    self.parentView = self.bannerView.superview;

    [self centerBannerInFrame];

    [self startViewsObservation];

    [self registerForApplicationLifecycleNotifications];

    [self.displayer registerForVolumeChange];

    [self.displayer dispatchInformation:[[OGAAdDisplayerUpdateViewabilityInformation alloc] initWithViewability:NO]];

    [self.exposureController startExposure];

    return YES;
}

- (void)startViewsObservation {
    [[self getParentScrollViewFrom:self.bannerView].layer addObserver:self forKeyPath:OGABannerAdContainerStateKeyValueObservationBoundsKey options:NSKeyValueObservingOptionNew context:nil];

    [self.bannerView addObserver:self forKeyPath:OGABannerAdContainerStateKeyValueObservationFrameKey options:NSKeyValueObservingOptionNew context:nil];
    [self.bannerView addObserver:self forKeyPath:OGABannerAdContainerStateKeyValueObservationAlphaKey options:NSKeyValueObservingOptionNew context:nil];
    [self.bannerView addObserver:self forKeyPath:OGABannerAdContainerStateKeyValueObservationHiddenKey options:NSKeyValueObservingOptionNew context:nil];

    if (self.parentView) {
        [self.parentView.layer addObserver:self forKeyPath:OGABannerAdContainerStateKeyValueObservationBoundsKey options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (UIView *_Nullable)getParentScrollViewFrom:(UIView *)view {
    // Parent scroll view has been discovered beforehand, no need to traverse the whole tree
    if (self.lastKnownParentScrollView) {
        return self.lastKnownParentScrollView;
    }

    // Prevent infinite recursion
    if (self.numberOfParentTraversals >= OGABannerAdContainerStateMaximumNumberOfParentTraversals) {
        return nil;
    }

    self.numberOfParentTraversals += 1;

    UIView *superView = view.superview;

    if (!superView || ![superView isKindOfClass:[UIScrollView class]]) {
        return [self getParentScrollViewFrom:superView];
    }

    self.lastKnownParentScrollView = superView;
    self.numberOfParentTraversals = 0;

    return superView;
}

- (void)cleanUp {
    [super cleanUp];

    [self removeKeyPathObservers];

    [self.displayer.view removeFromSuperview];

    [self.exposureController stopExposure];
}

- (void)centerBannerInFrame {
    if (!self.displayer.view) {
        return;
    }

    BOOL isFullScreen = self.displayer.ad.bannerAdResponse.isFullScreen;

    CGRect bannerFrame = self.bannerView.frame;
    CGSize adSize = self.displayer.configuration.size;

    double widthMargin = (bannerFrame.size.width - adSize.width) / 2;
    double heightMargin = (bannerFrame.size.height - adSize.height) / 2;

    double originX = (isFullScreen || widthMargin < 0) ? 0 : widthMargin;
    double originY = heightMargin < 0 ? 0 : heightMargin;
    //  TODO: this is a temporary fix for Banner UI rendering, should be changed with layout constraint rendering
    self.displayer.view.translatesAutoresizingMaskIntoConstraints = YES;
    self.displayer.view.frame = CGRectMake(originX, originY, isFullScreen ? bannerFrame.size.width : adSize.width, adSize.height);
}

- (void)computeExposure {
    [self.exposureController computeExposure];
}

#pragma mark - KeyPath observation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    if ([keyPath isEqualToString:OGABannerAdContainerStateKeyValueObservationBoundsKey] && [object isKindOfClass:CALayer.self]) {
        CALayer *layer = (CALayer *)object;

        // Check if the change is significant enough to compute a new exposure or not
        double horizontalDifference = self.previousParentViewControllerBounds.origin.x - layer.bounds.origin.x;
        double verticalDifference = self.previousParentViewControllerBounds.origin.y - layer.bounds.origin.y;

        int totalDifference = @((horizontalDifference * horizontalDifference) + (verticalDifference * verticalDifference)).intValue;

        if (self.bannerView && totalDifference > 100) {
            self.previousParentViewControllerBounds = layer.bounds;

            [self computeExposure];
        }
    } else if ([keyPath isEqualToString:OGABannerAdContainerStateKeyValueObservationFrameKey]) {
        [self centerBannerInFrame];
        [self computeExposure];
    } else if ([keyPath isEqualToString:OGABannerAdContainerStateKeyValueObservationAlphaKey] || [keyPath isEqualToString:OGABannerAdContainerStateKeyValueObservationHiddenKey]) {
        [self computeExposure];
    }
}

- (void)removeKeyPathObservers {
    [[self getParentScrollViewFrom:self.bannerView].layer removeObserver:self forKeyPath:OGABannerAdContainerStateKeyValueObservationBoundsKey];

    [self.bannerView removeObserver:self forKeyPath:OGABannerAdContainerStateKeyValueObservationFrameKey];
    [self.bannerView removeObserver:self forKeyPath:OGABannerAdContainerStateKeyValueObservationAlphaKey];
    [self.bannerView removeObserver:self forKeyPath:OGABannerAdContainerStateKeyValueObservationHiddenKey];

    if (self.parentView) {
        [self.parentView.layer removeObserver:self forKeyPath:OGABannerAdContainerStateKeyValueObservationBoundsKey];
    }
}

#pragma mark - Window & App observation

- (void)registerForApplicationLifecycleNotifications {
    [super registerForApplicationLifecycleNotifications];

    [self.notificationCenter addObserver:self selector:@selector(bannerViewDidMoveToWindow:) name:OGABannerAdInternalAPIBannerDidMoveToWindowNotificationName object:nil];
}

- (void)windowDidBecomeVisible:(NSNotification *)notification {
    [super windowDidBecomeVisible:notification];

    [self computeExposure];
}

- (void)windowDidBecomeHidden:(NSNotification *)notification {
    [super windowDidBecomeHidden:notification];

    [self computeExposure];
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
    [super windowDidBecomeKey:notification];

    [self computeExposure];
}

- (void)windowDidResignKey:(NSNotification *)notification {
    [super windowDidResignKey:notification];

    [self computeExposure];
}

- (void)bannerViewDidMoveToWindow:(NSNotification *)notification {
    NSString *adUnitId = (NSString *)notification.object;

    self.exposureController.exposedWindow = self.bannerView.window;

    if (adUnitId && [adUnitId isEqualToString:self.displayer.ad.adConfiguration.adUnitId]) {
        // Exposure is used to pause or resume the video
        if (self.bannerView.window) {
            [self.exposureController startExposure];
        } else {
            [self.exposureController stopExposure];
        }
    }
}

@end

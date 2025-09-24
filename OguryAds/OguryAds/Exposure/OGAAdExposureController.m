//
// Copyright (c) 2020 Ogury Ltd. All rights reserved.
//

#import "OGAAdExposureController.h"
#import "OGAThumbnailAdConstants.h"
#import "OGAKeyboardObserver.h"

@interface OGAAdExposureController ()

@property(nonatomic, copy) UIViewController * (^parentViewControllerProvider)(void);
@property(nonatomic, assign) NSNotificationCenter *notificationCenter;
@property(nonatomic, assign) UIApplication *application;
@property(nonatomic, assign) BOOL stopAdExposure;
@property(nonatomic, assign) OGAKeyboardObserver *keyboardObserver;
@property(nonatomic, assign) NSTimer *exposureTimer;

@end

@implementation OGAAdExposureController

static double const OGAExposureCalculationTimeInterval = 1.0;

- (instancetype)initWithApplication:(UIApplication *)application keyboardObserver:(OGAKeyboardObserver *)keyboardObserver notificationCenter:(NSNotificationCenter *)notificationCenter exposedView:(UIView *)exposedView exposedWindow:(UIWindow *)exposedWindow parentViewControllerProvider:(UIViewController * (^)(
                                                                                                                                                                                                                                                                                                   void))parentViewControllerProvider {
    if (self = [super init]) {
        _parentViewControllerProvider = parentViewControllerProvider;
        _application = application;
        _notificationCenter = notificationCenter;
        _exposedView = exposedView;
        _exposedWindow = exposedWindow;
        _keyboardObserver = keyboardObserver;
        [_notificationCenter addObserver:self selector:@selector(didReceiveKeyboardVisibilityDidChangeNotification:) name:OGAKeyboardVisibilityDidChangeNotification object:nil];
        _exposureTimer = [self createTimerForExposure];
    }

    return self;
}

- (instancetype)initWithExposedView:(UIView *)exposedView exposedWindow:(UIWindow *)exposedWindow parentViewControllerProvider:(UIViewController * (^)(
                                                                                                                                   void))parentViewControllerProvider {
    return [self initWithApplication:[UIApplication sharedApplication] keyboardObserver:[OGAKeyboardObserver shared] notificationCenter:NSNotificationCenter.defaultCenter exposedView:exposedView exposedWindow:exposedWindow parentViewControllerProvider:parentViewControllerProvider];
}

- (instancetype)initWithParentViewControllerProvider:(UIViewController * (^)(void))parentViewControllerProvider {
    return [self initWithApplication:[UIApplication sharedApplication] keyboardObserver:[OGAKeyboardObserver shared] notificationCenter:NSNotificationCenter.defaultCenter exposedView:nil exposedWindow:nil parentViewControllerProvider:parentViewControllerProvider];
}

- (void)dealloc {
    [self.notificationCenter removeObserver:self];
}

- (void)stopExposure {
    self.stopAdExposure = YES;
    [self computeExposure];
    [self.exposureTimer invalidate];
    self.exposureTimer = nil;
}

- (void)startExposure {
    self.stopAdExposure = NO;
    [self computeExposure];
    [self.exposureTimer invalidate];
    self.exposureTimer = nil;
    self.exposureTimer = [self createTimerForExposure];
}

- (void)computeExposure {
    if ([self.delegate respondsToSelector:@selector(exposureDidChange:)]) {
        [self.delegate exposureDidChange:[self getExposure]];
    }
}

- (void)didReceiveKeyboardVisibilityDidChangeNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:OGAKeyboardVisibilityDidChangeNotification]) {
        [self computeExposure];
    }
}

- (OGAAdExposure *)getExposure {
    if ([self.application applicationState] != UIApplicationStateActive || self.stopAdExposure || !self.exposedWindow || !self.exposedView) {
        return [OGAAdExposure zeroExposure];
    }

    NSMutableArray<NSValue *> *overlappingRect = [NSMutableArray arrayWithArray:[self getOverlappingWindow:self.exposedWindow inWindows:[self.application windows]]];

    UIViewController *parentViewController = self.parentViewControllerProvider();
    if (!parentViewController) {
        return [self getAdExposure:self.exposedWindow withOverlappingRect:overlappingRect];
    }

    UIViewController *referentViewController = [OGAAdExposureController getParentViewControllerFor:self.exposedView referentViewController:parentViewController];
    if (!referentViewController) {
        return [self getAdExposureWithFrame:self.exposedView.frame withOverlappingRect:overlappingRect];
    }

    [overlappingRect addObjectsFromArray:[self getOverlappingRectOfView:self.exposedView inView:self.exposedWindow]];
    [overlappingRect addObjectsFromArray:[self getOverlappingRectOfView:self.exposedView inView:referentViewController.view]];

    CGRect exposedFrame = [referentViewController.view convertRect:self.exposedView.bounds fromView:self.exposedView];
    return [self getAdExposureWithFrame:exposedFrame withOverlappingRect:overlappingRect];
}

+ (UIViewController *)getParentViewControllerFor:(UIView *)view referentViewController:(UIViewController *)viewController {
    if ([view isDescendantOfView:viewController.view]) {
        return viewController;
    }
    if (!viewController.presentedViewController) {
        return NULL;
    }
    return [self getParentViewControllerFor:view referentViewController:viewController.presentedViewController];
}

- (NSArray<NSValue *> *)getOverlappingRectOfView:(UIView *)exposedView inView:(UIView *)parentView {
    CGRect frame = [parentView convertRect:exposedView.frame fromView:exposedView];
    NSMutableArray<NSValue *> *overlappingRects = [NSMutableArray array];
    NSArray *viewsOfParent = [[NSArray alloc] initWithObjects:parentView, nil];
    [self getOutsideFrame:viewsOfParent frame:frame exposedView:exposedView parentView:parentView overlapingRects:overlappingRects isUnder:true];
    return overlappingRects;
}
/*
 * To find all covered view, It firstly check if the view is parent of exposed view,
 *      if not it check if view are transparent or not and do the same for subview if view are transparent.
 *      if the view are parent, it search covered view in all subview of parent view.
 */
- (void)getOutsideFrame:(NSArray<__kindof UIView *> *)arrOfView frame:(CGRect)frame exposedView:(UIView *)exposedView parentView:(UIView *)parentView overlapingRects:(NSMutableArray<NSValue *> *)overlapingRects isUnder:(BOOL)defaultIsUnder {
    BOOL isUnder = defaultIsUnder;
    for (int i = 0; i < arrOfView.count; i++) {
        CGRect frameOfSuperView = [self getConvertedPoint:arrOfView[i] baseView:parentView];
        if (![exposedView isDescendantOfView:arrOfView[i]] && exposedView != arrOfView[i]) {
            CGRect intersection = CGRectIntersection(frameOfSuperView, frame);
            if (!CGRectIsNull(intersection) && !isUnder && !arrOfView[i].isHidden && arrOfView[i].alpha != 0) {
                if ([self isViewTransparent:arrOfView[i]]) {
                    [overlapingRects addObject:[NSValue valueWithCGRect:intersection]];
                } else {
                    [self getOutsideFrame:arrOfView[i].subviews frame:frame exposedView:exposedView parentView:parentView overlapingRects:overlapingRects isUnder:false];
                }
            }
        } else {
            isUnder = false;
            if (exposedView != arrOfView[i]) {
                [self getOutsideFrame:arrOfView[i].subviews frame:frame exposedView:exposedView parentView:parentView overlapingRects:overlapingRects isUnder:true];
            }
        }
    }
}

- (BOOL)isViewTransparent:(UIView *)view {
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
    [view.backgroundColor getRed:&red green:&green blue:&blue alpha:&alpha];
    return view.backgroundColor != nil && view.backgroundColor != UIColor.clearColor && alpha > 0.1 && view.isHidden == NO;
}

- (CGRect)getConvertedPoint:(UIView *)targetView baseView:(UIView *)baseView {
    CGRect pnt = targetView.frame;
    if (targetView.superview == nil) {
        return pnt;
    }
    UIView *superview = targetView.superview;
    while (superview != baseView) {
        pnt = [superview.superview convertRect:pnt fromView:superview];
        if (superview.superview == nil) {
            break;
        } else {
            superview = superview.superview;
        }
    }
    return [superview convertRect:pnt toView:baseView];
}

- (OGAAdExposure *)getAdExposure:(UIWindow *)adWindow withOverlappingRect:(NSArray<NSValue *> *)overlappingRects {
    OGAAdExposure *adExposure = [[OGAAdExposure alloc] init];
    if (adWindow.hidden) {
        adExposure.exposurePercentage = 0.0f;
        return adExposure;
    }

    return [self getAdExposureWithFrame:adWindow.frame withOverlappingRect:overlappingRects];
}

- (CGRect)getScreenFrame {
    return UIScreen.mainScreen.bounds;
}

- (OGAAdExposure *)getAdExposureWithFrame:(CGRect)adFrame withOverlappingRect:(NSArray<NSValue *> *)overlappingRects {
    OGAAdExposure *adExposure = [[OGAAdExposure alloc] init];

    CGRect windowRect = adFrame;
    CGRect visibleWindowAdRect = CGRectIntersection(adFrame, [self getScreenFrame]);

    CGFloat webViewArea = windowRect.size.width * windowRect.size.height;
    CGFloat visibleWindowArea = visibleWindowAdRect.size.width * visibleWindowAdRect.size.height;
    NSInteger numberOfPointsCoveredByOtherViews = 0;
    if (overlappingRects.count > 0) {
        numberOfPointsCoveredByOtherViews = [self calculateNumberOfPointsCoveredByOtherViews:windowRect overlappingRects:overlappingRects];
    }

    CGFloat offscreenPoints = webViewArea - visibleWindowArea;
    if (offscreenPoints < 0) {
        offscreenPoints = 0;
    }

    CGFloat invisiblePercentage = (numberOfPointsCoveredByOtherViews + offscreenPoints) * OGAOneHundred / webViewArea;
    CGFloat exposurePercentage = OGAOneHundred - invisiblePercentage;
    if (exposurePercentage > OGAOneHundred) {
        exposurePercentage = OGAOneHundred;
    } else if (exposurePercentage < 0.0 || isnan(exposurePercentage)) {
        exposurePercentage = 0.0;
    }

    adExposure.exposurePercentage = exposurePercentage;
    adExposure.occlusionRectangles = overlappingRects;
    adExposure.visibleRectangle = windowRect;
    return adExposure;
}

- (NSArray<NSValue *> *)subtractRect:(CGRect)r1 on:(CGRect)r2 {
    // Find how much r1 overlaps r2
    CGRect intersection = CGRectIntersection(r1, r2);

    NSMutableArray<NSValue *> *arr = [[NSMutableArray alloc] init];
    // If they don't intersect, just return r2. No subtraction to be done
    if (CGRectIsNull(intersection) || intersection.size.width == 0 || intersection.size.height == 0) {
        [arr addObject:[NSValue valueWithCGRect:r2]];
        return arr;
    }

    if (r2.origin.y < intersection.origin.y) {
        [arr addObject:[NSValue valueWithCGRect:CGRectMake(r2.origin.x,
                                                           r2.origin.y,
                                                           r2.size.width,
                                                           intersection.origin.y - r2.origin.y)]];
    }

    if (r2.origin.x < intersection.origin.x) {
        [arr addObject:[NSValue valueWithCGRect:CGRectMake(r2.origin.x,
                                                           intersection.origin.y,
                                                           intersection.origin.x - r2.origin.x,
                                                           intersection.size.height)]];
    }

    if (r2.origin.x + r2.size.width > intersection.origin.x + intersection.size.width) {
        [arr addObject:[NSValue valueWithCGRect:CGRectMake(intersection.origin.x + intersection.size.width,
                                                           intersection.origin.y,
                                                           (r2.origin.x + r2.size.width) - (intersection.origin.x + intersection.size.width),
                                                           intersection.size.height)]];
    }

    if (r2.origin.y + r2.size.height > intersection.origin.y + intersection.size.height) {
        [arr addObject:[NSValue valueWithCGRect:CGRectMake(r2.origin.x,
                                                           intersection.origin.y + intersection.size.height,
                                                           r2.size.width,
                                                           (r2.origin.y + r2.size.height) - (intersection.origin.y + intersection.size.height))]];
    }

    return arr;
}

- (NSInteger)calculateNumberOfPointsCoveredByOtherViews:(CGRect)webViewRect overlappingRects:(NSArray *)array {
    NSMutableArray
        *arrOfDisplayRect = [[NSMutableArray alloc] initWithObjects:[NSValue valueWithCGRect:webViewRect], nil];
    for (NSValue *rectValue in array) {
        CGRect rectToSubstract = [rectValue CGRectValue];
        NSMutableArray<NSValue *> *arrAfterSupression = [[NSMutableArray alloc] init];
        for (NSValue *displayRect in arrOfDisplayRect) {
            CGRect rectDisplay = [displayRect CGRectValue];
            [arrAfterSupression addObjectsFromArray:[self subtractRect:rectToSubstract on:rectDisplay]];
        }
        [arrOfDisplayRect removeAllObjects];
        [arrOfDisplayRect addObjectsFromArray:arrAfterSupression];
    }
    NSInteger countDisplayPoint = 0;
    for (NSValue *displayRect in arrOfDisplayRect) {
        CGRect rectDisplay = [displayRect CGRectValue];
        countDisplayPoint += rectDisplay.size.height * rectDisplay.size.width;
    }

    return webViewRect.size.height * webViewRect.size.width - countDisplayPoint;
}

- (BOOL)isWindowVisible:(UIWindow *)window {
    return window.alpha > 0 && window.isHidden == NO && window.rootViewController != nil && [self isViewTransparent:window.rootViewController.view];
}

- (NSArray<NSValue *> *)getOverlappingWindow:(UIWindow *)currentWindow inWindows:(NSArray<UIWindow *> *)applicationWindows {
    NSMutableArray<NSValue *> *overlappingRects = [NSMutableArray array];
    for (UIWindow *window in applicationWindows) {
        if (window.rootViewController.view.window == window && window != currentWindow && window.windowLevel >= currentWindow.windowLevel && [self isWindowVisible:window] && CGRectIntersectsRect(window.frame, currentWindow.frame)) {
            NSValue *windowRect = [NSValue valueWithCGRect:window.frame];
            [overlappingRects addObject:windowRect];
        }
    }
    if (self.keyboardObserver.keyboardOnScreen) {
        [overlappingRects addObject:self.keyboardObserver.keyboardRect];
    }
    return overlappingRects;
}

- (NSTimer *)createTimerForExposure {
    return [NSTimer scheduledTimerWithTimeInterval:OGAExposureCalculationTimeInterval
                                            target:self
                                          selector:@selector(computeExposure)
                                          userInfo:nil
                                           repeats:YES];
}

@end

//
//  Copyright © 2019 Ogury Ltd. All rights reserved.
//

#import "UIViewController+OGAThumbnailAdRestrictions.h"
#import "objc/runtime.h"
#import "OGAThumbnailAdViewController.h"
#import "OGAApplicationViewControllersManager.h"

@implementation UIViewController (OGAThumbnailRestrictions)

+ (void)doThumbnailSwizzling {
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        SEL viewWillAppearSelector = @selector(viewWillAppear:);
        SEL viewWillAppearLoggerSelector = @selector(logged_viewWillAppear:);
        Method originalMethod = class_getInstanceMethod(self, viewWillAppearSelector);
        Method extendedMethod = class_getInstanceMethod(self, viewWillAppearLoggerSelector);
        if (!originalMethod || !extendedMethod) {
            return;
        }
        method_exchangeImplementations(originalMethod, extendedMethod);

        SEL viewWillDisappearSelector = @selector(viewWillDisappear:);
        SEL viewWillDisappearLoggerSelector = @selector(logged_viewWillDisappear:);
        Method originalViewWillDisappearMethod = class_getInstanceMethod(self, viewWillDisappearSelector);
        Method extendedViewWillDisappearMethod = class_getInstanceMethod(self, viewWillDisappearLoggerSelector);
        if (!originalViewWillDisappearMethod || !extendedViewWillDisappearMethod) {
            return;
        }
        method_exchangeImplementations(originalViewWillDisappearMethod, extendedViewWillDisappearMethod);

        UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
        int recursionLimitCounter = 0;
        while (topController.presentedViewController && recursionLimitCounter < 20) {
            topController = topController.presentedViewController;
            recursionLimitCounter += 1;
        }
        if (!topController.presentedViewController) {
            [[OGAApplicationViewControllersManager shared] addVisibleViewController:topController.getSelfClassRepresentation];
        }
    });
}

- (void)logged_viewWillAppear:(BOOL)animated {
    [self logged_viewWillAppear:animated];
    [[OGAApplicationViewControllersManager shared] addVisibleViewController:self.getSelfClassRepresentation];
}

- (void)logged_viewWillDisappear:(BOOL)animated {
    [self logged_viewWillDisappear:animated];
    [[OGAApplicationViewControllersManager shared] removeVisibleViewController:self.getSelfClassRepresentation];
}

- (NSDictionary<NSString *, NSString *> *)getSelfClassRepresentation {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *stringBundle = bundle.bundleIdentifier ?: @"";
    NSString *currentClass = NSStringFromClass([self class]);
    return @{currentClass : stringBundle};
}

@end

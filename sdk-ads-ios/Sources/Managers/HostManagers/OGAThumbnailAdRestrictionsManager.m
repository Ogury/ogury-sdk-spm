//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGAThumbnailAdRestrictionsManager.h"
#import "OGAFullscreenViewController.h"
#import "OGAThumbnailAdViewController.h"
#import "OGAApplicationViewControllersManager.h"
#import "OGAFullscreenViewController.h"

@interface OGAThumbnailAdRestrictionsManager ()

@property(nonatomic, strong) NSArray<NSString *> *permanentWhitelistedBundles;
@property(nonatomic, strong) NSArray<NSString *> *permanentBlackListedViewControllersClassNames;
@property(nonatomic, strong) OGAApplicationViewControllersManager *applicationViewControllersManager;

@end

@implementation OGAThumbnailAdRestrictionsManager

- (instancetype)init {
    return [self initWithPermanentWhitelistedBundles:[self getDefaultWhitelistedBundles] permanentBlackListedViewControllers:[self getDefaultBlackListedViewControllers] applicationViewControllersManager:[OGAApplicationViewControllersManager shared]];
}

- (instancetype)initWithPermanentWhitelistedBundles:(NSArray<NSString *> *)permanentWhitelistedBundles permanentBlackListedViewControllers:(NSArray<NSString *> *)permanentBlackListedViewControllersClassNames applicationViewControllersManager:(OGAApplicationViewControllersManager *)applicationViewControllersManager {
    if (self = [super init]) {
        _permanentWhitelistedBundles = permanentWhitelistedBundles;
        _permanentBlackListedViewControllersClassNames = permanentBlackListedViewControllersClassNames;
        _applicationViewControllersManager = applicationViewControllersManager;
    }
    return self;
}

- (BOOL)shouldRestrict:(NSArray<NSString *> *_Nullable)viewControllersClassNames whiteListBundles:(NSArray<NSString *> *_Nullable)whiteListBundles {
    NSMutableArray *restrictedViewControllersClassNames = [NSMutableArray arrayWithArray:self.permanentBlackListedViewControllersClassNames];
    if (viewControllersClassNames) {
        for (NSString *name in viewControllersClassNames) {
            [restrictedViewControllersClassNames addObject:[self processViewControllerName:name]];
        }
    }

    if (!whiteListBundles) {
        whiteListBundles = [NSArray array];
    }

    if ([self checkBundleRestrictionFor:whiteListBundles]) {
        return YES;
    }

    for (NSString *viewControllerName in restrictedViewControllersClassNames) {
        for (NSString *visibleViewController in [self.applicationViewControllersManager getVisibleViewControllers]) {
            if ([[self processViewControllerName:visibleViewController] isEqualToString:viewControllerName]) {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)checkBundleRestrictionFor:(nonnull NSArray<NSString *> *)whiteListBundles {
    BOOL restricted = false;
    for (NSString *visibleViewController in [self.applicationViewControllersManager getVisibleBundles]) {
        if ([self isbundleWhiteListed:visibleViewController publisherWhitelist:whiteListBundles] == NO) {
            restricted = true;
            break;
        }
    }
    return restricted;
}

- (BOOL)isbundleWhiteListed:(NSString *)bundle publisherWhitelist:(NSArray<NSString *> *)publisherWhitelistBundle {
    BOOL isWhiteListed = NO;
    NSArray *allWhitelistBundle = [self.permanentWhitelistedBundles arrayByAddingObjectsFromArray:publisherWhitelistBundle];
    for (NSString *whiteListedBundle in allWhitelistBundle) {
        if ([bundle containsString:whiteListedBundle]) {
            isWhiteListed = YES;
            break;
        }
    }
    return isWhiteListed;
}

- (NSString *)processViewControllerName:(NSString *)name {
    NSString *actualName = nil;
    if (name) {
        NSArray *compArray = [name componentsSeparatedByString:@"."];
        if (compArray.count > 1) {
            actualName = compArray.lastObject;
        } else if (compArray.count == 1) {
            actualName = compArray.firstObject;
        }
    }
    return actualName;
}

- (NSArray *)getDefaultWhitelistedBundles {
    return [NSArray arrayWithObjects:@"com.apple", @"com.unity3d", NSBundle.mainBundle.bundleIdentifier, @"com.ogury.AdsCardLibrary", nil];
}

- (NSArray *)getDefaultBlackListedViewControllers {
    return [NSArray arrayWithObjects:NSStringFromClass([OGAFullscreenViewController class]), @"OguryConsentViewController", nil];
}

@end

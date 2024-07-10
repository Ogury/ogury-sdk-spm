//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import "OGAApplicationViewControllersManager.h"
#import "OGAAdContainerConstants.h"

@interface OGAApplicationViewControllersManager ()

@property(nonatomic, strong) NSNotificationCenter *notificationCenter;
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *visibleViewControllers;

@end

@implementation OGAApplicationViewControllersManager

- (instancetype)init {
    return [self initWithNotificationCenter:[NSNotificationCenter defaultCenter] visibleViewControllers:[NSMutableDictionary dictionary]];
}

- (instancetype)initWithNotificationCenter:(NSNotificationCenter *)notificationCenter visibleViewControllers:(NSMutableDictionary<NSString *, NSString *> *)visibleViewControllers;
{
    if (self = [super init]) {
        _notificationCenter = notificationCenter;
        _visibleViewControllers = visibleViewControllers;
    }
    return self;
}

+ (instancetype)shared {
    static OGAApplicationViewControllersManager *instance;
    static dispatch_once_t token;

    dispatch_once(&token, ^{
        instance = [[OGAApplicationViewControllersManager alloc] init];
    });

    return instance;
}

- (NSArray<NSString *> *)getVisibleViewControllers {
    return self.visibleViewControllers.allKeys;
}

- (NSArray<NSString *> *)getVisibleBundles {
    return self.visibleViewControllers.allValues;
}

- (void)addVisibleViewController:(NSDictionary<NSString *, NSString *> *)visibleViewController {
    [self.visibleViewControllers addEntriesFromDictionary:visibleViewController];
    [self.notificationCenter postNotificationName:OGAViewControllersUpdated object:nil];
}

- (void)removeVisibleViewController:(NSDictionary<NSString *, NSString *> *)visibleViewController {
    [self.visibleViewControllers removeObjectForKey:visibleViewController.allKeys.firstObject];
    [self.notificationCenter postNotificationName:OGAViewControllersUpdated object:nil];
}

@end

//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGWModules.h"

@interface OGWModules ()

@property (nonatomic, strong) NSArray<OGWModule *> *modules;

@end

static NSString * const OGWModulesCoreModuleClassName = @"OGCInternal";
static NSString * const OGWModulesChoiceManagerModuleClassName = @"OGYInternal";
static NSString * const OGWModulesAdsModuleClassName = @"OGAInternal";

@implementation OGWModules

#pragma mark - Initialization

+ (OGWModules *)shared {
    static OGWModules *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        NSMutableArray *modules = [[NSMutableArray alloc] init];
        for (NSString *moduleClassName in @[
                OGWModulesCoreModuleClassName,
                OGWModulesChoiceManagerModuleClassName,
                OGWModulesAdsModuleClassName
        ]) {
            [modules addObject:[[OGWModule alloc] initWithClassName:moduleClassName]];
        }
        _modules = modules;
    }
    return self;
}

#pragma mark - Properties

- (OGWModule *)coreModule {
    return [self moduleByClassName:OGWModulesCoreModuleClassName];
}

- (OGWModule *)adsModule {
    return [self moduleByClassName:OGWModulesAdsModuleClassName];
}

- (OGWModule *)choiceManagerModule {
    return [self moduleByClassName:OGWModulesChoiceManagerModuleClassName];
}

#pragma mark - Methods

- (OGWModule *)moduleByClassName:(NSString *)className {
    OGWModule *foundModule;
    OGWModule *module;
    NSEnumerator<OGWModule *> *it = self.modules.objectEnumerator;
    while (!foundModule && (module = it.nextObject)) {
        if ([module.className isEqualToString:className]) {
            foundModule = module;
        }
    }
    return foundModule;
}

@end

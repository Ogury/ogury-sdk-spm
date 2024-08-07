//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGYModule.h"

@interface OGYModule ()

@property(nonatomic, retain, nullable) id module;

@end

@implementation OGYModule

NSString *const OGWModuleSharedSelector = @"shared";
NSString *const OGWModuleStartWithAssetKeySelector = @"startWithAssetKey:";
NSString *const OGWModuleGetVersionSelector = @"getVersion";

#pragma mark - Initialization

- (instancetype)initWithClassName:(NSString *)className {
    if (self = [super init]) {
        _className = className;
        SEL sharedSelector = NSSelectorFromString(OGWModuleSharedSelector);
        Class moduleClass = NSClassFromString(className);
        _module = [moduleClass performSelector:sharedSelector];
    }
    return self;
}

#pragma mark - Properties

- (BOOL)isPresent {
    return self.module != nil;
}

#pragma mark - Methods

- (void)startWithAssetKey:(NSString *)assetKey {
    SEL startWithAssetKeySelector = NSSelectorFromString(OGWModuleStartWithAssetKeySelector);
    if ([self.module respondsToSelector:startWithAssetKeySelector]) {
        NSMethodSignature *signature = [self methodSignatureForSelector:startWithAssetKeySelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];

        [invocation setSelector:startWithAssetKeySelector];
        [invocation setTarget:self.module];
        [invocation setArgument:&assetKey atIndex:2];
        [invocation invoke];
    }
}

@end

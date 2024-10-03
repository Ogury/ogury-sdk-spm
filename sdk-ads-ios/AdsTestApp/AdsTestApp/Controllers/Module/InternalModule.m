//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "InternalModule.h"

@interface InternalModule ()

@property(nonatomic, retain, nullable) id module;

@end

@implementation InternalModule

NSString *const InternalModuleSharedSelector = @"shared";
NSString *const InternalModuleStartWithAssetKeySelector = @"startWithAssetKey:";

#pragma mark - Initialization

- (instancetype)initWithClassName:(NSString *)className {
    if (self = [super init]) {
        _className = className;
        SEL sharedSelector = NSSelectorFromString(InternalModuleSharedSelector);
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
    SEL startWithAssetKeySelector = NSSelectorFromString(InternalModuleStartWithAssetKeySelector);
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

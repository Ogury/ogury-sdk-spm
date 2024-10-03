//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "InternalModule.h"

@interface InternalModule ()

@property(nonatomic, retain, nullable) id module;

@end

@implementation InternalModule

NSString *const InternalModuleSharedSelector = @"shared";
NSString *const InternalModuleStartWithSelector = @"startWith:";

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

- (void)startWith:(NSString *)assetKey {
    SEL startWithSelector = NSSelectorFromString(InternalModuleStartWithSelector);
    if ([self.module respondsToSelector:startWithSelector]) {
        NSMethodSignature *signature = [self methodSignatureForSelector:startWithSelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];

        [invocation setSelector:startWithSelector];
        [invocation setTarget:self.module];
        [invocation setArgument:&assetKey atIndex:2];
        [invocation invoke];
    }
}

@end

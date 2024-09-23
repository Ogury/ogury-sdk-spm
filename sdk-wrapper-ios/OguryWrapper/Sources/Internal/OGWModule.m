//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGWModule.h"
#import "OGWLog.h"

@interface OGWModule ()

@property(nonatomic, retain, nullable) id module;

@end

@implementation OGWModule

NSString *const OGWModuleSharedSelector = @"shared";
NSString *const OGWModuleStartWithAssetKeySelector = @"startWithAssetKey:";
NSString *const OGWModuleSetLogLevelSelector = @"setLogLevel:";
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

- (void)setLogLevel:(OguryLogLevel)logLevel {
   SEL setLogLevelSelector = NSSelectorFromString(OGWModuleSetLogLevelSelector);
   if ([self.module respondsToSelector:setLogLevelSelector]) {
      // using Invocation to pass a no-object type paramater
      NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self.module methodSignatureForSelector:setLogLevelSelector]];
      [inv setSelector:setLogLevelSelector];
      [inv setTarget:self.module];
      [inv setArgument:&logLevel atIndex:2];  // arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation
      [inv invoke];
   }
}

- (void)startWithAssetKey:(NSString *)assetKey {
    SEL startWithAssetKeySelector = NSSelectorFromString(OGWModuleStartWithAssetKeySelector);
    if ([self.module respondsToSelector:startWithAssetKeySelector]) {
        [[OGWLog shared] log:OguryLogLevelDebug message:[NSString stringWithFormat:@"Start with assetKey %@", assetKey]];
        
        NSMethodSignature *signature = [self methodSignatureForSelector:startWithAssetKeySelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        
        [invocation setSelector:startWithAssetKeySelector];
        [invocation setTarget:self.module];
        [invocation setArgument:&assetKey atIndex:2];
        [invocation invoke];
    }
}

- (NSString *)getVersion {
   SEL getVersionSelector = NSSelectorFromString(OGWModuleGetVersionSelector);
   if ([self.module respondsToSelector:getVersionSelector]) {
       [[OGWLog shared] log:OguryLogLevelDebug message:@"getVersion called"];
      return [self.module performSelector:getVersionSelector];
   } else {
       [[OGWLog shared] log:OguryLogLevelDebug message:[NSString stringWithFormat:@"getVersion not found on module %@", self]];
      return nil;
   }
}

@end

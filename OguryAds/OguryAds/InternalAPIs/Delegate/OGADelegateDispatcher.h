//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdDelegate.h"

@class OGALog;

NS_ASSUME_NONNULL_BEGIN

@interface OGADelegateDispatcher<T> : NSObject <OGAAdDelegate>

@property(weak) T delegate;
@property(nonatomic, assign) BOOL hasSentDisplayedDelegate;
@property(nonatomic, strong) OGALog *log;

- (void)dispatch:(void (^)(T delegate))block;

+ (void)setAlwaysDispatchInMainThread:(BOOL)alwaysDispatchInMainThread;

@end

NS_ASSUME_NONNULL_END

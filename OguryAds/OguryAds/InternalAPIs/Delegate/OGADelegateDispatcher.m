//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import "OGADelegateDispatcher.h"
#import "OGALog.h"

static BOOL oguryAdsAlwaysDispatchInMainThread = YES;

@interface OGADelegateDispatcher ()

@property BOOL alwaysDispatchInMainThread;

@end

@implementation OGADelegateDispatcher

- (id)init {
    return [self initWithAlwaysDispatchInMainThread:oguryAdsAlwaysDispatchInMainThread log:[OGALog shared]];
}

- (id)initWithAlwaysDispatchInMainThread:(BOOL)alwaysDispatchInMainThread log:(OGALog *)log {
    if (self = [super init]) {
        _alwaysDispatchInMainThread = alwaysDispatchInMainThread;
        _log = log;
    }
    return self;
}

- (void)dispatch:(void (^)(id _Nonnull delegate))block {
    __strong id strongDelegate = self.delegate;
    if (strongDelegate == nil) {
        return;
    }
    if (self.alwaysDispatchInMainThread) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(strongDelegate);
        });
    } else {
        block(strongDelegate);
    }
}

+ (void)setAlwaysDispatchInMainThread:(BOOL)alwaysDispatchInMainThread {
    oguryAdsAlwaysDispatchInMainThread = alwaysDispatchInMainThread;
}

@end

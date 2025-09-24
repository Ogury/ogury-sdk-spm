//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGAMraidVerificationOperation.h"

@interface OGAMraidVerificationOperation ()

@property(nonatomic, weak) OGAMraidBaseWebView *baseView;
@property(nonatomic, copy) void (^completionHandler)(BOOL);

@end

@implementation OGAMraidVerificationOperation

- (instancetype)initWithBaseView:(OGAMraidBaseWebView *)baseView completionHandler:(nonnull void (^)(BOOL))completionHandler {
    if (self = [super init]) {
        _baseView = baseView;
        _completionHandler = completionHandler;
    }

    return self;
}

- (void)main {
    if (self.isCancelled) {
        return;
    }

    // Give some time for the WKWebView (main thread) to evaluate the MRAID JS
    [NSThread sleepForTimeInterval:0.1];

    self.completionHandler(self.baseView.isCommunicatingWithMraid);
}

@end

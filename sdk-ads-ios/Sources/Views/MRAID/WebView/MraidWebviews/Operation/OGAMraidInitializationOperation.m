//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import "OGAMraidInitializationOperation.h"
#import "OGALog.h"
#import "OGAAd.h"
#import "OGAMraidCommandsHandler.h"

@interface OGAMraidInitializationOperation ()

@property(nonatomic, weak) OGAMraidBaseWebView *baseView;
@property(nonatomic, copy) NSString *initializationScript;
@property(nonatomic, assign) BOOL isRunning;
@property(nonatomic, assign) BOOL hasFinished;
@property(nonatomic, strong) OGALog *log;

@end

@implementation OGAMraidInitializationOperation

#pragma mark - Properties

- (BOOL)isExecuting {
    return self.isRunning;
}

- (void)setIsRunning:(BOOL)isRunning {
    [self willChangeValueForKey:@"isExecuting"];
    _isRunning = isRunning;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isFinished {
    return self.hasFinished;
}

- (void)setHasFinished:(BOOL)hasFinished {
    [self willChangeValueForKey:@"isFinished"];
    _hasFinished = hasFinished;
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - Initialization

- (instancetype)initWithBaseView:(OGAMraidBaseWebView *)baseView initializationScript:(nonnull NSString *)initializationScript {
    return [self initWithBaseView:baseView initializationScript:initializationScript log:[OGALog shared]];
}

- (instancetype)initWithBaseView:(OGAMraidBaseWebView *)baseView initializationScript:(nonnull NSString *)initializationScript log:(OGALog *)log {
    if (self = [super init]) {
        _baseView = baseView;
        _initializationScript = initializationScript;
        _log = log;
    }

    return self;
}

#pragma mark - Methods

- (void)start {
    if (self.isCancelled) {
        self.hasFinished = YES;
        return;
    }

    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];

    self.isRunning = YES;
}

- (void)main {
    if (self.isCancelled) {
        self.hasFinished = YES;
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.baseView.wkWebView evaluateJavaScript:self.initializationScript
                                  completionHandler:^(id _Nullable result, NSError *_Nullable error) {
                                      if (error) {
                                          [self.log logMraidError:error forAdConfiguration:self.baseView.ad.adConfiguration webViewId:self.baseView.webViewId message:@"An error occurred during MRAID evaluation in webview"];
                                      }

                                      self.isRunning = NO;
                                      self.hasFinished = YES;
                                  }];
    });
}

@end

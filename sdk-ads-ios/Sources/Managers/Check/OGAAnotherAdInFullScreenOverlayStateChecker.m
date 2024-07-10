//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import "OGAAnotherAdInFullScreenOverlayStateChecker.h"

#import "OGAAdManager+Check.h"
#import "OGAAdSequenceCoordinator.h"

@interface OGAAnotherAdInFullScreenOverlayStateChecker ()

@property(nonatomic, strong) OGAAdManager *adManager;

@end

@implementation OGAAnotherAdInFullScreenOverlayStateChecker

#pragma mark - Initialization

+ (instancetype)shared {
    static OGAAnotherAdInFullScreenOverlayStateChecker *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    return [self initWithAdManager:[OGAAdManager sharedManager]];
}

- (instancetype)initWithAdManager:(OGAAdManager *)adManager {
    if (self = [super init]) {
        _adManager = adManager;
    }
    return self;
}

#pragma mark - Methods

- (BOOL)checkForSequence:(OGAAdSequence *)sequence error:(OguryError **)error {
    if ([self isAnotherAdInFullScreenOverlayState:sequence]) {
        if (error) {
            *error = [OguryError createAnotherAdAlreadyDisplayedError];
        }
        return NO;
    }
    return YES;
}

- (BOOL)isAnotherAdInFullScreenOverlayState:(OGAAdSequence *)sequence {
    @synchronized(self.adManager.sequencesShowing) {
        OGAAdSequence *shownSequence = nil;
        NSEnumerator *it = [self.adManager.sequencesShowing objectEnumerator];
        while ((shownSequence = it.nextObject)) {
            if (shownSequence.coordinator && shownSequence.coordinator.isFullScreenOverlay) {
                return YES;
            }
        }
    }
    return NO;
}

@end

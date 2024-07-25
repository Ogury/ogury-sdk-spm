//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import "OGAAnotherAdOfSameTypeAlreadyDisplayedChecker.h"

#import "OGAAdManager+Check.h"
#import "OGAAdSequenceCoordinator.h"

@interface OGAAnotherAdOfSameTypeAlreadyDisplayedChecker ()

@property(nonatomic, strong) OGAAdManager *adManager;

@end

@implementation OGAAnotherAdOfSameTypeAlreadyDisplayedChecker

#pragma mark - Initialization

+ (instancetype)shared {
    static OGAAnotherAdOfSameTypeAlreadyDisplayedChecker *instance = nil;
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
    if ([self isAnotherAdOfSameTypeAlreadyDisplayed:sequence]) {
        if (error) {
            *error = [OguryError createAnotherAdAlreadyDisplayedError];
        }
        return NO;
    }
    return YES;
}

- (BOOL)isAnotherAdOfSameTypeAlreadyDisplayed:(OGAAdSequence *)sequence {
    @synchronized(self.adManager.sequencesShowing) {
        OGAAdSequence *shownSequence = nil;
        NSEnumerator *it = [self.adManager.sequencesShowing objectEnumerator];
        while ((shownSequence = it.nextObject)) {
            if (shownSequence.coordinator && sequence.configuration.adType == shownSequence.configuration.adType && shownSequence.coordinator.isDisplayed) {
                return YES;
            }
        }
    }
    return NO;
}

@end

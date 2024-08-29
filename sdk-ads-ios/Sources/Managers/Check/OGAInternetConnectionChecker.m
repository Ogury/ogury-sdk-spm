//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import "OGAInternetConnectionChecker.h"
#import "OguryAdsError+Internal.h"
#import "OGAReachability.h"

@interface OGAInternetConnectionChecker ()

@property(nonatomic, strong) OGAReachability *internetReachability;

@end

@implementation OGAInternetConnectionChecker

#pragma mark - Initialization

+ (instancetype)shared {
    static OGAInternetConnectionChecker *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    return [self initWithInternetReachability:[OGAReachability reachabilityForInternetConnection]];
}

- (instancetype)initWithInternetReachability:(OGAReachability *)internetReachability {
    if (self = [super init]) {
        _internetReachability = internetReachability;
        _origin = OguryInternalAdsErrorOriginLoad;
    }
    return self;
}

#pragma mark - Methods
- (void)updateReachabilityStatus {
    self.internetReachability = [OGAReachability reachabilityForInternetConnection];
}

- (BOOL)checkForSequence:(OGAAdSequence *)sequence error:(OguryError **)error {
    [self updateReachabilityStatus];
    if (self.internetReachability.currentReachabilityStatus == NotReachable) {
        if (error) {
            *error = [OguryAdsError noInternetConnectionFrom:self.origin];
        }
        return NO;
    }
    return YES;
}

@end

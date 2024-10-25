//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGAIsExpiredChecker.h"
#import "OGALog.h"
#import "OguryAdError+Internal.h"

@interface OGAIsExpiredChecker ()

@property(nonatomic, strong) OGALog *log;

@end

@implementation OGAIsExpiredChecker

#pragma mark - Initialization

- (instancetype)initWithAdManager:(OGAAdManager *)adManager {
    return [self initWithAdManager:adManager log:[OGALog shared]];
}

- (instancetype)initWithAdManager:(OGAAdManager *)adManager log:(OGALog *)log {
    if (self = [super init]) {
        _adManager = adManager;
        _log = log;
    }

    return self;
}

#pragma mark - Methods

- (BOOL)checkForSequence:(OGAAdSequence *)sequence error:(OguryError *_Nullable __autoreleasing *)error {
    if ([self.adManager isExpired:sequence]) {
        if (error) {
            *error = [OguryAdError adExpired];
            [self.log logAd:OguryLogLevelError forAdConfiguration:sequence.configuration message:@" Failed to show (ad is expired)"];
        }
        return NO;
    }
    return YES;
}

@end

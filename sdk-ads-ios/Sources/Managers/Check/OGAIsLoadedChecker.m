//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import "OGAIsLoadedChecker.h"
#import "OGALog.h"
#import "OguryAdsError+Internal.h"

@interface OGAIsLoadedChecker ()

@property(nonatomic, strong) OGALog *log;

@end

@implementation OGAIsLoadedChecker

#pragma mark - init

- (instancetype)init {
    return [self init:[OGALog shared]];
}

- (instancetype)init:(OGALog *)log {
    if (self = [super init]) {
        _log = log;
    }
    return self;
}

#pragma mark - Methods

- (BOOL)checkForSequence:(OGAAdSequence *)sequence error:(OguryError **)error {
    if (![self.adManager isLoaded:sequence]) {
        if (error) {
            *error = [OguryAdsError noAdLoaded];

            [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelError
                                                 adConfiguration:sequence.configuration
                                                         logType:OguryLogTypePublisher
                                                         message:@"Failed to show (no ad loaded)"
                                                            tags:nil]];
        }
        return NO;
    }
    return YES;
}

@end

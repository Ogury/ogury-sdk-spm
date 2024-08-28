//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAIsKilledChecker.h"
#import "OGALog.h"

@interface OGAIsKilledChecker ()

@property(nonatomic, strong) OGALog *log;

@end

@implementation OGAIsKilledChecker

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
    if ([self.adManager isKilled:sequence]) {
        if (error) {
            *error = [OguryAdsError webviewTerminatedBySystem];

            [self.log logAd:OguryLogLevelError forAdConfiguration:sequence.configuration message:@"Failed to show (ad killed by the OS)"];
        }
        return NO;
    }
    return YES;
}

@end

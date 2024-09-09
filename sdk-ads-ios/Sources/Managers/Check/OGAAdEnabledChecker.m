//
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdEnabledChecker.h"
#import "OGALog.h"
#import "OGAProfigDao.h"
#import "OguryAdsError+Internal.h"

@interface OGAAdEnabledChecker ()

@property(nonatomic, strong) OGALog *log;

@end

@implementation OGAAdEnabledChecker

#pragma mark - Initialization

- (instancetype)initFrom:(OguryInternalAdsErrorOrigin)origin {
    return [self init:[OGALog shared] origin:origin];
}

- (instancetype)init:(OGALog *)log origin:(OguryInternalAdsErrorOrigin)origin {
    if (self = [super init]) {
        _log = log;
        _origin = origin;
    }
    return self;
}

- (OGAProfigDao *)profigDao {
    return [OGAProfigDao shared];
}

#pragma mark - Methods

- (BOOL)checkForSequence:(OGAAdSequence *)sequence error:(OguryError *_Nullable __autoreleasing *)error {
    if ([[self profigDao].profigFullResponse isAdsEnabled] == NO) {
        sequence.status = OGAAdSequenceStatusError;
        *error = [OguryAdsError adDisabled:[[self profigDao].profigFullResponse disablingReason] from:self.origin];
        [self.log logAd:OguryLogLevelError forAdConfiguration:sequence.configuration message:@" Failed to show (ad is disabled)"];
        return NO;
    }
    return YES;
}

@end

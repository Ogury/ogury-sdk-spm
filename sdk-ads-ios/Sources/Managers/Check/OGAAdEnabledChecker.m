//
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdEnabledChecker.h"
#import "OGALog.h"
#import "OGAProfigDao.h"
#import "OguryAdError+Internal.h"

@interface OGAAdEnabledChecker ()

@property(nonatomic, strong) OGALog *log;

@end

@implementation OGAAdEnabledChecker

#pragma mark - Initialization

- (instancetype)initFrom:(OguryAdErrorType)type {
    return [self init:[OGALog shared] type:type];
}

- (instancetype)init:(OGALog *)log type:(OguryAdErrorType)type {
    if (self = [super init]) {
        _log = log;
        _type = type;
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
        *error = [OguryAdError adDisabled:[[self profigDao].profigFullResponse disablingReason] from:self.type];
        [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelError
                                             adConfiguration:sequence.configuration
                                                     logType:OguryLogTypePublisher
                                                     message:@" Failed to show (ad is disabled)"
                                                        tags:nil]];
        return NO;
    }
    return YES;
}

@end

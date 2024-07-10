//
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import "OGAMonitoringDetails.h"

@implementation OGAMonitoringDetails
@synthesize mediation;
- (instancetype)init {
    if (self = [super init]) {
        [self startNewMonitoringSession];
        _reloaded = NO;
        _loadedSource = nil;
        _fromAdMarkUp = NO;
        mediation = nil;
    }
    return self;
}

- (void)startNewMonitoringSession {
    _sessionId = [[NSUUID UUID] UUIDString];
}

@end

//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAAdSequence.h"
#import "OGAAdSequenceCoordinator.h"
#import "OGAAdController.h"

@implementation OGAAdSequence

#pragma mark - Initialization

- (instancetype)initWithAdConfiguration:(OGAAdConfiguration *)adConfiguration {
    if (self = [super init]) {
        _status = OGAAdSequenceStatusLoading;
        _configuration = adConfiguration;
    }

    return self;
}

- (void)updateReloadStateWithSessionId:(NSString *)sessionId {
    self.configuration.monitoringDetails.sessionId = sessionId;
    self.configuration.monitoringDetails.reloaded = YES;
    for (int index = 0; index < self.coordinator.adControllers.count; index++) {
        self.coordinator.adControllers[index].ad.adConfiguration.monitoringDetails.sessionId = sessionId;
        self.coordinator.adControllers[index].ad.adConfiguration.monitoringDetails.reloaded = YES;
    }
}

- (OGAAdConfiguration *)monitoringAdConfiguration {
    return self.coordinator.adControllers.count > 0
        ? self.coordinator.adControllers[0].ad.adConfiguration
        : self.configuration;
}

@end

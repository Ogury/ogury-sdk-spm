//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import "OGAEnvironmentURLBuilder.h"
#import "OGAEnvironmentURLConstants.h"
#import "OGAEnvironmentURLLegacyBuilder.h"

@interface OGAEnvironmentURLBuilder ()

@property(nonatomic, strong) NSString *baseURL;
@property(nonatomic, strong) NSString *domain;
@property(nonatomic, strong) NSString *adSyncService;
@property(nonatomic, strong) NSString *profigService;
@property(nonatomic, strong) NSString *monitoringService;
@property(nonatomic, strong) NSString *adSyncPath;
@property(nonatomic, strong) NSString *profigPath;
@property(nonatomic, strong) NSString *monitoringPath;
@property(nonatomic, strong) NSString *monitoringVersion;
@property(nonatomic, strong) NSString *adSyncVersion;
@property(nonatomic, strong) NSString *profigVersion;
@property(nonatomic, strong) OGAEnvironmentURLLegacyBuilder *environmentURLLegacyBuilder;

@end

@implementation OGAEnvironmentURLBuilder

- (instancetype)initWith:(OGAEnvironment)environment {
    return [self initWith:environment legacyBuilder:[[OGAEnvironmentURLLegacyBuilder alloc] initWith:environment]];
}

- (instancetype)initWith:(OGAEnvironment)environment legacyBuilder:(OGAEnvironmentURLLegacyBuilder *)legacyBuilder {
    if (self = [super init]) {
        _baseURL = OGAURLPattern;
        _environmentURLLegacyBuilder = legacyBuilder;
        [self updateEnvironment:environment];
    }
    return self;
}

- (void)updateEnvironment:(OGAEnvironment)environment {
    [self setupPath];
    [self setupDomainWith:environment];
    [self setupServiceWith:environment];
    [self setupVersion];
    [self.environmentURLLegacyBuilder updateEnvironment:environment];
}

- (void)setupServiceWith:(OGAEnvironment)environment {
    _profigService = OGAServiceProfig;
    switch (environment) {
        case OGAEnvironmentProd:
            _monitoringService = OGAServiceMonitoringProd;
            _adSyncService = OGAServiceAdSyncProd;
            break;
        case OGAEnvironmentStaging:
        case OGAEnvironmentDevC:
            _monitoringService = OGAServiceMonitoringDevcStaging;
            _adSyncService = OGAServiceAdSync;
            break;
    }
}

- (void)setupPath {
    _adSyncPath = OGAPathAdSync;
    _profigPath = OGAPathProfig;
    _monitoringPath = OGAPathMonitoring;
}

- (void)setupDomainWith:(OGAEnvironment)environment {
    switch (environment) {
        case OGAEnvironmentProd:
            _domain = OGADomainProd;
            break;
        case OGAEnvironmentStaging:
            _domain = OGADomainStaging;
            break;
        case OGAEnvironmentDevC:
            _domain = OGADomainDevc;
            break;
    }
}

- (void)setupVersion {
    _adSyncVersion = OGAApiV2;
    _profigVersion = OGAApiV1;
    _monitoringVersion = OGAApiV1;
}

- (NSURL *)buildAdSyncURL {
    NSString *adSyncURLString = [NSString stringWithFormat:self.baseURL, self.adSyncService, self.domain, self.adSyncVersion, self.adSyncPath];
    NSURL *adSyncURL = [NSURL URLWithString:adSyncURLString];
    return adSyncURL;
}

- (NSURL *)buildMonitoringURL {
    NSString *monitoringURLString = [NSString stringWithFormat:self.baseURL, self.monitoringService, self.domain, self.monitoringVersion, self.monitoringPath];
    NSURL *monitoringURL = [NSURL URLWithString:monitoringURLString];
    return monitoringURL;
}

- (NSURL *)buildProfigURL {
    NSString *profigURLString = [NSString stringWithFormat:self.baseURL, self.profigService, self.domain, self.profigVersion, self.profigPath];
    NSURL *profigURL = [NSURL URLWithString:profigURLString];
    return profigURL;
}

- (NSURL *)buildLaunchURL {
    return [self.environmentURLLegacyBuilder buildLaunchURL];
}

- (NSURL *)buildPreCacheURL {
    return [self.environmentURLLegacyBuilder buildPreCacheURL];
}

- (NSURL *)buildTrackURL {
    return [self.environmentURLLegacyBuilder buildTrackURL];
}

- (NSURL *)buildAdHistoryURL {
    return [self.environmentURLLegacyBuilder buildAdHistoryURL];
}

@end

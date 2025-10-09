//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import "OGAEnvironmentURLLegacyBuilder.h"
#import "OGAEnvironmentURLConstants.h"

@interface OGAEnvironmentURLLegacyBuilder ()

@property(nonatomic, strong) NSString *baseLegacyURL;

@end

@implementation OGAEnvironmentURLLegacyBuilder

- (instancetype)initWith:(OGAEnvironment)environment {
    if (self = [super init]) {
        [self updateEnvironment:environment];
    }
    return self;
}

- (void)updateEnvironment:(OGAEnvironment)environment {
    switch (environment) {
        case OGAEnvironmentProd:
            _baseLegacyURL = OGAProductionURL;
            break;
        case OGAEnvironmentStaging:
            _baseLegacyURL = OGAStagingURL;
            break;
        case OGAEnvironmentDevC:
            _baseLegacyURL = OGADevCURL;
            break;
    }
}

#pragma mark - Building Legacy URLs
- (NSURL *)buildLaunchURL {
    return [self buildURLWithService:OGAServiceLaunch server:@"l" version:OGAApiV1];
}

- (NSURL *)buildPreCacheURL {
    return [self buildURLWithService:OGAServicePreCache server:@"pl" version:OGAApiV2];
}

- (NSURL *)buildTrackURL {
    return [self buildURLWithService:OGAServiceTrack server:@"tr" version:OGAApiV1];
}

- (NSURL *)buildAdHistoryURL {
    return [self buildURLWithService:OGAServiceAdHistory server:@"ah" version:OGAApiV1];
}

- (NSURL *)buildURLWithService:(NSString *)service
                        server:(NSString *)server
                       version:(NSString *)apiVersion {
    NSString *urlString = [NSString stringWithFormat:self.baseLegacyURL,
                                                     server,
                                                     apiVersion,
                                                     apiVersion,
                                                     service];
    return [NSURL URLWithString:urlString];
}

@end

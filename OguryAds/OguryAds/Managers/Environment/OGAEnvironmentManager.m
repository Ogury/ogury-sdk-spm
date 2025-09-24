//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAEnvironmentManager.h"
#import "OGAMonitoringDispatcher.h"
#import "OGAEnvironmentURLBuilder.h"
#import "OGALog.h"

@interface OGAEnvironmentManager ()

@property(nonatomic, assign) OGAEnvironment environment;
@property(nonatomic, strong) OGAEnvironmentURLBuilder *environmentURLBuilder;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) NSNotificationCenter *notificationCenter;

@property(nonatomic, strong, readwrite) NSURL *adSyncURL;
@property(nonatomic, strong, readwrite) NSURL *launchURL;
@property(nonatomic, strong, readwrite) NSURL *preCacheURL;
@property(nonatomic, strong, readwrite) NSURL *profigURL;
@property(nonatomic, strong, readwrite) NSURL *trackURL;
@property(nonatomic, strong, readwrite) NSURL *adHistoryURL;
@property(nonatomic, strong, readwrite) NSURL *monitoringURL;
@end

@implementation OGAEnvironmentManager

- (instancetype)init {
    return [self initWithEnvironment:[OGAEnvironmentManager getDefaultEnvironment]
               environmentURLBuilder:[[OGAEnvironmentURLBuilder alloc] initWith:[OGAEnvironmentManager getDefaultEnvironment]]
                  notificationCenter:NSNotificationCenter.defaultCenter
                                 log:[OGALog shared]];
}

- (instancetype)initWithEnvironment:(OGAEnvironment)environment
              environmentURLBuilder:(OGAEnvironmentURLBuilder *)environmentURLBuilder
                 notificationCenter:(NSNotificationCenter *)notificationCenter
                                log:(OGALog *)log {
    if (self = [super init]) {
        _environment = environment;
        _environmentURLBuilder = environmentURLBuilder;
        _log = log;
        _notificationCenter = notificationCenter;
    }
    return self;
}

+ (instancetype)shared {
    static dispatch_once_t token;
    static OGAEnvironmentManager *instance;
    dispatch_once(&token, ^{
        instance = [[OGAEnvironmentManager alloc] init];
        [instance updateURLs];
    });
    return instance;
}

+ (OGAEnvironment)getDefaultEnvironment {
    OGAEnvironment defaultEnvironment = [OGAEnvironmentManager environmentToEnum:OGA_DEFAULT_ENV];
    if (defaultEnvironment != NSNotFound) {
        return defaultEnvironment;
    }
    NSLog(@"Wrong default environment in config file, setting environment to production");
    return OGAEnvironmentProd;
}

+ (OGAEnvironment)environmentToEnum:(NSString *)environment {
    NSUInteger environmentIndex = [@[ OGAEnvironmentProdString, OGAEnvironmentStagingString, OGAEnvironmentDevcString ] indexOfObject:environment];
    if (environmentIndex != NSNotFound) {
        return (OGAEnvironment)environmentIndex;
    }
    return NSNotFound;
}

- (void)updateWith:(NSString *)environment {
    OGAEnvironment enumEnvironment = [OGAEnvironmentManager environmentToEnum:environment];
    if (enumEnvironment != NSNotFound) {
        self.environment = enumEnvironment;
    } else {
        [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                             adConfiguration:nil
                                                     logType:OguryLogTypeInternal
                                                     message:[NSString stringWithFormat:@"wrong environment submitted (%@), setting environment to production", environment]
                                                        tags:nil]];
        self.environment = OGAEnvironmentProd;
    }
    [self.environmentURLBuilder updateEnvironment:self.environment];
    [self updateURLs];
    [self.notificationCenter postNotificationName:OGAEnvironmentChanged object:nil userInfo:nil];
}

- (void)updateURLs {
    self.adSyncURL = [self.environmentURLBuilder buildAdSyncURL];
    self.launchURL = [self.environmentURLBuilder buildLaunchURL];
    self.preCacheURL = [self.environmentURLBuilder buildPreCacheURL];
    self.profigURL = [self.environmentURLBuilder buildProfigURL];
    self.trackURL = [self.environmentURLBuilder buildTrackURL];
    self.adHistoryURL = [self.environmentURLBuilder buildAdHistoryURL];
    self.monitoringURL = [self.environmentURLBuilder buildMonitoringURL];
}

@end

//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAProfigDao.h"
#import "OGAConfigurationUtils+Profig.h"
#import "OGAAdIdentifierService.h"
#import "OGAEXTScope.h"
#import "OGALog.h"

@interface OGAProfigDao ()

@property(nonatomic, strong) NSUserDefaults *userDefaults;
@property(nonatomic, strong) OGALog *log;

- (OGAProfigDao *)load;

@end

@implementation OGAProfigDao

- (instancetype)init {
    return [self initWithUserDefaults:NSUserDefaults.standardUserDefaults log:[OGALog shared]];
}

- (id)initWithUserDefaults:(NSUserDefaults *)userDefault log:(OGALog *)log {
    if (self = [super init]) {
        _userDefaults = userDefault;
        _log = log;
        [self handleMigrationIfNeeded];
        [self load];
    }
    return self;
}

- (void)handleMigrationIfNeeded {
    if ([self shouldMigrateToIdless]) {
        [self.userDefaults removeObjectForKey:PROFIG_FULL_PROFIG_RESPONSE_JSON];
        [self.userDefaults removeObjectForKey:PROFIG_LAST_PROFIG_SYNC];
        [self.userDefaults removeObjectForKey:LAST_INSTANCE_TOKEN_PROFIG_PARAM];
        [self.userDefaults synchronize];
    }
}

+ (instancetype)shared {
    static OGAProfigDao *instance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[OGAProfigDao alloc] init];
    });
    return instance;
}

- (OGAProfigDao *)load {
    self.profigFullResponse = [[OGAProfigFullResponse alloc] initWithString:[self.userDefaults stringForKey:FULL_PROFIG_RESPONSE_JSON_IDLESS] error:nil];
    self.profigParams = [OGAConfigurationUtils profigParams];
    self.profigInstanceToken = [[self.userDefaults objectForKey:LAST_INSTANCE_TOKEN_PROFIG_PARAM_IDLESS] mutableCopy];
    self.lastProfigSyncDate = [self.userDefaults objectForKey:PROFIG_LAST_PROFIG_SYNC_IDLESS];
    return self;
}

- (OGAProfigDao *)sync {
    @weakify(self)
    [[self daoQueue] addOperationWithBlock:^{
        @strongify(self)
        [self.userDefaults setObject:self.lastProfigSyncDate forKey:PROFIG_LAST_PROFIG_SYNC_IDLESS];
        NSString *jsonProfig = [self.profigFullResponse toJSONString];
        [self.userDefaults setObject:jsonProfig forKey:FULL_PROFIG_RESPONSE_JSON_IDLESS];
        [self.userDefaults setObject:self.profigInstanceToken forKey:LAST_INSTANCE_TOKEN_PROFIG_PARAM_IDLESS];
        [self.userDefaults synchronize];
    }];
    return self;
}

- (void)reset {
    [self.userDefaults removeObjectForKey:FULL_PROFIG_RESPONSE_JSON_IDLESS];
    [self.userDefaults removeObjectForKey:PROFIG_LAST_PROFIG_SYNC_IDLESS];
    [self.userDefaults removeObjectForKey:LAST_INSTANCE_TOKEN_PROFIG_PARAM_IDLESS];
    [self.userDefaults synchronize];

    self.profigFullResponse.retryInterval = @0;
}

- (NSOperationQueue *)daoQueue {
    static NSOperationQueue *queue;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 1;
    });
    return queue;
}

- (void)updateWithFullProfig:(OGAProfigFullResponse *)profig {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeInternal
                                                 message:@"[Setup] Saving configuration"
                                                    tags:nil]];

    self.profigFullResponse = profig;
    self.profigParams = [OGAConfigurationUtils profigParams];
    self.lastProfigSyncDate = [NSDate new];
    self.profigInstanceToken = [OGAAdIdentifierService getInstanceToken];

    [self sync];

    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeInternal
                                                 message:@"[Setup] Configuration saved"
                                                    tags:nil]];
}

- (BOOL)shouldMigrateToIdless {
    return [self.userDefaults stringForKey:PROFIG_FULL_PROFIG_RESPONSE_JSON] != nil;
}

@end

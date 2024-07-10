//
// Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGWMonitoringInfoStore.h"

#import "OGWMonitoringInfoSerializer.h"

NSString * const OGWMonitoringInfoStoreKey = @"OguryMonitoringInfo";

@interface OGWMonitoringInfoStore ()

@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, strong) OGWMonitoringInfoSerializer *serializer;

@end

@implementation OGWMonitoringInfoStore

#pragma mark - Initialization

- (instancetype)init {
    return [self initWithUserDefaults:NSUserDefaults.standardUserDefaults
                           serializer:[[OGWMonitoringInfoSerializer alloc] init]];
}

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults
                          serializer:(OGWMonitoringInfoSerializer *)serializer {
    if (self = [super init]) {
        _userDefaults = userDefaults;
        _serializer = serializer;
    }
    return self;
}

#pragma mark - Methods

- (BOOL)save:(OGWMonitoringInfo *)monitoringInfo error:(NSError **)error {
    NSData *data = [self.serializer serialize:monitoringInfo error:error];
    if (!data) {
        return NO;
    }
    [self.userDefaults setObject:data forKey:OGWMonitoringInfoStoreKey];
    return YES;
}

- (OGWMonitoringInfo *)load {
    NSData *data = [self.userDefaults dataForKey:OGWMonitoringInfoStoreKey];
    if (!data) {
        return nil;
    }
    return [self.serializer deserialize:data];
}

@end

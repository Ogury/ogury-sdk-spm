//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGMEventPersistanceStore.h"
#import "OGAUserDefaultsStore.h"

@interface OGMEventPersistanceStore ()

@property(nonatomic, strong) OGAUserDefaultsStore *userDefaultsStore;

@end

static NSString *const MonitoringEventPersistanceStoreUserdefaultKey = @"OGMIdLessMonitorinEvents";

@implementation OGMEventPersistanceStore

- (instancetype)init {
    return [self initWithUserDefault:[OGAUserDefaultsStore shared]];
}
- (instancetype)initWithUserDefault:(OGAUserDefaultsStore *)userDefaultsStore {
    if (self = [super init]) {
        self.userDefaultsStore = userDefaultsStore;
    }
    return self;
}

- (NSMutableArray<id<OGMEventMonitorable>> *)getEvents {
    NSData *data = [self.userDefaultsStore dataForKey:MonitoringEventPersistanceStoreUserdefaultKey];

    if (data != nil) {
        NSMutableArray<id<OGMEventMonitorable>> *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (array == nil) {
            array = [[NSMutableArray alloc] init];
        }

        return array;
    }
    return [[NSMutableArray alloc] init];
}

- (void)saveEvents:(NSArray<id<OGMEventMonitorable>> *)events {
    [self.userDefaultsStore setObject:[NSKeyedArchiver archivedDataWithRootObject:events]
                               forKey:MonitoringEventPersistanceStoreUserdefaultKey];
}

- (void)cleanEvents {
    [self.userDefaultsStore removeObjectForKey:MonitoringEventPersistanceStoreUserdefaultKey];
}

@end

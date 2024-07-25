//
// Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGWMonitoringInfo.h"

#import "NSString+OGWUtility.h"
#import "OGWMonitoringInfoFetcher.h"
#import "OGWMonitoringInfoSerializer.h"

@interface OGWMonitoringInfo ()

@property (nonatomic, strong, readwrite) NSMutableDictionary<NSString *, NSString *> *monitoringInfoMutableDict;

@end

@implementation OGWMonitoringInfo

#pragma mark - Initialization

- (instancetype)init {
    if (self = [super init]) {
        _monitoringInfoMutableDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - Properties

- (NSDictionary<NSString *, NSString *> *)monitoringInfoDict {
    return self.monitoringInfoMutableDict;
}

- (NSString *)assetKey {
    return self.monitoringInfoMutableDict[OGWMonitoringInfoFetcherAssetKeyKey];
}

#pragma mark - Methods

- (NSString * _Nullable)getValueForKey:(NSString *)key {
    return self.monitoringInfoMutableDict[key];
}

- (void)putValue:(NSString *)value key:(NSString *)key {
    if (!value) {
        [self.monitoringInfoMutableDict removeObjectForKey:key];
    } else {
        self.monitoringInfoMutableDict[key] = value;
    }
}

- (void)putAll:(OGWMonitoringInfo *)monitoringInfo {
    NSEnumerator<NSString *> *it = monitoringInfo.monitoringInfoMutableDict.keyEnumerator;
    NSString *key;
    while ((key = it.nextObject)) {
        [self putValue:monitoringInfo.monitoringInfoMutableDict[key] key:key];
    }
}

- (BOOL)containsAll:(OGWMonitoringInfo *)monitoringInfo {
    BOOL result = YES;
    NSEnumerator<NSString *> *it = monitoringInfo.monitoringInfoMutableDict.keyEnumerator;
    NSString *key;
    while (result && (key = it.nextObject)) {
        result = [NSString ogwString:monitoringInfo.monitoringInfoMutableDict[key]
                     isEqualToString:self.monitoringInfoMutableDict[key]];
    }
    return result;
}

- (NSString *)debugDescription {
    OGWMonitoringInfoSerializer *serializer = [[OGWMonitoringInfoSerializer alloc] init];
    NSData *data = [serializer serialize:self error:nil];
    if (!data) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end

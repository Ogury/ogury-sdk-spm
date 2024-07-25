//
// Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGWMonitoringInfoSerializer.h"

@implementation OGWMonitoringInfoSerializer

#pragma mark - Methods

- (NSData *)serialize:(OGWMonitoringInfo *)monitoringInfo error:(NSError **)error {
    NSDictionary<NSString *, NSString *> *dict = [monitoringInfo.monitoringInfoDict copy];
    return [NSJSONSerialization dataWithJSONObject:dict options:0 error:error];
}

- (OGWMonitoringInfo *)deserialize:(NSData *)monitoringInfoJson {
    OGWMonitoringInfo *monitoringInfo = [[OGWMonitoringInfo alloc] init];
    NSDictionary<NSString *, id> *dict = [NSJSONSerialization JSONObjectWithData:monitoringInfoJson options:0 error:nil];
    if (!dict) {
        return nil;
    }
    NSEnumerator *it = dict.keyEnumerator;
    NSString *key;
    while((key = it.nextObject)) {
        id value = dict[key];
        if ([value isKindOfClass:[NSString class]]) {
            [monitoringInfo putValue:value key:key];
        }
    }
    return monitoringInfo;
}

@end

//
// Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGWMonitoringInfoHeadersBuilder.h"

NSString * const OGWMonitoringInfoHeadersAssetKeyHeader = @"Asset-Key";
NSString * const OGWMonitoringInfoHeadersPackageNameHeader = @"Package-Name";

@interface OGWMonitoringInfoHeadersBuilder ()

@property (nonatomic, strong) NSBundle *mainBundle;

@end

@implementation OGWMonitoringInfoHeadersBuilder

#pragma mark - Initialization

- (instancetype)init {
    return [self initWithMainBundle:NSBundle.mainBundle];
}

- (instancetype)initWithMainBundle:(NSBundle *)mainBundle {
    if (self = [super init]) {
        _mainBundle = mainBundle;
    }
    return self;
}

#pragma mark - Methods

- (NSDictionary<NSString *, NSString *> *)build:(OGWMonitoringInfo *)monitoringInfo {
    NSMutableDictionary<NSString *, NSString *> *requestHeaders = [[NSMutableDictionary alloc] init];
    requestHeaders[OGWMonitoringInfoHeadersAssetKeyHeader] = monitoringInfo.assetKey;
    requestHeaders[OGWMonitoringInfoHeadersPackageNameHeader] = self.mainBundle.bundleIdentifier;
    return requestHeaders;
}

@end

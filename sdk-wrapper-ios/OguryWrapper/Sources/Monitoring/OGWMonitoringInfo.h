//
// Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGWMonitoringInfo : NSObject

#pragma mark - Properties

@property (nonatomic, copy, readonly) NSString *assetKey;

@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSString *> *monitoringInfoDict;

#pragma mark - Methods

- (NSString * _Nullable)getValueForKey:(NSString *)key;

- (void)putValue:(NSString * _Nullable)value key:(NSString *)key;

- (void)putAll:(OGWMonitoringInfo *)monitoringInfo;

- (BOOL)containsAll:(OGWMonitoringInfo *)monitoringInfo;

@end

NS_ASSUME_NONNULL_END

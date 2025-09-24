//
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAMonitoringConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAMonitorEventConfiguration : NSObject

- (instancetype)initWithEventCode:(NSString *)eventCode
                        eventName:(NSString *)eventName
                        errorType:(NSString *)errorType
                 errorDescription:(NSString *)errorDescription
                   permissionMask:(OGAAdIdMask)permissionMask;

- (instancetype)initWithEventCode:(NSString *)eventCode
                        eventName:(NSString *)eventName
                   permissionMask:(OGAAdIdMask)permissionMask;

- (NSString *)eventCode;
- (NSString *)eventName;
- (NSString *)errorType;
- (NSString *)errorDescription;
- (OGAAdIdMask)permissionMask;

@end

NS_ASSUME_NONNULL_END

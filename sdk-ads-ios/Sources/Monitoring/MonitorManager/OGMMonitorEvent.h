//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGMEventMonitorable.h"
#import "OGMEventServerMonitorable.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGMMonitorEvent : NSObject <OGMEventMonitorable, OGMEventServerMonitorable>

#pragma mark - properties

@property(nonatomic, assign) OGMDispatchType dispatchType;
@property(nonatomic, copy) NSString *logOrigin;

#pragma mark - methods

- (instancetype)initEventWithTimestamp:(NSNumber *)timestamp
                             sessionId:(NSString *)sessionId
                             eventCode:(NSString *)eventCode
                             eventName:(NSString *)eventName
                          dispatchType:(OGMDispatchType)dispatchType
                     detailsDictionary:(NSDictionary *_Nullable)detailsDictionary
                             errorType:(NSString *_Nullable)errorType
                          errorContent:(NSDictionary *_Nullable)errorContent;

@end

NS_ASSUME_NONNULL_END

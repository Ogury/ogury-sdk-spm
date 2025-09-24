//
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import "OGAAdMonitorEvent.h"

NS_ASSUME_NONNULL_BEGIN
@interface OGAAdMonitorEvent ()
- (instancetype)initWithTimestamp:(NSNumber *)timestamp
                        sessionId:(NSString *)sessionId
                        eventCode:(NSString *)eventCode
                        eventName:(NSString *)eventName
                     dispatchType:(OGMDispatchType)dispatchType
                         adUnitId:(NSString *)adUnitId
                        mediation:(OguryMediation *)mediation
                       campaignId:(NSString *_Nullable)campaignId
                       creativeId:(NSString *_Nullable)creativeId
                           extras:(NSArray *_Nullable)extras
                detailsDictionary:(NSDictionary *_Nullable)detailsDictionary
                        errorType:(NSString *_Nullable)errorType
                     errorContent:(NSDictionary *_Nullable)errorContent;
@end

NS_ASSUME_NONNULL_END

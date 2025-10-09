//
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryMediation.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAMonitoringDetails : NSObject
@property(nonatomic, strong, nonnull) NSString *sessionId;
@property(nonatomic, strong, nullable) NSString *loadedSource;
@property(nonatomic, copy, nullable) OguryMediation *mediation;
@property(nonatomic) BOOL reloaded;
@property(nonatomic) BOOL fromAdMarkUp;
- (void)startNewMonitoringSession;
@end

NS_ASSUME_NONNULL_END

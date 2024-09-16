//
//  Copyright © 2024 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryLogger.h"

NS_ASSUME_NONNULL_BEGIN

@interface OguryNSLogger : NSObject<OguryLogger>
@property (nonatomic, assign, readwrite) OguryLogLevel logLevel;
@property (nonatomic, assign, readwrite) NSArray<OguryLogType> *allowedLogTypes;
- (instancetype)initWithLevel:(OguryLogLevel)level;
@end

NS_ASSUME_NONNULL_END

//
//  Copyright © 2024 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryLogger.h"

NS_ASSUME_NONNULL_BEGIN

@interface OguryNSLogger : NSObject<OguryLogger>
@property (nonatomic, assign) OguryLogLevel logLevel;
@property (nonatomic, strong) NSArray<OguryLogType> *allowedLogTypes;
/// The formatter to use
@property (nonatomic, strong) OguryLogFormatter *logFormatter;
- (instancetype)initWithLevel:(OguryLogLevel)level;
@end

NS_ASSUME_NONNULL_END

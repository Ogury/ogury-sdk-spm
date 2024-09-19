//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <os/log.h>
#import "OguryLogMessage.h"

@protocol OguryLogFormatter;

NS_ASSUME_NONNULL_BEGIN

@protocol OguryLogger <NSObject>

#pragma mark - Properties

@property (nonatomic, assign) OguryLogLevel logLevel;
@property (nonatomic, strong) NSArray<OguryLogType> *allowedLogTypes;
/// The formatter to use
@property (nonatomic, strong) OguryLogFormatter *logFormatter;

#pragma mark - Methods

- (void)logMessage:(OguryLogMessage *)message;

@end

NS_ASSUME_NONNULL_END

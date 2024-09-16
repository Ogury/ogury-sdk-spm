//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryLogMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface OguryAbstractLogMessage : NSObject <NSCopying, OguryLogMessage>

#pragma mark - Properties

@property (nonatomic, assign, readonly) OguryLogLevel level;
@property (nonatomic, assign, readonly) OguryLogType logType;
@property (nonatomic, copy, readonly) NSString *message;
@property (nonatomic, strong, nullable) id<OguryLogFormatter> logFormatter;

#pragma mark - Initialization

- (instancetype)initWithLevel:(OguryLogLevel)level logType:(OguryLogType)logType message:(NSString *)message;
- (NSString *)formattedMessage;

@end

NS_ASSUME_NONNULL_END

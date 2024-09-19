//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryLogger.h"

typedef NS_ENUM(NSInteger, OguryLogLevel);

@class OguryLogMessage;

NS_ASSUME_NONNULL_BEGIN

@interface OguryOSLogger : NSObject<OguryLogger>

#pragma mark - Properties

@property (nonatomic, assign) OguryLogLevel logLevel;
@property (nonatomic, strong) NSArray<OguryLogType> *allowedLogTypes;
/// The formatter to use
@property (nonatomic, strong) OguryLogFormatter *logFormatter;

#pragma mark - Initialization

- (instancetype)initWithSubSystem:(nullable NSString *)subSystem category:(nullable NSString *)category NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryLogType.h"
#import <OguryCore/OguryLogLevel.h>
#import "OguryLogFormatter.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Log Tags
@interface OguryLogTag: NSObject
@property (nonatomic, retain) NSString* key;
@property (nonatomic, retain) id value;
@end

@implementation OguryLogTag
@end

#pragma mark - LogMessage protocol
@protocol OguryLogMessage

#pragma mark Properties
/// The level of the message
@property (nonatomic, assign, readonly) OguryLogLevel level;
/// The type of message (internal, request, ...)
@property (nonatomic, assign, readonly) OguryLogType logType;
/// The origin (i.e. id) of the message
@property (nonatomic, copy, readonly, nullable) NSString *origin;
/// The SDK that emitted the message
@property (nonatomic, copy, readonly) NSString *sdk;
/// The date the message was created
@property (nonatomic, copy, readonly) NSDate *messageDate;
/// The message itself
@property (nonatomic, copy, readonly) NSString *message;
/// a list of tags, rendered in the same ordre as the array
@property (nonatomic, assign, nullable) NSArray<OguryLogTag *> *tags;
/// The formatter to use
@property (nonatomic, strong) OguryLogFormatter *logFormatter;

#pragma mark Initialization
- (instancetype)initWithLevel:(OguryLogLevel)level logType:(OguryLogType)logType message:(NSString *)message;
- (instancetype)initWithLevel:(OguryLogLevel)level logType:(OguryLogType)logType message:(NSString *)message tags:(NSArray<OguryLogTag *> *_Nullable)tags;
- (NSString *)formattedMessage;

@end

NS_ASSUME_NONNULL_END

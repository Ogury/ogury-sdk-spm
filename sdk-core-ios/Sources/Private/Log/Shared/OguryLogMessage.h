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
+(instancetype)tagWithKey:(NSString *)key value:(id)value;
@end

typedef NSString *OguryLogSDK NS_TYPED_EXTENSIBLE_ENUM;

extern OguryLogSDK const OguryLogSDKCore;

#pragma mark - LogMessage protocol
@interface OguryLogMessage: NSObject

#pragma mark Properties
/// The level of the message
@property (nonatomic, assign) OguryLogLevel level;
/// The type of message (internal, request, ...)
@property (nonatomic, assign) OguryLogType logType;
/// The origin (i.e. id) of the message
@property (nonatomic, copy, nullable) NSString *origin;
/// The SDK that emitted the message
@property (nonatomic, copy) OguryLogSDK sdk;
/// The date the message was created
@property (nonatomic, assign) NSDate *messageDate;
/// The message itself
@property (nonatomic, copy) NSString *message;
/// a list of tags, rendered in the same ordre as the array
@property (nonatomic, strong) NSArray<OguryLogTag *> *tags;

#pragma mark Initialization
- (instancetype)initWithLevel:(OguryLogLevel)level
                      logType:(OguryLogType)logType
                          sdk:(OguryLogSDK _Nonnull)sdk
                      message:(NSString *)message;

- (instancetype)initWithLevel:(OguryLogLevel)level
                      logType:(OguryLogType _Nonnull)logType
                       origin:(NSString *_Nullable)origin
                          sdk:(OguryLogSDK _Nonnull)sdk
                  messageDate:(NSDate *_Nullable)messageDate
                      message:(NSString *_Nonnull)message
                         tags:(NSArray<OguryLogTag *> *_Nullable)tags;

@end

NS_ASSUME_NONNULL_END

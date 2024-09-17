//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, OguryLogDisplay) {
    OguryLogDisplayDate      = 0,
    OguryLogDisplaySDK       = 1 << 0,
    OguryLogDisplayLevel     = 1 << 1,
    OguryLogDisplayType      = 1 << 2,
    OguryLogDisplayOrigin    = 1 << 3,
    OguryLogDisplayTags      = 1 << 4
};

@protocol OguryLogMessage;

@interface OguryLogFormatter: NSObject
/// Options used to format the message
@property (nonatomic, assign, readonly) OguryLogDisplay displayOptions;
// use regular full date and time output if not provided
@property (nonatomic, assign) NSDateFormatter* dateFormatter;
- (instancetype)init;
- (instancetype)initWithOptions:(OguryLogDisplay)options dateFormatter:(NSDateFormatter *_Nullable)dateFOrmatter;

- (nullable NSString *)formatLogMessage:(id<OguryLogMessage>)logMessage;
- (nullable NSAttributedString *)formatAttributedLogMessage:(id<OguryLogMessage>)logMessage;
@end

NS_ASSUME_NONNULL_END

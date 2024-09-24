//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryLogLevel.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, OguryLogDisplay) {
    OguryLogDisplayDate      = 1 << 0,
    OguryLogDisplaySDK       = 1 << 1,
    OguryLogDisplayLevel     = 1 << 2,
    OguryLogDisplayType      = 1 << 3,
    OguryLogDisplayOrigin    = 1 << 4,
    OguryLogDisplayTags      = 1 << 5
};

@class OguryLogMessage;

@interface OguryLogFormatter: NSObject
/// Options used to format the message
@property (nonatomic, assign, readonly) OguryLogDisplay displayOptions;
// use regular full date and time output if not provided
@property (nonatomic, assign) NSDateFormatter* dateFormatter;
- (instancetype)init;
- (instancetype)initWithOptions:(OguryLogDisplay)options dateFormatter:(NSDateFormatter *_Nullable)dateFOrmatter;

- (nullable NSString *)formatLogMessage:(OguryLogMessage *)logMessage;
- (nullable NSAttributedString *)formatAttributedLogMessage:(OguryLogMessage *)logMessage;
// returns the attributed version of `str` depending on the `options` and if attributed attributes should be applied to brackets
- (NSAttributedString *_Nonnull)attributedString:(NSString *)str
                                          option:(OguryLogDisplay)option
                                 includeBrackets:(BOOL)includeBrackets
                                 originalMessage:(OguryLogMessage *)logMessage;
// returns the attributes for an option
- (NSDictionary<NSAttributedStringKey, id> *_Nullable)attributesFor:(OguryLogDisplay)option originalMessage:(OguryLogMessage *)logMessage;

NSString* levelAsString(OguryLogLevel level);
@end

NS_ASSUME_NONNULL_END

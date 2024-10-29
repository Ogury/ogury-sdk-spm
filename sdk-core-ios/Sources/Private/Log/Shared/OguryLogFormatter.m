//
//  Copyright © 2024 Ogury. All rights reserved.
//

#import "OguryLogFormatter.h"
#import "OguryLogMessage.h"
#import <UIKit/UIKit.h>

@implementation OguryLogFormatter
@synthesize dateFormatter;
@synthesize displayOptions;

- (instancetype)init {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterMediumStyle];
    [df setTimeStyle:NSDateFormatterMediumStyle];
    return [self initWithOptions:OguryLogDisplaySDK | OguryLogDisplayOrigin | OguryLogDisplayType | OguryLogDisplayLevel
            dateFormatter:df];
}

- (instancetype)initWithOptions:(OguryLogDisplay)options dateFormatter:(NSDateFormatter *_Nonnull)dateFormatter {
    if (self = [super init]) {
        displayOptions = options;
        self.dateFormatter = dateFormatter;
    }
    return self;
}

NSString* levelAsString(OguryLogLevel level) {
    switch (level) {
        case OguryLogLevelOff: return @"NONE";
        case OguryLogLevelError: return @"ERROR";
        case OguryLogLevelWarning: return @"WARNING";
        case OguryLogLevelInfo: return @"INFO";
        case OguryLogLevelDebug: return @"DEBUG";
        case OguryLogLevelAll: return @"ALL";
    }
}

- (nullable NSString *)formatLogMessage:(OguryLogMessage *)logMessage {
    return [self formatAttributedLogMessage:logMessage].string;
}

- (nullable NSAttributedString *)formatAttributedLogMessage:(OguryLogMessage *)logMessage {
   
    NSMutableAttributedString *log = [NSMutableAttributedString new];
    if (displayOptions & OguryLogDisplayDate) {
        NSString *logStr = [NSString stringWithFormat:@"[%@]", [dateFormatter stringFromDate:logMessage.messageDate]];
        [log appendAttributedString:[self attributedString:logStr
                                                    option:OguryLogDisplayDate
                                           includeBrackets:NO
                                           originalMessage:logMessage]];
    }
    if (displayOptions & OguryLogDisplaySDK) {
        NSString *logStr = [NSString stringWithFormat:@"[%@]", logMessage.sdk];
        [log appendAttributedString:[self attributedString:logStr
                                                    option:OguryLogDisplaySDK
                                           includeBrackets:YES
                                           originalMessage:logMessage]];
    }
    if (displayOptions & OguryLogDisplayLevel) {
        NSString *logStr = [NSString stringWithFormat:@"[%@]", levelAsString(logMessage.level)];
        [log appendAttributedString:[self attributedString:logStr
                                                    option:OguryLogDisplayLevel
                                           includeBrackets:NO
                                           originalMessage:logMessage]];
    }
    if (displayOptions & OguryLogDisplayType) {
        NSString *logStr = [NSString stringWithFormat:@"[%@]", logMessage.logType];
        [log appendAttributedString:[self attributedString:logStr
                                                    option:OguryLogDisplayType
                                           includeBrackets:NO
                                           originalMessage:logMessage]];
    }
    if ((displayOptions & OguryLogDisplayOrigin) && logMessage.origin != nil) {
        NSString *logStr = [NSString stringWithFormat:@"[%@]", logMessage.origin];
        [log appendAttributedString:[self attributedString:logStr
                                                    option:OguryLogDisplayDate
                                           includeBrackets:YES
                                           originalMessage:logMessage]];
    }
    if ((displayOptions & OguryLogDisplayTags) && logMessage.tags != nil) {
        NSMutableString *logStr = [@"[" mutableCopy];
        for (int index=0; index<logMessage.tags.count; index++) {
            OguryLogTag *tag = logMessage.tags[index];
            [logStr appendFormat:@"%@%@:%@", index == 0 ? @"" : @" - ", tag.key, tag.value];
        }
        [logStr appendString:@"]"];
        [log appendAttributedString:[self attributedString:logStr
                                                    option:OguryLogDisplayTags
                                           includeBrackets:NO
                                           originalMessage:logMessage]];
    }
    
    // main message
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:logMessage.message];
   [attr addAttributes:[self attributesForMessage:logMessage] range:NSMakeRange(0, attr.string.length)];
    [log appendAttributedString:attr];
    
    return log;
}

- (NSAttributedString *_Nonnull)attributedString:(NSString *)str
                                          option:(OguryLogDisplay)option
                                 includeBrackets:(BOOL)includeBrackets
                                 originalMessage:(OguryLogMessage *)logMessage {
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:str];
    NSRange range = includeBrackets ? NSMakeRange(0, str.length) : NSMakeRange(1, str.length-2);
    [attr addAttributes:[self attributesFor:option originalMessage:logMessage] range:range];
    return attr;
}

- (NSDictionary<NSAttributedStringKey, id> *_Nullable)attributesFor:(OguryLogDisplay)option originalMessage:(OguryLogMessage *)logMessage {
    switch (option) {
        case OguryLogDisplayDate:
            return @{ NSFontAttributeName : [UIFont systemFontOfSize:10] };
            break;
            
        case OguryLogDisplaySDK:
            return @{ NSFontAttributeName : [UIFont boldSystemFontOfSize:14.0] };
            break;
            
        case OguryLogDisplayLevel:
            return @{ NSFontAttributeName : [UIFont italicSystemFontOfSize:14.0] };
            break;
            
        case OguryLogDisplayType:
            return @{ NSFontAttributeName : [UIFont italicSystemFontOfSize:14.0] };
            break;
            
        case OguryLogDisplayOrigin:
            return @{ NSFontAttributeName : [UIFont systemFontOfSize:12] };
            break;
            
        case OguryLogDisplayTags:
            return @{ NSFontAttributeName : [UIFont systemFontOfSize:12]};
            break;
    }
}

- (NSDictionary<NSAttributedStringKey, id> *_Nullable)attributesForMessage:(OguryLogMessage *)logMessage  {
    return @{ NSFontAttributeName : [UIFont systemFontOfSize:12] };
}

- (void)add:(OguryLogDisplay)option {
    if (!(displayOptions & option)) {
        displayOptions |= option;
    }
}

- (void)remove:(OguryLogDisplay)option {
    if (displayOptions & option) {
        displayOptions &= ~option;
    }
}

@end

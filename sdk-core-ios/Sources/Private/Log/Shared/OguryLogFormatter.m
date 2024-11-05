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
    BOOL bracketsAdded = NO;
    if (displayOptions & OguryLogDisplayDate) {
        NSString *logStr = [NSString stringWithFormat:@"%@ : ", [dateFormatter stringFromDate:logMessage.messageDate]];
        [log appendAttributedString:[self attributedString:logStr
                                                    option:OguryLogDisplayDate
                                           originalMessage:logMessage]];
    }
    if (displayOptions & OguryLogDisplaySDK) {
        bracketsAdded = YES;
        NSString *logStr = [NSString stringWithFormat:@"[%@", logMessage.sdk];
        [log appendAttributedString:[self attributedString:logStr
                                                    option:OguryLogDisplaySDK
                                           originalMessage:logMessage]];
    }
    if (displayOptions & OguryLogDisplayLevel) {
        NSString *logStr = [NSString stringWithFormat:@"%@%@", bracketsAdded ? @"-" : @"[", levelAsString(logMessage.level)];
        bracketsAdded = YES;
        [log appendAttributedString:[self attributedString:logStr
                                                    option:OguryLogDisplayLevel
                                           originalMessage:logMessage]];
    }
    if (displayOptions & OguryLogDisplayType) {
        NSString *logStr = [NSString stringWithFormat:@"%@%@", bracketsAdded ? @"-" : @"[", logMessage.logType];
        bracketsAdded = YES;
        [log appendAttributedString:[self attributedString:logStr
                                                    option:OguryLogDisplayType
                                           originalMessage:logMessage]];
    }
    if ((displayOptions & OguryLogDisplayOrigin) && logMessage.origin != nil) {
        NSString *logStr = [NSString stringWithFormat:@"%@%@", bracketsAdded ? @"-" : @"[", logMessage.origin];
        bracketsAdded = YES;
        [log appendAttributedString:[self attributedString:logStr
                                                    option:OguryLogDisplayDate
                                           originalMessage:logMessage]];
    }
    if (bracketsAdded) {
        [log appendAttributedString:[self attributedString:@"]"
                                                    option:OguryLogDisplaySDK
                                           originalMessage:logMessage]];
    }
    if ((displayOptions & OguryLogDisplayTags) && logMessage.tags.count > 0) {
        NSMutableString *logStr = [@"\n[" mutableCopy];
        for (int index=0; index<logMessage.tags.count; index++) {
            OguryLogTag *tag = logMessage.tags[index];
            [logStr appendFormat:@"%@%@:%@", index == 0 ? @"" : @" - ", tag.key, tag.value];
        }
        [logStr appendString:@"]\n"];
        [log appendAttributedString:[self attributedString:logStr
                                                    option:OguryLogDisplayTags
                                           originalMessage:logMessage]];
    } else if (log.string.length > 0) {
        [log appendAttributedString:[self attributedString:@" - "
                                                    option:OguryLogDisplayDate
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
                                 originalMessage:(OguryLogMessage *)logMessage {
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:str];
    [attr addAttributes:[self attributesFor:option originalMessage:logMessage] range:NSMakeRange(0, str.length)];
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

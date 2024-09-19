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
    return [self initWithOptions:OguryLogDisplaySDK | OguryLogDisplayOrigin | OguryLogDisplayType | OguryLogDisplayLevel
            dateFormatter:[[NSDateFormatter alloc] init]];
}

- (instancetype)initWithOptions:(OguryLogDisplay)options dateFormatter:(NSDateFormatter *_Nullable)dateFOrmatter {
    if (self = [super init]) {
        
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
                                           includeBrackets:NO]];
    }
    if (displayOptions & OguryLogDisplaySDK) {
        [log appendAttributedString:[self attributedString:logMessage.sdk
                                                    option:OguryLogDisplaySDK
                                           includeBrackets:YES]];
    }
    if (displayOptions & OguryLogDisplayLevel) {
        NSString *logStr = [NSString stringWithFormat:@"[%@]", levelAsString(logMessage.level)];
        [log appendAttributedString:[self attributedString:logStr
                                                    option:OguryLogDisplayLevel
                                           includeBrackets:NO]];
    }
    if (displayOptions & OguryLogDisplayType) {
        NSString *logStr = [NSString stringWithFormat:@"[%@]", [self loggableType:logMessage.logType]];
        [log appendAttributedString:[self attributedString:logStr
                                                    option:OguryLogDisplayType
                                           includeBrackets:NO]];
    }
    if ((displayOptions & OguryLogDisplayOrigin) && logMessage.origin != nil) {
        [log appendAttributedString:[self attributedString:logMessage.origin
                                                    option:OguryLogDisplayDate
                                           includeBrackets:YES]];
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
                                           includeBrackets:NO]];
    }
    return log;
}

- (NSAttributedString *_Nonnull)attributedString:(NSString *)str
                                          option:(OguryLogDisplay)option
                                 includeBrackets:(BOOL)includeBrackets {
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:str];
    NSRange range = includeBrackets ? NSMakeRange(0, str.length) : NSMakeRange(1, str.length-2);
    [attr addAttributes:[self attributesFor:option] range:range];
    return attr;
}

- (NSString *_Nullable)loggableType:(OguryLogType)logType {
    if ([logType isEqualToString:OguryLogTypeAll]) {
        return @"All";
    } else if ([logType isEqualToString:OguryLogTypeInternal]) {
        return @"Internal";
    } else if ([logType isEqualToString:OguryLogTypeRequests]) {
        return @"Request";
    } else if ([logType isEqualToString:OguryLogTypePublisher]) {
        return @"Publisher";
    }
    return nil;
}

- (NSDictionary<NSAttributedStringKey, id> *_Nullable)attributesFor:(OguryLogDisplay)option {
    switch (option) {
        case OguryLogDisplayDate:
            return @{ NSFontAttributeName : [UIFont systemFontOfSize:12] };
            break;
            
        case OguryLogDisplaySDK:
            return @{ NSFontAttributeName : [UIFont boldSystemFontOfSize:16.0] };
            break;
            
        case OguryLogDisplayLevel:
            return @{ NSFontAttributeName : [UIFont italicSystemFontOfSize:16.0] };
            break;
            
        case OguryLogDisplayType:
            return @{ NSFontAttributeName : [UIFont italicSystemFontOfSize:16.0] };
            break;
            
        case OguryLogDisplayOrigin:
            return @{ NSFontAttributeName : [UIFont systemFontOfSize:12] };
            break;
            
        case OguryLogDisplayTags:
            return nil;
            break;
    }
}

@end

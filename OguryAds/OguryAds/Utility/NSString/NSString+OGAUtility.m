//
// Copyright (c) 2020 Ogury Ltd. All rights reserved.
//

#import "NSString+OGAUtility.h"

@implementation NSString (OGAUtility)

+ (BOOL)ogaString:(NSString *_Nullable)string isEqualToString:(NSString *_Nullable)anotherString {
    if (!string && !anotherString) {
        return YES;
    } else if (string && [string isEqualToString:anotherString]) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)ogaIsNilOrEmpty:(NSString *)string {
    return (!string || string.length == 0);
}

@end

//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "NSString+OGWUtility.h"

@implementation NSString (OGWUtility)

+ (BOOL)ogwString:(NSString *)string isEqualToString:(NSString *)anotherString {
    if (!string && !anotherString) {
        return YES;
    } else if (string && [string isEqualToString:anotherString]) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)ogwIsNilOrEmpty:(NSString *)string {
    return (!string || string.length == 0);
}

@end

//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "UIColor+OGAString.h"

@implementation UIColor (OGAString)

+ (UIColor *_Nonnull)colorFromString:(NSString *_Nullable)stringValue {
    if (![stringValue hasPrefix:@"#"]) {
        return [UIColor blackColor];
    }
    unsigned int hexint = [self intFromHexString:stringValue];
    switch (stringValue.length) {
        case 4:
            return [UIColor colorWithRed:((CGFloat)((hexint & 0xF00) >> 8) * 17) / 255 green:((CGFloat)((hexint & 0xF0) >> 4) * 17) / 255 blue:((CGFloat)(hexint & 0xF) * 17) / 255 alpha:1];
        case 7:
            return [UIColor colorWithRed:((CGFloat)((hexint & 0xFF0000) >> 16)) / 255 green:((CGFloat)((hexint & 0xFF00) >> 8)) / 255 blue:((CGFloat)(hexint & 0xFF)) / 255 alpha:1];
        case 9:
            return [UIColor colorWithRed:((CGFloat)((hexint & 0xFF0000) >> 16)) / 255 green:((CGFloat)((hexint & 0xFF00) >> 8)) / 255 blue:((CGFloat)(hexint & 0xFF)) / 255 alpha:((CGFloat)((hexint & 0xFF000000) >> 24)) / 255];
        default:
            return [UIColor blackColor];
    }
}

+ (unsigned int)intFromHexString:(NSString *)hexString {
    unsigned int hexInt = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    [scanner scanHexInt:&hexInt];
    return hexInt;
}

@end

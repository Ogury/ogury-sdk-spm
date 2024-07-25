//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "NSString+OGABase64.h"

@implementation NSString (OGABase64)

- (NSString *)ogaEncodeStringTo64 {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:kNilOptions];
}

@end

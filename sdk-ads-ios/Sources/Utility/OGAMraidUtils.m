//
//  Copyright © 2019 Ogury. All rights reserved.
//

#import "OGAMraidUtils.h"
#import "OGAAd.h"

#warning FIXME Do not forget to change this on a category

@implementation OGAMraidUtils

+ (NSString *)getMraidStringFromState:(OGAMRAIDState)mraidState {
    switch (mraidState) {
        case OGAMRAIDStateLoading:
            return @"loading";
        case OGAMRAIDStateDefault:
            return @"default";
        case OGAMRAIDStateHidden:
            return @"hidden";
        case OGAMRAIDStateExpanded:
            return @"expanded";
        case OGAMRAIDStateResized:
            return @"resized";
        default:
            return @"";
    }
}

+ (NSString *)closeButtonBase64 {
    return @"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";
}

+ (UIImage *_Nullable)decodeBase64ToImage:(NSString *)strEncodeData {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data ?: [NSData data]];
}
@end

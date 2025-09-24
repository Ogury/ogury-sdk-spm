//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import "OGAAd+ImpressionSource.h"

static NSString *const OGAImpressionSourceFormat = @"format";
static NSString *const OGAImpressionSourceSDK = @"sdk";

@implementation OGAAd (ImpressionSource)

- (BOOL)isImpressionSourceFormat {
    // should be changed to equal "format" later we keep it like this as the server side is not implemented yet on the Ad Object
    return ![self.impressionSource isEqualToString:OGAImpressionSourceSDK];
}

- (BOOL)isImpressionSourceSDK {
    return [self.impressionSource isEqualToString:OGAImpressionSourceSDK];
}

- (NSString *)getRawImpressionSource {
    // avoid nil
    return [self.impressionSource isEqualToString:OGAImpressionSourceSDK] ? OGAImpressionSourceSDK : OGAImpressionSourceFormat;
}

@end

//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAAdIdentifierService.h"

#import <UIKit/UIKit.h>
#import <OguryCore/OGCInternal.h>

#import "OGAAssetKeyManager.h"

@implementation OGAAdIdentifierService

+ (NSString *)getAdIdentifier {
    return [[OGCInternal shared] getAdIdentifier];
}

+ (NSString *)getVendorIdentifier {
    return [[OGCInternal shared] getVendorIdentifier];
}

+ (NSString *)getInstanceToken {
    return [[OGCInternal shared] getInstanceToken];
}

+ (NSString *)getConsentToken {
    return [[OGCInternal shared] getConsentToken];
}

+ (BOOL)isAdOptin {
    return [[OGCInternal shared] isAdOptin];
}

+ (BOOL)isFakeAaid {
    return ![OGAAdIdentifierService isAdOptin];
}

+ (void)updateInstanceToken {
    [[OGCInternal shared] updateInstanceToken];
}

+ (NSString *)getUserAgent {
    NSString *systemVersion = UIDevice.currentDevice.systemVersion;
    return [NSString stringWithFormat:@"%@/%@/%@", OGA_SDK_VERSION, OGAAssetKeyManager.shared.assetKey, systemVersion];
}

@end

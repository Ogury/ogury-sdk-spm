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
// GPP
+ (NSString *_Nullable)gppConsentString {
    return [[OGCInternal shared] gppConsentString];
}

+ (NSString *_Nullable)gppSID {
    return [[OGCInternal shared] gppSID];
}

+ (NSString *_Nullable)tcfConsentString {
    return [[OGCInternal shared] tcfConsentString];
}

+ (NSDictionary<NSString *, id> *)privacyDatas {
    // return [[OGCInternal shared] retrieveDataPrivacy];
    return @{};
}

@end

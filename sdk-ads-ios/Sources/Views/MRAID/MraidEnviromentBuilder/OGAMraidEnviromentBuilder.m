//
//  Copyright © 2018 Ogury. All rights reserved.
//

#import "OGAMraidEnviromentBuilder.h"
#import "OGAAdUnit.h"

@implementation OGAMraidEnviromentBuilder

#pragma mark - Constants

static NSString *const OGARewardedAd = @"optin_video";

#pragma mark - Methods

+ (NSString *)buildMraidEnvironmentRewardedAd:(OGAAdUnit *)adUnit {
    return [NSString stringWithFormat:@"window.MRAID_ENV =  { version: '%@', sdk: 'Presage', sdkVersion: '%@',adUnit: { type: '%@', reward : { name: '%@', value: '%@', launch: '%@'}}};",
                                      OGA_SDK_VERSION,
                                      OGA_SDK_VERSION,
                                      adUnit.type,
                                      adUnit.rewardName,
                                      adUnit.rewardValue,
                                      adUnit.rewardLaunch];
}

+ (NSString *)buildMraidEnviromentInterstitial {
    return [NSString stringWithFormat:@"window.MRAID_ENV =  { version: '%@', sdk: 'Presage', sdkVersion: '%@'};", OGA_SDK_VERSION, OGA_SDK_VERSION];
}

+ (NSString *)generateMraidEnviroment:(OGAAdUnit *)adUnit {
    if (adUnit && [adUnit.type isEqualToString:OGARewardedAd]) {
        return [self buildMraidEnvironmentRewardedAd:adUnit];
    } else {
        return [self buildMraidEnviromentInterstitial];
    }
}
@end

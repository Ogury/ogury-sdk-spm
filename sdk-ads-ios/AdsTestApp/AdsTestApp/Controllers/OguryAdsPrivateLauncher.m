//
//  OguryAdsPrivateLauncher.m
//  AdsTestApp
//
//  Created by Jerome TONNELIER on 09/10/2024.
//

#import "OguryAdsPrivateLauncher.h"
#import <OguryAds/OGAInternal.h>

@implementation OguryAdsPrivateLauncher

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)startWith:(NSString *)assetKey {
    [[OGAInternal shared] startWith:assetKey
                  completionHandler:^(BOOL success, OguryError *_Nullable error){

                  }];
}

- (void)changeEnvironmentTo:(NSString *)environment {
    [[OGAInternal shared] performSelector:@selector(changeServerEnvironment:) withObject:environment];
}

- (NSString *)sdkVersion {
    return [[OGAInternal shared] getVersion];
}

@end

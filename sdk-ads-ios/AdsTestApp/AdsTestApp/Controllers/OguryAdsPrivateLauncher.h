//
//  OguryAdsPrivateLauncher.h
//  AdsTestApp
//
//  Created by Jerome TONNELIER on 09/10/2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OguryAdsPrivateLauncher : NSObject
- (instancetype)init;
- (void)startWith:(NSString *)assetKey;
- (void)changeEnvironmentTo:(NSString *)environment;
- (NSString *)sdkVersion;
@end

NS_ASSUME_NONNULL_END

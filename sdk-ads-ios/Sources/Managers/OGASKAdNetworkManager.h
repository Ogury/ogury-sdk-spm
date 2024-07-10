//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OGAAd;

NS_ASSUME_NONNULL_BEGIN

/**
 * Managers in charge of creation skadnetwork ads.
 *
 */
@interface OGASKAdNetworkManager : NSObject

#pragma mark - Initialization

+ (instancetype)shared;

#pragma mark - Methods

- (void)startImpressionWithAd:(OGAAd *)ad;

- (void)stopImpressionWithAd:(OGAAd *)ad;

@end

NS_ASSUME_NONNULL_END

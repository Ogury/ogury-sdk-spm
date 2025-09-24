//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OGAAd;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief The `OGAAdExpirationManager` provides the methods for sending the expiration tracker event for an `OGAAd`.
 */
@interface OGAAdExpirationManager : NSObject

#pragma mark - Constants

+ (instancetype)shared;

#pragma mark - Initialization

- (instancetype)init NS_UNAVAILABLE;

#pragma mark - Methods

/**
 * @brief Sends the expiration tracker event for the supplied OGAAd.
 *
 * @param ad The OGAAd to send the expiration tracker event for.
 *
 * @remark If the expiration tracker event has already been sent for the Ad, it will not be sent again.
 */
- (void)sendExpirationTrackerEventForAd:(OGAAd *)ad;

@end

NS_ASSUME_NONNULL_END

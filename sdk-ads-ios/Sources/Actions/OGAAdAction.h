//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryAdError.h"

@class OGAAdContainer;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Represents any action that can be performed against an ad container.
 *
 * @discussion Supported actions:
 *
 * - close: showNextAd: true/false
 *
 * - forceClose
 *
 * - expand
 *
 * - setResizeProperties: allowOffscreen, height, offsetX, width, offsetY
 */
@protocol OGAAdAction <NSObject>

#pragma mark - Properties

@property(nonatomic, strong) NSString *name;

#pragma mark - Methods

/**
 Perform the action itself against the supplied ad container.

 @param adContainer The ad container to perform the action against.
 @param error An error that will be populated if something went wrong while performing the action.
 */
- (BOOL)performAction:(OGAAdContainer *)adContainer error:(OguryAdError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END

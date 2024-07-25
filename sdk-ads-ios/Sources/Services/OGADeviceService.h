//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGADeviceService : NSObject

#pragma mark - Methods

/**
 * Returns the current interface orientation.
 *
 * Uses the UIWindowScene's active window to retrieve it, if it is not available, fallback to the statusBarOrientation.
 *
 * If both of those are not available, switch to the deprecated UIDevice's orientation.
 *
 * @returns A NSString matching the current interface orientation of either the UIApplication or the UIDevice
 */
- (NSString *)interfaceOrientation;

@end

NS_ASSUME_NONNULL_END

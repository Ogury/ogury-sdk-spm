//
// Copyright (c) 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OguryCore/OguryError.h>

#import "OGAAd.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^OGAPrepareAdContentsCompletionHandler)(OguryError *_Nullable error);

@interface OGAAdContentPreCacheManager : NSObject

/**
 * Prepare the provided ads in order for them to be cached in a webview:
 * - Create local identifier.
 * - Download ad contents that required to be cached on local storage (ex. mraid script).
 *
 * @param ads Ads to prepare content for.
 * @param completionHandler Completion handler called when the ad contents is prepared.
 */
- (void)prepareAdContents:(NSArray<OGAAd *> *)ads completionHandler:(OGAPrepareAdContentsCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END

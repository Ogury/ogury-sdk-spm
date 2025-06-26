//
//  OGABannerAdSize.h
//  OguryAdsSDK
//
//  Created by nicolas perret on 03/06/2025.
//  Copyright © 2025 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAJSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGABannerAdSize : OGAJSONModel

#pragma mark - Properties

@property(readwrite) NSNumber *width;
@property(readwrite) NSNumber *height;

- (CGSize)size;

@end

NS_ASSUME_NONNULL_END

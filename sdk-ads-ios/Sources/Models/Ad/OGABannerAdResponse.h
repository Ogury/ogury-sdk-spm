//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAJSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGABannerAdResponse : OGAJSONModel

#pragma mark - Properties

@property(nonatomic, strong) NSString *autoRefreshRate;
@property(nonatomic, strong) NSNumber *fullWidth;
@property(nonatomic, strong) NSNumber *autoRefresh;
@property(nonatomic, assign, readonly) BOOL isFullScreen;

@end

NS_ASSUME_NONNULL_END

//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OguryAdsError.h"
#import "OGARewardItem.h"
#import <UIKit/UIKit.h>

@protocol OGAAdDelegate <NSObject>

- (void)loaded;
- (void)clicked;
- (void)adImpression;
- (void)closed;
- (void)failedWithError:(OguryError *)error;

@optional
- (void)rewarded:(OGARewardItem *)item;
- (UIViewController *)bannerViewController;

@end

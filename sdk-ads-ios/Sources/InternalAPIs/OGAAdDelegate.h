//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OguryAdError.h"
#import "OguryReward.h"
#import <UIKit/UIKit.h>

@protocol OGAAdDelegate <NSObject>

- (void)loaded;
- (void)clicked;
- (void)adImpression;
- (void)closed;
- (void)failedWithError:(OguryAdError *)error;

@optional
- (void)rewarded:(OguryReward *)item;
- (UIViewController *)bannerViewController;

@end

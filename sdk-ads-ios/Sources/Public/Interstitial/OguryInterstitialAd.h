//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OguryInterstitialAdDelegate.h"
#import "OguryMediation.h"

NS_ASSUME_NONNULL_BEGIN

@interface OguryInterstitialAd : NSObject

@property(nonatomic, strong, readonly) NSString *adUnitId;
@property(nonatomic, weak, nullable) id<OguryInterstitialAdDelegate> delegate;
@property(nonatomic, assign, readonly) BOOL isLoaded;

- (instancetype)initWithAdUnitId:(NSString *)adUnitId;
- (instancetype)initWithAdUnitId:(NSString *)adUnitId mediation:(OguryMediation *_Nonnull)mediation;

- (void)load;

- (void)loadWithAdMarkup:(NSString *)adMarkup;

- (void)showAdInViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END

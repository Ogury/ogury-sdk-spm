//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OGAAdInternalAPI.h"
#import "OGADelegateDispatcher.h"
#import "OguryMediation.h"

@class OGAAdManager;

NS_ASSUME_NONNULL_BEGIN

@interface OGAInterstitialAdInternalAPI : NSObject <OGAAdInternalAPI>

#pragma mark - properties

@property(nonatomic, strong, readonly) OGADelegateDispatcher *delegateDispatcher;

#pragma mark - Initialization

- (instancetype)initWithAdUnitId:(NSString *)adUnitId
              delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher
                       mediation:(OguryMediation *_Nullable)mediation;

#pragma mark - Methods

- (void)load;

- (void)loadWithAdMarkup:(NSString *)adMarkup;

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId;

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId creativeId:(NSString *_Nullable)creativeId;

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId creativeId:(NSString *_Nullable)creativeId dspCreativeId:(NSString *_Nullable)dspCreativeId dspRegion:(NSString *_Nullable)dspRegion;

- (BOOL)isLoaded;

- (void)showAdInViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END

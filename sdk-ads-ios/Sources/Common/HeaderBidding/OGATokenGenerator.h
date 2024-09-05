//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryTokenService.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGATokenGenerator : NSObject

- (void)generateBidderToken:(HeaderBiddingCompletionBlock)completion;

- (void)generateBidderTokenWithCampaignId:(NSString *)campaignId
                               completion:(HeaderBiddingCompletionBlock)completion;

- (void)generateBidderTokenWithCampaignId:(NSString *)campaignId
                               creativeId:(NSString *_Nullable)creativeId
                               completion:(HeaderBiddingCompletionBlock)completion;

- (void)generateBidderTokenWithCampaignId:(NSString *_Nullable)campaignId
                               creativeId:(NSString *_Nullable)creativeId
                            dspCreativeId:(NSString *_Nullable)dspCreativeId
                                dspRegion:(NSString *_Nullable)dspRegion
                               completion:(HeaderBiddingCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END

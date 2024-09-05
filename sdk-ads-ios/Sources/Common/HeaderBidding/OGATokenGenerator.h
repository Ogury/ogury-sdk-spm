//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryTokenService.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGATokenGenerator : NSObject

- (void)bidderToken:(HeaderBiddingCompletionBlock)completion;

- (void)bidderTokenWithCampaignId:(NSString *)campaignId
                       completion:(HeaderBiddingCompletionBlock)completion;

- (void)bidderTokenWithCampaignId:(NSString *)campaignId
                       creativeId:(NSString *_Nullable)creativeId
                       completion:(HeaderBiddingCompletionBlock)completion;

- (void)bidderTokenWithCampaignId:(NSString *_Nullable)campaignId
                       creativeId:(NSString *_Nullable)creativeId
                    dspCreativeId:(NSString *_Nullable)dspCreativeId
                        dspRegion:(NSString *_Nullable)dspRegion
                       completion:(HeaderBiddingCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END

//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryTokenService.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGATokenGenerator : NSObject

- (void)bidToken:(BidTokenCompletionBlock)completion;

- (void)bidTokenWithCampaignId:(NSString *)campaignId
                    completion:(BidTokenCompletionBlock)completion;

- (void)bidTokenWithCampaignId:(NSString *)campaignId
                    creativeId:(NSString *_Nullable)creativeId
                    completion:(BidTokenCompletionBlock)completion;

- (void)bidTokenWithCampaignId:(NSString *_Nullable)campaignId
                    creativeId:(NSString *_Nullable)creativeId
                 dspCreativeId:(NSString *_Nullable)dspCreativeId
                     dspRegion:(NSString *_Nullable)dspRegion
                    completion:(BidTokenCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END

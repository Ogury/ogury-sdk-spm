//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OguryBidTokenService.h"
#import "OGATokenGenerator.h"

@implementation OguryBidTokenService

+ (void)bidToken:(BidTokenCompletionBlock)completion {
    OGATokenGenerator *tokenGenerator = [[OGATokenGenerator alloc] init];
    [self bidTokenFrom:tokenGenerator completion:completion];
}

+ (void)bidTokenFrom:(OGATokenGenerator *)tokenGenerator completion:(BidTokenCompletionBlock)completion {
    [tokenGenerator bidToken:completion];
}

+ (void)bidTokenWithCampaignId:(NSString *)campaignId
                    completion:(BidTokenCompletionBlock)completion {
    [self bidTokenWithCampaignId:campaignId creativeId:nil completion:completion];
}

+ (void)bidTokenWithCampaignId:(NSString *)campaignId
                    creativeId:(NSString *_Nullable)creativeId
                    completion:(BidTokenCompletionBlock)completion {
    [self bidTokenWithCampaignId:campaignId
                      creativeId:creativeId
                   dspCreativeId:nil
                       dspRegion:nil
                      completion:completion];
}

+ (void)bidTokenWithCampaignId:(NSString *)campaignId
                    creativeId:(NSString *_Nullable)creativeId
                 dspCreativeId:(NSString *_Nullable)dspCreativeId
                     dspRegion:(NSString *_Nullable)dspRegion
                    completion:(BidTokenCompletionBlock)completion {
    OGATokenGenerator *tokenGenerator = [[OGATokenGenerator alloc] init];
    [self bidTokenFrom:tokenGenerator
            campaignId:campaignId
            creativeId:creativeId
         dspCreativeId:dspCreativeId
             dspRegion:dspRegion
            completion:completion];
}

+ (void)bidTokenFrom:(OGATokenGenerator *)tokenGenerator
          campaignId:(NSString *)campaignId
          creativeId:(NSString *_Nullable)creativeId
       dspCreativeId:(NSString *_Nullable)dspCreativeId
           dspRegion:(NSString *_Nullable)dspRegion
          completion:(BidTokenCompletionBlock)completion {
    [tokenGenerator bidTokenWithCampaignId:campaignId
                                creativeId:creativeId
                             dspCreativeId:dspCreativeId
                                 dspRegion:dspRegion
                                completion:completion];
}

@end

//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OguryTokenService.h"
#import "OGATokenGenerator.h"

@implementation OguryTokenService

+ (void)bidderToken:(HeaderBiddingCompletionBlock)completion {
    OGATokenGenerator *tokenGenerator = [[OGATokenGenerator alloc] init];
    [self bidderTokenFrom:tokenGenerator completion:completion];
}

+ (void)bidderTokenFrom:(OGATokenGenerator *)tokenGenerator completion:(HeaderBiddingCompletionBlock)completion {
    [tokenGenerator bidderToken:completion];
}

+ (void)bidderTokenWithCampaignId:(NSString *)campaignId
                       completion:(HeaderBiddingCompletionBlock)completion {
    [self bidderTokenWithCampaignId:campaignId creativeId:nil completion:completion];
}

+ (void)bidderTokenWithCampaignId:(NSString *)campaignId
                       creativeId:(NSString *_Nullable)creativeId
                       completion:(HeaderBiddingCompletionBlock)completion {
    [self bidderTokenWithCampaignId:campaignId
                         creativeId:creativeId
                      dspCreativeId:nil
                          dspRegion:nil
                         completion:completion];
}

+ (void)bidderTokenWithCampaignId:(NSString *)campaignId
                       creativeId:(NSString *_Nullable)creativeId
                    dspCreativeId:(NSString *_Nullable)dspCreativeId
                        dspRegion:(NSString *_Nullable)dspRegion
                       completion:(HeaderBiddingCompletionBlock)completion {
    OGATokenGenerator *tokenGenerator = [[OGATokenGenerator alloc] init];
    [self bidderTokenFrom:tokenGenerator
               campaignId:campaignId
               creativeId:creativeId
            dspCreativeId:dspCreativeId
                dspRegion:dspRegion
               completion:completion];
}

+ (void)bidderTokenFrom:(OGATokenGenerator *)tokenGenerator
             campaignId:(NSString *)campaignId
             creativeId:(NSString *_Nullable)creativeId
          dspCreativeId:(NSString *_Nullable)dspCreativeId
              dspRegion:(NSString *_Nullable)dspRegion
             completion:(HeaderBiddingCompletionBlock)completion {
    [tokenGenerator bidderTokenWithCampaignId:campaignId
                                   creativeId:creativeId
                                dspCreativeId:dspCreativeId
                                    dspRegion:dspRegion
                                   completion:completion];
}

@end

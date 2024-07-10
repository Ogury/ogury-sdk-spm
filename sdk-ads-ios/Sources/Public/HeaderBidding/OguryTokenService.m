//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OguryTokenService.h"
#import "OGATokenGenerator.h"

@implementation OguryTokenService

+ (NSString *_Nullable)getBidderToken {
    OGATokenGenerator *tokenGenerator = [[OGATokenGenerator alloc] init];
    return [OguryTokenService getBidderTokenFrom:tokenGenerator];
}

+ (NSString *_Nullable)getBidderTokenFrom:(OGATokenGenerator *)tokenGenerator {
    return [tokenGenerator generateBidderToken];
}

+ (NSString *_Nullable)getBidderTokenWithCampaignId:(NSString *)campaignId {
    return [OguryTokenService getBidderTokenWithCampaignId:campaignId creativeId:nil];
}

+ (NSString *_Nullable)getBidderTokenWithCampaignId:(NSString *)campaignId creativeId:(NSString *_Nullable)creativeId {
    OGATokenGenerator *tokenGenerator = [[OGATokenGenerator alloc] init];
    return [OguryTokenService getBidderTokenFrom:tokenGenerator campaignId:campaignId creativeId:creativeId dspCreativeId:nil dspRegion:nil];
}

+ (NSString *_Nullable)getBidderTokenWithCampaignId:(NSString *)campaignId creativeId:(NSString *_Nullable)creativeId dspCreativeId:(NSString *_Nullable)dspCreativeId dspRegion:(NSString *_Nullable)dspRegion {
    OGATokenGenerator *tokenGenerator = [[OGATokenGenerator alloc] init];
    return [OguryTokenService getBidderTokenFrom:tokenGenerator campaignId:campaignId creativeId:creativeId dspCreativeId:dspCreativeId dspRegion:dspRegion];
}

+ (NSString *_Nullable)getBidderTokenFrom:(OGATokenGenerator *)tokenGenerator campaignId:(NSString *)campaignId creativeId:(NSString *_Nullable)creativeId dspCreativeId:(NSString *_Nullable)dspCreativeId dspRegion:(NSString *_Nullable)dspRegion {
    return [tokenGenerator generateBidderToken:campaignId creativeId:creativeId dspCreativeId:dspCreativeId dspRegion:dspRegion];
}

@end

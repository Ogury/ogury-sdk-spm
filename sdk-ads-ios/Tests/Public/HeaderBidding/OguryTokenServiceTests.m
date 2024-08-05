//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OguryAds/OguryTokenService.h"
#import "NSDictionary+OGABase64.h"
#import "OGAConfigurationUtils.h"
#import "OGAConstants.h"
#import "OGAAdIdentifierService.h"
#import "OGAAdPrivacyConfiguration.h"
#import <OCMock/OCMock.h>
#import "OGAProfigManager.h"
#import "OGATokenGenerator.h"

static NSString *const DefaultCampaignId = @"campaignId";
static NSString *const DefaultCreativeId = @"creativeId";
static NSString *const DefaultDspCreativeId = @"dspCreativeId";
static NSString *const DefaultDspRegion = @"dspRegion";

@interface OguryTokenService ()

+ (NSString *_Nullable)getBidderTokenFrom:(OGATokenGenerator *)tokenGenerator;

+ (NSString *_Nullable)getBidderTokenWithCampaignId:(NSString *)campaignId
                                         creativeId:(NSString *_Nullable)creativeId
                                      dspCreativeId:(NSString *_Nullable)dspCreativeId
                                          dspRegion:(NSString *_Nullable)dspRegion;

+ (NSString *_Nullable)getBidderTokenWithCampaignId:(NSString *)campaignId
                                         creativeId:(NSString *_Nullable)creativeId;

+ (NSString *_Nullable)getBidderTokenWithCampaignId:(NSString *)campaignId;

+ (NSString *_Nullable)getBidderTokenFrom:(OGATokenGenerator *)tokenGenerator campaignId:(NSString *)campaignId creativeId:(NSString *_Nullable)creativeId dspCreativeId:(NSString *_Nullable)dspCreativeId dspRegion:(NSString *_Nullable)dspRegion;

@end

@interface OGATokenGenerator ()

- (BOOL)canSendToken;

@end

@interface OguryTokenServiceTests : XCTestCase

@end

@implementation OguryTokenServiceTests

- (void)testGetBidderToken {
    OGATokenGenerator *tokenGenerator = OCMPartialMock([OGATokenGenerator new]);
    OCMStub([tokenGenerator canSendToken]).andReturn(YES);
    NSString *bidderToken = [OguryTokenService getBidderTokenFrom:tokenGenerator];
    XCTAssertNotNil(bidderToken);
}

- (void)testTokenHasAppVersion {
    OGATokenGenerator *tokenGenerator = OCMPartialMock([OGATokenGenerator new]);
    OCMStub([tokenGenerator canSendToken]).andReturn(YES);
    NSString *bidderToken = [OguryTokenService getBidderTokenFrom:tokenGenerator];
    NSError *error = nil;
    NSDictionary *token = [NSDictionary ogaDecodeFromBase64:bidderToken error:&error];
    NSDictionary *app = token[OGARequestBodyAppKey];
    XCTAssertNotNil(app, @"app key not found");
    NSString *version = app[OGARequestBodyAppVersionKey];
    XCTAssertNotNil(version, @"version key not found");
    XCTAssertTrue([version isEqualToString:[OGAConfigurationUtils getAppMarketingVersion]]);
}

- (void)testGetBidderTokenWithCampaignIdCreativeIdDspCreativeIdDspRegion {
    OGATokenGenerator *tokenGenerator = OCMPartialMock([[OGATokenGenerator alloc] init]);
    OCMStub([tokenGenerator canSendToken]).andReturn(YES);
    NSString *bidderToken = [OguryTokenService getBidderTokenFrom:tokenGenerator
                                                       campaignId:DefaultCampaignId
                                                       creativeId:DefaultCreativeId
                                                    dspCreativeId:DefaultDspCreativeId
                                                        dspRegion:DefaultDspRegion];
    XCTAssertNotNil(bidderToken);
}

@end

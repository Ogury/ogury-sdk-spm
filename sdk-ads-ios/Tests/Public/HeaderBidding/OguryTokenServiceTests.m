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

+ (void)bidderTokenFrom:(OGATokenGenerator *)tokenGenerator completion:(HeaderBiddingCompletionBlock)completion;

+ (void)bidderTokenFrom:(OGATokenGenerator *)tokenGenerator
             campaignId:(NSString *)campaignId
             creativeId:(NSString *_Nullable)creativeId
          dspCreativeId:(NSString *_Nullable)dspCreativeId
              dspRegion:(NSString *_Nullable)dspRegion
             completion:(HeaderBiddingCompletionBlock)completion;

@end

@interface OGATokenGenerator ()

- (NSError *)tokenGenerationDenied;
- (OGAProfigManager *)profigManager;
- (void)bidderTokenWithCampaignId:(NSString *_Nullable)campaignId
                       creativeId:(NSString *_Nullable)creativeId
                    dspCreativeId:(NSString *_Nullable)dspCreativeId
                        dspRegion:(NSString *_Nullable)dspRegion
                       completion:(HeaderBiddingCompletionBlock)completion;
- (void)collectBidderTokenDataWithCampaignId:(NSString *_Nullable)campaignId
                                  creativeId:(NSString *_Nullable)creativeId
                               dspCreativeId:(NSString *_Nullable)dspCreativeId
                                   dspRegion:(NSString *_Nullable)dspRegion
                                  completion:(HeaderBiddingCompletionBlock)completion;

@end

@interface OguryTokenServiceTests : XCTestCase

@end

@implementation OguryTokenServiceTests

- (void)testGetBidderToken {
    OGATokenGenerator *tokenGenerator = OCMPartialMock([OGATokenGenerator new]);
    OCMStub([tokenGenerator tokenGenerationDenied]).andReturn(nil);
    [OguryTokenService bidderTokenFrom:tokenGenerator
                            completion:^(NSString *_Nullable token, NSError *_Nullable error) {
                                XCTAssertNotNil(token);
                            }];
}

- (void)testTokenHasAppVersion {
    OGATokenGenerator *tokenGenerator = OCMPartialMock([OGATokenGenerator new]);
    OCMStub([tokenGenerator tokenGenerationDenied]).andReturn(nil);
    [OguryTokenService bidderTokenFrom:tokenGenerator
                            completion:^(NSString *_Nullable bidderToken, NSError *_Nullable error) {
                                NSError *decodeError = nil;
                                NSDictionary *token = [NSDictionary ogaDecodeFromBase64:bidderToken error:&decodeError];
                                NSDictionary *app = token[OGARequestBodyAppKey];
                                XCTAssertNotNil(app, @"app key not found");
                                NSString *version = app[OGARequestBodyAppVersionKey];
                                XCTAssertNotNil(version, @"version key not found");
                                XCTAssertTrue([version isEqualToString:[OGAConfigurationUtils getAppMarketingVersion]]);
                            }];
}

- (void)testGetBidderTokenWithCampaignIdCreativeIdDspCreativeIdDspRegion {
    OGATokenGenerator *tokenGenerator = OCMPartialMock([[OGATokenGenerator alloc] init]);
    OCMStub([tokenGenerator tokenGenerationDenied]).andReturn(nil);
    [OguryTokenService bidderTokenFrom:tokenGenerator
                            campaignId:DefaultCampaignId
                            creativeId:DefaultCreativeId
                         dspCreativeId:DefaultDspCreativeId
                             dspRegion:DefaultDspRegion
                            completion:^(NSString *_Nullable token, NSError *_Nullable error) {
                                XCTAssertNotNil(token);
                            }];
}

- (void)testWhenProfigShouldBeUpdatedThenItIsUpdatedBeforeComputingToken {
    OGAProfigManager *profigManager = OCMClassMock([OGAProfigManager class]);
    OGATokenGenerator *tokenGenerator = OCMPartialMock([[OGATokenGenerator alloc] init]);
    OCMStub(profigManager.shouldSync).andReturn(YES);
    OCMStub(tokenGenerator.profigManager).andReturn(profigManager);
    [tokenGenerator bidderTokenWithCampaignId:nil
                                   creativeId:nil
                                dspCreativeId:nil
                                    dspRegion:nil
                                   completion:^(NSString *_Nullable token, NSError *_Nullable error){

                                   }];
    OCMVerify([profigManager syncProfigWithCompletion:[OCMArg any]]);
    OCMReject([tokenGenerator collectBidderTokenDataWithCampaignId:nil
                                                        creativeId:nil
                                                     dspCreativeId:nil
                                                         dspRegion:nil
                                                        completion:^(NSString *_Nullable token, NSError *_Nullable error){

                                                        }]);
}

- (void)testWhenProfigShouldNotBeUpdatedThenComputingTokenStartsImmediately {
    OGAProfigManager *profigManager = OCMClassMock([OGAProfigManager class]);
    OGATokenGenerator *tokenGenerator = OCMPartialMock([[OGATokenGenerator alloc] init]);
    OCMStub(profigManager.shouldSync).andReturn(NO);
    OCMStub(tokenGenerator.profigManager).andReturn(profigManager);
    [tokenGenerator bidderTokenWithCampaignId:nil
                                   creativeId:nil
                                dspCreativeId:nil
                                    dspRegion:nil
                                   completion:^(NSString *_Nullable token, NSError *_Nullable error){

                                   }];
    OCMReject([profigManager syncProfigWithCompletion:[OCMArg any]]);
    OCMVerify([tokenGenerator collectBidderTokenDataWithCampaignId:[OCMArg any]
                                                        creativeId:[OCMArg any]
                                                     dspCreativeId:[OCMArg any]
                                                         dspRegion:[OCMArg any]
                                                        completion:[OCMArg any]]);
}

@end

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
#import "OGAAssetKeyManager.h"
#import "OGAProfigDao.h"

static NSString *const DefaultCampaignId = @"campaignId";
static NSString *const DefaultCreativeId = @"creativeId";
static NSString *const DefaultDspCreativeId = @"dspCreativeId";
static NSString *const DefaultDspRegion = @"dspRegion";

@interface OguryTokenService ()

+ (void)bidTokenFrom:(OGATokenGenerator *)tokenGenerator completion:(BidTokenCompletionBlock)completion;

+ (void)bidTokenFrom:(OGATokenGenerator *)tokenGenerator
          campaignId:(NSString *)campaignId
          creativeId:(NSString *_Nullable)creativeId
       dspCreativeId:(NSString *_Nullable)dspCreativeId
           dspRegion:(NSString *_Nullable)dspRegion
          completion:(BidTokenCompletionBlock)completion;

@end

@interface OGATokenGenerator ()

@property(nonatomic, strong) OGAAssetKeyManager *assetKeyManager;
@property(nonatomic, strong) OGAProfigDao *profigDao;

- (OGAProfigManager *)profigManager;
- (void)bidTokenWithCampaignId:(NSString *_Nullable)campaignId
                    creativeId:(NSString *_Nullable)creativeId
                 dspCreativeId:(NSString *_Nullable)dspCreativeId
                     dspRegion:(NSString *_Nullable)dspRegion
                    completion:(BidTokenCompletionBlock)completion;
- (void)collectBidTokenDataWithCampaignId:(NSString *_Nullable)campaignId
                               creativeId:(NSString *_Nullable)creativeId
                            dspCreativeId:(NSString *_Nullable)dspCreativeId
                                dspRegion:(NSString *_Nullable)dspRegion
                               completion:(BidTokenCompletionBlock)completion;

@end

@interface OguryTokenServiceTests : XCTestCase

@property(nonatomic, strong) OGATokenGenerator *tokenGenerator;

@end

@implementation OguryTokenServiceTests

- (void)setUp {
    self.tokenGenerator = OCMPartialMock([[OGATokenGenerator alloc] init]);
    OGAAssetKeyManager *assetKeyManager = OCMPartialMock([[OGAAssetKeyManager alloc] init]);
    OGAProfigDao *profigDao = OCMPartialMock([[OGAProfigDao alloc] init]);
    OGAProfigFullResponse *profigFullResponse = OCMPartialMock([[OGAProfigFullResponse alloc] init]);
    OCMStub(self.tokenGenerator.assetKeyManager).andReturn(assetKeyManager);
    OCMStub(profigDao.profigFullResponse).andReturn(profigFullResponse);
    OCMStub(profigFullResponse.adsEnabled).andReturn(true);
    OCMStub(self.tokenGenerator.profigDao).andReturn(profigDao);
    OCMStub([assetKeyManager checkAssetKeyIsValid:[OCMArg anyObjectRef] type:OguryAdErrorTypeLoad]).andReturn(true);
}

- (void)testGetBidToken {
    [OguryTokenService bidTokenFrom:self.tokenGenerator
                         completion:^(NSString *_Nullable token, NSError *_Nullable error) {
                             XCTAssertNotNil(token);
                         }];
}

- (void)testTokenHasAppVersion {
    [OguryTokenService bidTokenFrom:self.tokenGenerator
                         completion:^(NSString *_Nullable bidToken, NSError *_Nullable error) {
                             NSError *decodeError = nil;
                             NSDictionary *token = [NSDictionary ogaDecodeFromBase64:bidToken error:&decodeError];
                             NSDictionary *app = token[OGARequestBodyAppKey];
                             XCTAssertNotNil(app, @"app key not found");
                             NSString *version = app[OGARequestBodyAppVersionKey];
                             XCTAssertNotNil(version, @"version key not found");
                             XCTAssertTrue([version isEqualToString:[OGAConfigurationUtils getAppMarketingVersion]]);
                         }];
}

- (void)testGetBidTokenWithCampaignIdCreativeIdDspCreativeIdDspRegion {
    [OguryTokenService bidTokenFrom:self.tokenGenerator
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
    OCMStub(profigManager.shouldSync).andReturn(YES);
    OCMStub(self.tokenGenerator.profigManager).andReturn(profigManager);
    [self.tokenGenerator bidTokenWithCampaignId:nil
                                     creativeId:nil
                                  dspCreativeId:nil
                                      dspRegion:nil
                                     completion:^(NSString *_Nullable token, NSError *_Nullable error){

                                     }];
    OCMVerify([profigManager syncProfigWithCompletion:[OCMArg any]]);
    OCMReject([self.tokenGenerator collectBidTokenDataWithCampaignId:nil
                                                          creativeId:nil
                                                       dspCreativeId:nil
                                                           dspRegion:nil
                                                          completion:^(NSString *_Nullable token, NSError *_Nullable error){

                                                          }]);
}

- (void)testWhenProfigShouldNotBeUpdatedThenComputingTokenStartsImmediately {
    OGAProfigManager *profigManager = OCMClassMock([OGAProfigManager class]);
    OCMStub(profigManager.shouldSync).andReturn(NO);
    OCMStub(self.tokenGenerator.profigManager).andReturn(profigManager);
    [self.tokenGenerator bidTokenWithCampaignId:nil
                                     creativeId:nil
                                  dspCreativeId:nil
                                      dspRegion:nil
                                     completion:^(NSString *_Nullable token, NSError *_Nullable error){

                                     }];
    OCMReject([profigManager syncProfigWithCompletion:[OCMArg any]]);
    OCMVerify([self.tokenGenerator collectBidTokenDataWithCampaignId:[OCMArg any]
                                                          creativeId:[OCMArg any]
                                                       dspCreativeId:[OCMArg any]
                                                           dspRegion:[OCMArg any]
                                                          completion:[OCMArg any]]);
}

@end

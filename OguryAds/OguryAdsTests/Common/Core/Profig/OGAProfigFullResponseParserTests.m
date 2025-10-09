//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAProfigFullResponse+Parser.h"
#import "OGAProfigConstants.h"
#import <OCMock/OCMock.h>

@interface OGAProfigFullResponseParserTests : XCTestCase

@property(atomic, strong) NSURLResponse *urlResponse;
@property(atomic, strong) NSArray<NSString *> *defaultBlackListTracks;

@end

@interface OGAProfigFullResponse ()

+ (OGAProfigFullResponse *)parserFullResponseWithDictionary:(NSDictionary *)profigJSON;
+ (NSDictionary *)retreiveHttpResponseHeader:(NSURLResponse *)urlResponse;
+ (void)handleBooleansDefaultValuesFrom:(NSDictionary*)json for:(OGAProfigFullResponse *)profig;

@end

@implementation OGAProfigFullResponseParserTests

- (void)setUp {
    self.urlResponse = OCMClassMock([NSURLResponse class]);
    self.defaultBlackListTracks = @[ @"LI-002", @"LI-003", @"LI-004", @"LI-005", @"LI-006", @"LI-007", @"LI-008", @"LI-010", @"LI-011", @"LI-012", @"LI-013", @"LI-014", @"SI-002", @"SI-003", @"SI-004", @"SI-005", @"SI-006", @"SI-008", @"SI-009", @"SI-010", @"SI-011", @"SI-012", @"SI-013", @"SI-014", @"SI-015" ];
}

- (void)testParseProfigResponseWithData {
    OGAProfigFullResponse *response = [OGAProfigFullResponse parseProfigResponseWithData:nil urlResponse:self.urlResponse];
    XCTAssertNil(response);

    response = [OGAProfigFullResponse parseProfigResponseWithData:[@"{invalidJSON}" dataUsingEncoding:NSUTF8StringEncoding] urlResponse:self.urlResponse];
    XCTAssertNil(response);

    response = [OGAProfigFullResponse parseProfigResponseWithData:[@"{}" dataUsingEncoding:NSUTF8StringEncoding] urlResponse:self.urlResponse];
    XCTAssertNil(response);
}

- (void)testParserFullResponseWithDictionary {
    NSDictionary *profigDictionnary = [NSDictionary dictionary];
    OGAProfigFullResponse *response = [OGAProfigFullResponse parserFullResponseWithDictionary:nil];
    XCTAssertNil(response);
    response = [OGAProfigFullResponse parserFullResponseWithDictionary:profigDictionnary];
    XCTAssertNotNil(response);
    XCTAssertNotNil(response.maxProfigApiCallsPerDay);
    XCTAssertTrue([response.maxProfigApiCallsPerDay isEqualToNumber:@(OGAProfigCallsPerDayDefault)]);
    XCTAssertFalse(response.backButtonEnabled);
    XCTAssertTrue(response.backButtonEnabled == OGABackButtonEnabledDefault);
    XCTAssertNotNil(response.webviewLoadTimeout);
    XCTAssertTrue([response.webviewLoadTimeout isEqualToNumber:@(OGAWebviewLoadTimeoutDefault)]);
    XCTAssertNotNil(response.adExpirationTime);
    XCTAssertTrue([response.adExpirationTime isEqualToNumber:@(OGAADExpirationTimeDefault)]);
    XCTAssertNotNil(response.showCloseButtonDelay);
    XCTAssertTrue([response.showCloseButtonDelay isEqualToNumber:@(OGAShowCloseButtonDelayDefault)]);
    XCTAssertFalse(response.adsEnabled);
    XCTAssertFalse(response.omidEnabled);
    XCTAssertTrue(response.cacheLogsEnabled);
    XCTAssertFalse(response.backButtonEnabled);
    XCTAssertTrue(response.precachingLogsEnabled);
    XCTAssertTrue(response.adLifeCycleLogsEnabled);
    XCTAssertTrue(response.closeAdWhenLeavingApp);
    XCTAssertEqualObjects(response.blacklistedTracks, self.defaultBlackListTracks);
}

- (void)testWhenJsonDoesNotContainRetryIntervalThenDefaultValueIsUSed {
    NSString *profigJson = [[NSBundle bundleForClass:[self class]] pathForResource:@"testProfigJSON1" ofType:@"json"];
    NSData *profigJsonData = [NSData dataWithContentsOfFile:profigJson];
    OGAProfigFullResponse *response = [OGAProfigFullResponse parseProfigResponseWithData:profigJsonData urlResponse:[NSURLResponse new]];
    XCTAssertNotNil(response.retryInterval);
    XCTAssertTrue([response.retryInterval isEqualToNumber:@(OGAMaxAgeDefault)]);
}

- (void)testWhenMaxAgeIsInHeadersThenItIsParsed {
    NSString *profigJson = [[NSBundle bundleForClass:[self class]] pathForResource:@"testProfigJSON1" ofType:@"json"];
    NSData *profigJsonData = [NSData dataWithContentsOfFile:profigJson];
    NSHTTPURLResponse *response = OCMClassMock([NSHTTPURLResponse class]);
    id profigClassMock = OCMClassMock([OGAProfigFullResponse class]);
    OCMStub(OCMClassMethod([profigClassMock retreiveHttpResponseHeader:[OCMArg any]])).andReturn(@{@"Cache-Control" : @"max-age=300"});
    OGAProfigFullResponse *profigResponse = [OGAProfigFullResponse parseProfigResponseWithData:profigJsonData urlResponse:response];
    XCTAssertEqual(profigResponse.retryInterval, @(300));
}

- (void)testWhenMaxAgeIsInHeadersAlongWithOtherValuesThenItIsParsed {
    NSString *profigJson = [[NSBundle bundleForClass:[self class]] pathForResource:@"testProfigJSON1" ofType:@"json"];
    NSData *profigJsonData = [NSData dataWithContentsOfFile:profigJson];
    NSHTTPURLResponse *response = OCMClassMock([NSHTTPURLResponse class]);
    id profigClassMock = OCMClassMock([OGAProfigFullResponse class]);
    OCMStub(OCMClassMethod([profigClassMock retreiveHttpResponseHeader:[OCMArg any]])).andReturn(@{@"Cache-Control" : @"public, max-age=400"});
    OGAProfigFullResponse *profigResponse = [OGAProfigFullResponse parseProfigResponseWithData:profigJsonData urlResponse:response];
    XCTAssertEqual(profigResponse.retryInterval, @(400));
}

- (void)testWhenBooleanValuesAreMissingFromJsonThenDefaultValuesAreSet {
    OGAProfigFullResponse *response = [OGAProfigFullResponse new];
    XCTAssertFalse(response.adsEnabled);
    XCTAssertFalse(response.omidEnabled);
    XCTAssertFalse(response.cacheLogsEnabled);
    XCTAssertFalse(response.backButtonEnabled);
    XCTAssertFalse(response.precachingLogsEnabled);
    XCTAssertFalse(response.adLifeCycleLogsEnabled);
    XCTAssertFalse(response.closeAdWhenLeavingApp);
    [OGAProfigFullResponse handleBooleansDefaultValuesFrom:@{} for:response];
    XCTAssertFalse(response.adsEnabled);
    XCTAssertFalse(response.omidEnabled);
    XCTAssertTrue(response.cacheLogsEnabled);
    XCTAssertFalse(response.backButtonEnabled);
    XCTAssertTrue(response.precachingLogsEnabled);
    XCTAssertTrue(response.adLifeCycleLogsEnabled);
    XCTAssertTrue(response.closeAdWhenLeavingApp);
    XCTAssertEqualObjects(response.blacklistedTracks, self.defaultBlackListTracks);
}

- (void)testWhenBooleanValuesArePresentInJsonThenDefaultValuesAreNotSet {
    OGAProfigFullResponse *response = [OGAProfigFullResponse new];
    // setting values to opposite as default
    response.adsEnabled = YES;
    response.omidEnabled = YES;
    response.cacheLogsEnabled = YES;
    response.backButtonEnabled = YES;
    response.precachingLogsEnabled = YES;
    response.adLifeCycleLogsEnabled = YES;
    response.closeAdWhenLeavingApp = NO;
    // if values for booleans are present in dictionary, then profig value is not updated
    [OGAProfigFullResponse handleBooleansDefaultValuesFrom:@{ @"response" : @{
        @"ad_serving" : @{
            @"enabled" : @NO,
            @"webview" : @{ @"back_button_enabled" : @NO, @"close_ad_when_leaving_app" : @YES }
        },
        @"monitoring" : @{
            @"tracks" : @{ @"enabled" : @NO },
            @"precaching_logs" : @{ @"enabled" : @NO },
            @"ad_life_cycle" : @{ @"enabled" : @NO }
        },
        @"omid" : @{
            @"enabled" : @NO
        }
    } } for:response];
    XCTAssertTrue(response.adsEnabled);
    XCTAssertTrue(response.omidEnabled);
    XCTAssertTrue(response.cacheLogsEnabled);
    XCTAssertTrue(response.backButtonEnabled);
    XCTAssertTrue(response.precachingLogsEnabled);
    XCTAssertTrue(response.adLifeCycleLogsEnabled);
    XCTAssertFalse(response.closeAdWhenLeavingApp);
}

@end

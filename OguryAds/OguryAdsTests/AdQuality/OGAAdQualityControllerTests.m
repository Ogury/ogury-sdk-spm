//
//  OGAAdQualityControllerTests.m
//  OguryAdsTests
//
//  Created by Jerome TONNELIER on 27/08/2025.
//  Copyright © 2025 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGAAdQualityController.h"
#import "OGAAdConfiguration.h"
#import "OGAMonitoringDispatcher.h"
#import "OGAAdQualityAlgorithm.h"
#import "OGAAdQualityUniformColorRectAlgorithm.h"
#import <OguryAds/OGALog.h>

@interface OGAAdQualityControllerTests : XCTestCase
@property(nonatomic, retain) OGAAdQualityController *sut;
@property(nonatomic, retain) UIView *emtpyView;
@end

@interface OGAAdQualityUniformColorRectAlgorithm ()
- (instancetype)initWithSize:(CGSize)size
                   threshold:(NSNumber *)threshold
                  startDelay:(NSNumber *)delay
              allowedFormats:(NSArray<NSString *> *)allowedFormats;
- (void)sendMonitoringEventFor:(OGAAdQualityResult *)result adConfiguration:(OGAAdConfiguration *)adConfiguration;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) NSNumber *devianceMax;
@property(nonatomic, strong) NSString *uniformHexColor;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@end

@interface OGAAdQualityController ()
@property(nonatomic, retain) NSArray<id<OGAAdQualityAlgorithm>> *activeAlgorithms;
@end

@implementation OGAAdQualityControllerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.sut = OCMPartialMock([OGAAdQualityController new]);
    self.emtpyView = [UIView new];
    [self.emtpyView setBackgroundColor:[UIColor whiteColor]];
    [self.emtpyView setFrame:CGRectMake(0, 0, 100, 100)];
}

- (void)addDefaultDictValuesAndSingleton:(BOOL)addSingleton {
    OGAAdQualityUniformColorRectAlgorithm *rectAlgo = self.sut.activeAlgorithms[0];
    rectAlgo.devianceMax = @(0);
    rectAlgo.uniformHexColor = @"";
    if (addSingleton) {
        rectAlgo.log = OCMClassMock([OGALog class]);
        rectAlgo.monitoringDispatcher = OCMClassMock([OGAMonitoringDispatcher class]);
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testWhenUpdatingAllowedAlgosThenTheListIsUpdated {
    self.sut.activeAlgorithms = @[];
    XCTAssertEqual(self.sut.activeAlgorithms.count, 0);
    self.sut.activeAlgorithms = @[ [[OGAAdQualityUniformColorRectAlgorithm alloc] initWithSize:CGSizeMake(50, 50)
                                                                                     threshold:@(6)
                                                                                    startDelay:@(1000)
                                                                                allowedFormats:@[ OGAAdConfigurationAdTypeInterstitial ]] ];
    XCTAssertEqual(self.sut.activeAlgorithms.count, 1);
}

- (void)testWhenPerformingChecksWithNoAlgorythmThenEmptyCompletionIsCalled {
    self.sut.activeAlgorithms = @[];
    OGAAdConfiguration *conf = OCMClassMock([OGAAdConfiguration class]);
    XCTestExpectation *ex = [self expectationWithDescription:@"Completion block called"];
    [self.sut performAdQualityChecksOn:[UIView new]
                       adConfiguration:conf
                            completion:^(NSArray<OGAAdQualityResult *> *_Nonnull results) {
                                XCTAssertEqual(results.count, 0);
                                [ex fulfill];
                            }];
    [self waitForExpectations:@[ ex ] timeout:2];
}

- (void)testWhenPerformingChecksOnUnallowedFormatThenEmptyCompletionIsCalled {
    self.sut.activeAlgorithms = @[ [[OGAAdQualityUniformColorRectAlgorithm alloc] initWithSize:CGSizeMake(50, 50)
                                                                                     threshold:@(6)
                                                                                    startDelay:@(1000)
                                                                                allowedFormats:@[ OGAAdConfigurationAdTypeInterstitial ]] ];
    [self addDefaultDictValuesAndSingleton:YES];
    OGAAdConfiguration *conf = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([conf getAdTypeString]).andReturn(OGAAdConfigurationAdTypeStandardBanners);
    XCTestExpectation *ex = [self expectationWithDescription:@"Completion block called"];
    [self.sut performAdQualityChecksOn:[UIView new]
                       adConfiguration:conf
                            completion:^(NSArray<OGAAdQualityResult *> *_Nonnull results) {
                                XCTAssertEqual(results.count, 0);
                                [ex fulfill];
                            }];
    [self waitForExpectations:@[ ex ] timeout:2];
}

- (void)testWhenPerformingChecksOnAllowedFormatThenEmptyCompletionIsCalled {
    OGAAdQualityUniformColorRectAlgorithm *algo = OCMPartialMock([[OGAAdQualityUniformColorRectAlgorithm alloc] initWithSize:CGSizeMake(50, 50)
                                                                                                                   threshold:@(6)
                                                                                                                  startDelay:@(1000)
                                                                                                              allowedFormats:@[ OGAAdConfigurationAdTypeInterstitial ]]);
    self.sut.activeAlgorithms = @[ algo ];
    [self addDefaultDictValuesAndSingleton:YES];
    OGAAdConfiguration *conf = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([conf getAdTypeString]).andReturn(OGAAdConfigurationAdTypeInterstitial);
    XCTestExpectation *ex = [self expectationWithDescription:@"Completion block called"];
    [self.sut performAdQualityChecksOn:self.emtpyView
                       adConfiguration:conf
                            completion:^(NSArray<OGAAdQualityResult *> *_Nonnull results) {
                                if (results.count == 1) {
                                    [ex fulfill];
                                }
                            }];
    OCMVerify([algo performAdQualityCheckOn:self.emtpyView
                            adConfiguration:conf
                                 completion:[OCMArg any]]);
    [self waitForExpectations:@[ ex ] timeout:2];
}

- (void)testWhenPerformingChecksOnWhiteViewThenUniformResultIsSentBack {
    OGAAdQualityUniformColorRectAlgorithm *algo = OCMPartialMock([[OGAAdQualityUniformColorRectAlgorithm alloc] initWithSize:CGSizeMake(50, 50)
                                                                                                                   threshold:@(6)
                                                                                                                  startDelay:@(1000)
                                                                                                              allowedFormats:@[ OGAAdConfigurationAdTypeInterstitial ]]);
    self.sut.activeAlgorithms = @[ algo ];
    [self addDefaultDictValuesAndSingleton:YES];
    OGAAdConfiguration *conf = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([conf getAdTypeString]).andReturn(OGAAdConfigurationAdTypeInterstitial);
    XCTestExpectation *ex = [self expectationWithDescription:@"Completion block called"];
    [self.sut performAdQualityChecksOn:self.emtpyView
                       adConfiguration:conf
                            completion:^(NSArray<OGAAdQualityResult *> *_Nonnull results) {
                                XCTAssertEqual(results.count, 1);
                                OGAAdQualityResult *res = results[0];
                                XCTAssertEqualObjects(res.algo, OguryAdQualityAlgorithmUniformColorRect);
                                XCTAssertEqual(res.success, NO);
                                [ex fulfill];
                            }];
    [self waitForExpectations:@[ ex ] timeout:2];
}

- (void)testWhenPerformingChecksOnNotBlankAdThenUniformResultIsSentBack {
    OGAAdQualityUniformColorRectAlgorithm *algo = OCMPartialMock([[OGAAdQualityUniformColorRectAlgorithm alloc] initWithSize:CGSizeMake(50, 50)
                                                                                                                   threshold:@(6)
                                                                                                                  startDelay:@(1000)
                                                                                                              allowedFormats:@[ OGAAdConfigurationAdTypeInterstitial ]]);
    self.sut.activeAlgorithms = @[ algo ];
    [self addDefaultDictValuesAndSingleton:YES];
    OGAAdConfiguration *conf = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([conf getAdTypeString]).andReturn(OGAAdConfigurationAdTypeInterstitial);
    XCTestExpectation *ex = [self expectationWithDescription:@"Completion block called"];
    NSString *dataUrl = [[NSBundle bundleForClass:[OGAAdQualityControllerTests class]] pathForResource:@"NotBlankAd" ofType:@"png"];
    NSData *data = [NSData dataWithContentsOfFile:dataUrl];
    UIImage *image = [UIImage imageWithData:data];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [self.sut performAdQualityChecksOn:imageView adConfiguration:conf completion:^(NSArray<OGAAdQualityResult *> *_Nonnull results) {
        XCTAssertEqual(results.count, 1);
        OGAAdQualityResult *res = results[0];
        XCTAssertEqualObjects(res.algo, OguryAdQualityAlgorithmUniformColorRect);
        XCTAssertEqual(res.success, YES);
        [ex fulfill];
    }];
    [self waitForExpectations:@[ ex ] timeout:2];
}

- (void)testWhenPerformingChecksOnNotBlankAdThenMonitoringEventIsSent {
    OGALog *log = OCMClassMock([OGALog class]);
    OGAMonitoringDispatcher *monitoring = OCMClassMock([OGAMonitoringDispatcher class]);
    OGAAdQualityUniformColorRectAlgorithm *algo = OCMPartialMock([[OGAAdQualityUniformColorRectAlgorithm alloc] initWithSize:CGSizeMake(50, 50)
                                                                                                                   threshold:@(6)
                                                                                                                  startDelay:@(1000)
                                                                                                              allowedFormats:@[ OGAAdConfigurationAdTypeInterstitial ]]);
    self.sut.activeAlgorithms = @[ algo ];
    OCMStub(algo.monitoringDispatcher).andReturn(monitoring);
    OCMStub(algo.log).andReturn(log);
    [self addDefaultDictValuesAndSingleton:NO];
    OGAAdConfiguration *conf = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([conf getAdTypeString]).andReturn(OGAAdConfigurationAdTypeInterstitial);
    XCTestExpectation *ex = [self expectationWithDescription:@"Completion block called"];
    [self.sut performAdQualityChecksOn:self.emtpyView
                       adConfiguration:conf
                            completion:^(NSArray<OGAAdQualityResult *> *_Nonnull results) {
                                XCTAssertEqual(results.count, 1);
                                OGAAdQualityResult *res = results[0];
                                XCTAssertEqualObjects(res.algo, OguryAdQualityAlgorithmUniformColorRect);
                                XCTAssertEqual(res.success, NO);
                                [ex fulfill];
                                OCMVerify([monitoring sendAdQualityEvent:OGAShowEventAdQualityBlankAd adConfiguration:conf details:[OCMArg any]]);
                            }];
    [self waitForExpectations:@[ ex ] timeout:2];
}

@end

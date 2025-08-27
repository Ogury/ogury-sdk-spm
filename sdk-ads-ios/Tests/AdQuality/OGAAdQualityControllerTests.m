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
#import "OGAAdQualityUniformColorRectAlgorythm.h"

@interface OGAAdQualityControllerTests : XCTestCase
@property(nonatomic, retain) OGAAdQualityController *sut;
@property(nonatomic, retain) UIView *emtpyView;
@end

@implementation OGAAdQualityControllerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.sut = OCMPartialMock([OGAAdQualityController new]);
    self.emtpyView = [UIView new];
    [self.emtpyView setBackgroundColor:[UIColor whiteColor]];
    [self.emtpyView setFrame:CGRectMake(0, 0, 100, 100)];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testWhenUpdatingAllowedAlgosThenTheListIsUpdated {
    self.sut.activeAlgorythms = @[];
    XCTAssertEqual(self.sut.activeAlgorythms.count, 0);
    self.sut.activeAlgorythms = @[ [[OGAAdQualityUniformColorRectAlgorythm alloc] initWithSize:CGSizeMake(50, 50)
                                                                                     threshold:@(6)
                                                                                    startDelay:@(1000)
                                                                                allowedFormats:@[ OGAAdConfigurationAdTypeInterstitial ]] ];
    XCTAssertEqual(self.sut.activeAlgorythms.count, 1);
}

- (void)testWhenPerformingChecksWithNoAlgorythmThenEmptyCompletionIsCalled {
    self.sut.activeAlgorythms = @[];
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

- (void)testWhenPerformingChecksWhileDisabledThenEmptyCompletionIsCalled {
    self.sut.activeAlgorythms = @[ [[OGAAdQualityUniformColorRectAlgorythm alloc] initWithSize:CGSizeMake(50, 50)
                                                                                     threshold:@(6)
                                                                                    startDelay:@(1000)
                                                                                allowedFormats:@[ OGAAdConfigurationAdTypeInterstitial ]] ];
    OGAAdConfiguration *conf = OCMClassMock([OGAAdConfiguration class]);
    OCMStub(self.sut.isEnabled).andReturn(NO);
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
    self.sut.activeAlgorythms = @[ [[OGAAdQualityUniformColorRectAlgorythm alloc] initWithSize:CGSizeMake(50, 50)
                                                                                     threshold:@(6)
                                                                                    startDelay:@(1000)
                                                                                allowedFormats:@[ OGAAdConfigurationAdTypeInterstitial ]] ];
    OGAAdConfiguration *conf = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([conf getAdTypeString]).andReturn(OGAAdConfigurationAdTypeStandardBanners);
    OCMStub(self.sut.isEnabled).andReturn(NO);
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
    OGAAdQualityUniformColorRectAlgorythm *algo = OCMPartialMock([[OGAAdQualityUniformColorRectAlgorythm alloc] initWithSize:CGSizeMake(50, 50)
                                                                                                                   threshold:@(6)
                                                                                                                  startDelay:@(1000)
                                                                                                              allowedFormats:@[ OGAAdConfigurationAdTypeInterstitial ]]);
    self.sut.activeAlgorythms = @[ algo ];
    OGAAdConfiguration *conf = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([conf getAdTypeString]).andReturn(OGAAdConfigurationAdTypeInterstitial);
    OCMStub(self.sut.isEnabled).andReturn(YES);
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
    OGAAdQualityUniformColorRectAlgorythm *algo = OCMPartialMock([[OGAAdQualityUniformColorRectAlgorythm alloc] initWithSize:CGSizeMake(50, 50)
                                                                                                                   threshold:@(6)
                                                                                                                  startDelay:@(1000)
                                                                                                              allowedFormats:@[ OGAAdConfigurationAdTypeInterstitial ]]);
    self.sut.activeAlgorythms = @[ algo ];
    OGAAdConfiguration *conf = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([conf getAdTypeString]).andReturn(OGAAdConfigurationAdTypeInterstitial);
    OCMStub(self.sut.isEnabled).andReturn(YES);
    XCTestExpectation *ex = [self expectationWithDescription:@"Completion block called"];
    [self.sut performAdQualityChecksOn:self.emtpyView
                       adConfiguration:conf
                            completion:^(NSArray<OGAAdQualityResult *> *_Nonnull results) {
                                XCTAssertEqual(results.count, 1);
                                OGAAdQualityResult *res = results[0];
                                XCTAssertEqualObjects(res.algo, OguryAdQualityAlgorythmUniformColorRect);
                                XCTAssertEqual(res.success, NO);
                                [ex fulfill];
                            }];
    [self waitForExpectations:@[ ex ] timeout:2];
}

- (void)testWhenPerformingChecksOnNotBlankAdThenUniformResultIsSentBack {
    OGAAdQualityUniformColorRectAlgorythm *algo = OCMPartialMock([[OGAAdQualityUniformColorRectAlgorythm alloc] initWithSize:CGSizeMake(50, 50)
                                                                                                                   threshold:@(6)
                                                                                                                  startDelay:@(1000)
                                                                                                              allowedFormats:@[ OGAAdConfigurationAdTypeInterstitial ]]);
    self.sut.activeAlgorythms = @[ algo ];
    OGAAdConfiguration *conf = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([conf getAdTypeString]).andReturn(OGAAdConfigurationAdTypeInterstitial);
    OCMStub(self.sut.isEnabled).andReturn(YES);
    XCTestExpectation *ex = [self expectationWithDescription:@"Completion block called"];
    NSString *dataUrl = [[NSBundle bundleForClass:[OGAAdQualityControllerTests class]] pathForResource:@"NotBlankAd" ofType:@"png"];
    NSData *data = [NSData dataWithContentsOfFile:dataUrl];
    UIImage *image = [UIImage imageWithData:data];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [self.sut performAdQualityChecksOn:imageView
                       adConfiguration:conf
                            completion:^(NSArray<OGAAdQualityResult *> *_Nonnull results) {
                                XCTAssertEqual(results.count, 1);
                                OGAAdQualityResult *res = results[0];
                                XCTAssertEqualObjects(res.algo, OguryAdQualityAlgorythmUniformColorRect);
                                XCTAssertEqual(res.success, YES);
                                [ex fulfill];
                            }];
    [self waitForExpectations:@[ ex ] timeout:2];
}

@end

//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAViewControllerOrientationHelper.h"
#import <OCMock/OCMock.h>

@interface OGAViewController_OrientationOperationsTests : XCTestCase
- (BOOL)orientationIsSupportedByApplication:(UIInterfaceOrientationMask)orientation supportedOrientation:(NSArray<NSString *> *)supportedOrientations;
@end

@interface OGAViewControllerOrientationHelper ()
- (instancetype)initWithBundle:(NSBundle *)bundle;
@end

@implementation OGAViewController_OrientationOperationsTests
#pragma mark - (UIInterfaceOrientationMask)orientationMaskFromRawValue:(NSNumber*)rawValue
- (void)testOrientationMaskFromRawValuePortrait {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationMaskFromRawValue:[NSNumber numberWithUnsignedInt:1 << UIInterfaceOrientationPortrait]], UIInterfaceOrientationMaskPortrait);
}
- (void)testOrientationMaskNSNumberValuePortrait {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationMaskFromRawValue:[NSNumber numberWithUnsignedInt:UIInterfaceOrientationMaskPortrait]], UIInterfaceOrientationMaskPortrait);
}
- (void)testOrientationMaskFromRawValuePortraitUpsideDown {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationMaskFromRawValue:[NSNumber numberWithUnsignedInt:1 << UIInterfaceOrientationPortraitUpsideDown]], UIInterfaceOrientationMaskPortraitUpsideDown);
}
- (void)testOrientationMaskNSNumberValueUpsideDown {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationMaskFromRawValue:[NSNumber numberWithUnsignedInt:UIInterfaceOrientationMaskPortraitUpsideDown]], UIInterfaceOrientationMaskPortraitUpsideDown);
}
- (void)testOrientationMaskFromRawLandscape {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationMaskFromRawValue:[NSNumber numberWithUnsignedInt:((UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight))]], UIInterfaceOrientationMaskLandscape);
}
- (void)testOrientationMaskNSNumberValueLandscape {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationMaskFromRawValue:[NSNumber numberWithUnsignedInt:UIInterfaceOrientationMaskLandscape]], UIInterfaceOrientationMaskLandscape);
}
- (void)testOrientationMaskFromRawLandscapeLeft {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationMaskFromRawValue:[NSNumber numberWithUnsignedInt:1 << UIInterfaceOrientationLandscapeLeft]], UIInterfaceOrientationMaskLandscapeLeft);
}
- (void)testOrientationMaskNSNumberValueLandscapeLeft {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationMaskFromRawValue:[NSNumber numberWithUnsignedInt:UIInterfaceOrientationMaskLandscapeLeft]], UIInterfaceOrientationMaskLandscapeLeft);
}
- (void)testOrientationMaskFromRawLandscapeRight {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationMaskFromRawValue:[NSNumber numberWithUnsignedInt:1 << UIInterfaceOrientationLandscapeRight]], UIInterfaceOrientationMaskLandscapeRight);
}
- (void)testOrientationMaskNSNumberValueLandscapeRight {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationMaskFromRawValue:[NSNumber numberWithUnsignedInt:UIInterfaceOrientationMaskLandscapeRight]], UIInterfaceOrientationMaskLandscapeRight);
}
- (void)testOrientationMaskFromRawAllOrientation {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationMaskFromRawValue:[NSNumber numberWithUnsignedInt:((UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown))]], UIInterfaceOrientationMaskAll);
}
- (void)testOrientationMaskNSNumberValueAll {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationMaskFromRawValue:[NSNumber numberWithUnsignedInt:UIInterfaceOrientationMaskAll]], UIInterfaceOrientationMaskAll);
}
- (void)testOrientationMaskFromRawValueAllButUpsideDown {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationMaskFromRawValue:[NSNumber numberWithUnsignedInt:(UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight)]], UIInterfaceOrientationMaskAllButUpsideDown);
}
- (void)testOrientationMaskNSNumberValueAllButUpsideDown {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationMaskFromRawValue:[NSNumber numberWithUnsignedInt:UIInterfaceOrientationMaskAllButUpsideDown]], UIInterfaceOrientationMaskAllButUpsideDown);
}

#pragma mark - (UIInterfaceOrientationMask)orientationMaskFromInterfaceOrientation:(UIInterfaceOrientation)orientation
- (void)testOrientationMaskFromOrientationPortraitReturnsMaskPortrait {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationMaskFromInterfaceOrientation:UIInterfaceOrientationPortrait], UIInterfaceOrientationMaskPortrait);
}
- (void)testOrientationMaskFromOrientationPortraitUpsideOdwnReturnsMaskPortraitUpsideDown {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationMaskFromInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown], UIInterfaceOrientationMaskPortraitUpsideDown);
}
- (void)testOrientationMaskFromOrientationLandscapeLeftReturnsMaskLandscapeLeft {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationMaskFromInterfaceOrientation:UIInterfaceOrientationLandscapeLeft], UIInterfaceOrientationMaskLandscapeLeft);
}
- (void)testOrientationMaskFromOrientationLandscapeRightReturnsMaskLandscapeRight {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationMaskFromInterfaceOrientation:UIInterfaceOrientationLandscapeRight], UIInterfaceOrientationMaskLandscapeRight);
}
- (void)testOrientationMaskFromOrientationUnknownReturnsMaskAll {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationMaskFromInterfaceOrientation:UIInterfaceOrientationUnknown], UIInterfaceOrientationMaskAll);
}

#pragma mark - (UIInterfaceOrientation)orientationFromInterfaceOrientationMask:(UIInterfaceOrientationMask)orientation
- (void)testOrientationFromOrientationMaskPortraitReturnsPortrait {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationFromInterfaceOrientationMask:UIInterfaceOrientationMaskPortrait], UIInterfaceOrientationPortrait);
}
- (void)testOrientationFromOrientationMaskPortraitUpsideDownReturnsPortraitUpsideDown {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationFromInterfaceOrientationMask:UIInterfaceOrientationMaskPortraitUpsideDown], UIInterfaceOrientationPortraitUpsideDown);
}
- (void)testOrientationFromOrientationMaskLandscapeLeftReturnsLandscapeLeft {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationFromInterfaceOrientationMask:UIInterfaceOrientationMaskLandscapeLeft], UIInterfaceOrientationLandscapeLeft);
}
- (void)testOrientationFromOrientationMaskLandscapeRightReturnsLandscapeRight {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationFromInterfaceOrientationMask:UIInterfaceOrientationMaskLandscapeRight], UIInterfaceOrientationLandscapeRight);
}
- (void)testOrientationFromOrientationMaskLandscapeReturnsLandscapeLeft {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationFromInterfaceOrientationMask:UIInterfaceOrientationMaskLandscape], UIInterfaceOrientationLandscapeLeft);
}
- (void)testOrientationFromOrientationMaskAllReturnsAllOrientations {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationFromInterfaceOrientationMask:UIInterfaceOrientationMaskAll], UIInterfaceOrientationLandscapeLeft & UIInterfaceOrientationLandscapeRight & UIInterfaceOrientationPortrait & UIInterfaceOrientationPortraitUpsideDown);
}
- (void)testOrientationFromOrientationMaskAllButUpsideDownReturnsAllOrientationButUpsideDown {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationFromInterfaceOrientationMask:UIInterfaceOrientationMaskAllButUpsideDown], UIInterfaceOrientationLandscapeLeft & UIInterfaceOrientationLandscapeRight & UIInterfaceOrientationPortrait);
}

#pragma mark - (UIInterfaceOrientation)orientationFromRawValue:(NSNumber*)rawValue
- (void)testOrientationOneIsPortrait {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationFromRawValue:@1], UIInterfaceOrientationPortrait);
}
- (void)testUIInterfaceOrientationPortraitAsNSNumberIsPortrait {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationFromRawValue:[NSNumber numberWithUnsignedInt:UIInterfaceOrientationPortrait]], UIInterfaceOrientationPortrait);
}
- (void)testOrientationTwoIsPortraitUpSideDown {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationFromRawValue:@2], UIInterfaceOrientationPortraitUpsideDown);
}
- (void)testUIInterfaceOrientationPortraittUpsideDownAsNSNumberIsPortrait {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationFromRawValue:[NSNumber numberWithUnsignedInt:UIInterfaceOrientationPortraitUpsideDown]], UIInterfaceOrientationPortraitUpsideDown);
}
- (void)testOrientationThreeIsLandscapeLeft {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationFromRawValue:@3], UIInterfaceOrientationLandscapeRight);
}
- (void)testUIInterfaceOrientationLandscapeLeftAsNSNumberIsPortrait {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationFromRawValue:[NSNumber numberWithUnsignedInt:UIInterfaceOrientationLandscapeLeft]], UIInterfaceOrientationLandscapeLeft);
}
- (void)testOrientationThreeIsLandscapeRight {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationFromRawValue:@4], UIInterfaceOrientationLandscapeLeft);
}
- (void)testUIInterfaceOrientationLandscapeRightAsNSNumberIsPortrait {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationFromRawValue:[NSNumber numberWithUnsignedInt:UIInterfaceOrientationLandscapeRight]], UIInterfaceOrientationLandscapeRight);
}

- (void)testOrientationHundrerIsUnknown {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationFromRawValue:@100], UIInterfaceOrientationUnknown);
}
- (void)testUIInterfaceUnknownAsNSNumberIsUnknown {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] orientationFromRawValue:[NSNumber numberWithUnsignedInt:UIInterfaceOrientationUnknown]], UIInterfaceOrientationUnknown);
}

#pragma mark - (BOOL)orientationIsSupportedByApplication:(UIInterfaceOrientationMask)orientation
- (BOOL)orientationIsSupportedByApplication:(UIInterfaceOrientationMask)orientation supportedOrientation:(NSArray<NSString *> *)supportedOrientations {
    __weak NSBundle *bundle = OCMClassMock(NSBundle.self);
    OCMStub([bundle objectForInfoDictionaryKey:@"UISupportedInterfaceOrientations"]).andReturn(supportedOrientations);
    return [[[OGAViewControllerOrientationHelper alloc] initWithBundle:bundle] orientationIsSupportedByApplication:orientation];
}
- (void)testApplicationPortraitOnly_supportsPortraitOrientation {
    XCTAssertTrue([self orientationIsSupportedByApplication:UIInterfaceOrientationMaskPortrait
                                       supportedOrientation:@[ @"UIInterfaceOrientationPortrait" ]]);
}
- (void)testApplicationPortraitUpsideDownOnly_supportsPortraitOrientation {
    XCTAssertTrue([self orientationIsSupportedByApplication:UIInterfaceOrientationMaskPortraitUpsideDown
                                       supportedOrientation:@[ @"UIInterfaceOrientationPortraitUpsideDown" ]]);
}
- (void)testApplicationLandscapeOnly_supportsLandscapeOrientation {
    XCTAssertTrue([self orientationIsSupportedByApplication:UIInterfaceOrientationMaskLandscape
                                       supportedOrientation:@[ @"UIInterfaceOrientationLandscape" ]]);
}
- (void)testApplicationLandscapeLeftOnly_supportsLandscapeOrientation {
    XCTAssertTrue([self orientationIsSupportedByApplication:UIInterfaceOrientationMaskLandscapeLeft
                                       supportedOrientation:@[ @"UIInterfaceOrientationLandscapeLeft" ]]);
}
- (void)testApplicationLandscapeRightOnly_supportsLandscapeOrientation {
    XCTAssertTrue([self orientationIsSupportedByApplication:UIInterfaceOrientationMaskLandscapeRight
                                       supportedOrientation:@[ @"UIInterfaceOrientationLandscapeRight" ]]);
}
- (void)testApplicationAllOrientations_supportsAllOrientations {
    XCTAssertTrue([self orientationIsSupportedByApplication:UIInterfaceOrientationMaskAll
                                       supportedOrientation:@[ @"UIInterfaceOrientationMaskPortrait" ]]);
    XCTAssertTrue([self orientationIsSupportedByApplication:UIInterfaceOrientationMaskAll
                                       supportedOrientation:@[ @"UIInterfaceOrientationMaskPortraitUpsideDown" ]]);
    XCTAssertTrue([self orientationIsSupportedByApplication:UIInterfaceOrientationMaskAll
                                       supportedOrientation:@[ @"UIInterfaceOrientationMaskLandscapeLeft" ]]);
    XCTAssertTrue([self orientationIsSupportedByApplication:UIInterfaceOrientationMaskAll
                                       supportedOrientation:@[ @"UIInterfaceOrientationLandscapeRight" ]]);
}

#pragma mark - (NSString*)stringFrom:(UIInterfaceOrientation)orientation
- (void)testStringFromPortraitBehaves {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] stringFrom:UIInterfaceOrientationPortrait], @"portrait");
}
- (void)testStringFromPortraitUpSideDownBehaves {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] stringFrom:UIInterfaceOrientationPortraitUpsideDown], @"portrait");
}
- (void)testStringFromLandscapeLeftBehaves {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] stringFrom:UIInterfaceOrientationLandscapeLeft], @"landscape");
}
- (void)testStringFromLandscapeRightBehaves {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] stringFrom:UIInterfaceOrientationLandscapeRight], @"landscape");
}
- (void)testStringFromUnknownbBehaves {
    XCTAssertEqual([[OGAViewControllerOrientationHelper new] stringFrom:UIInterfaceOrientationUnknown], @"");
}

@end

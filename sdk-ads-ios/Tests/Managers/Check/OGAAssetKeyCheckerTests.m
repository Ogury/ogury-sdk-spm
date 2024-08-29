//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "OGAAssetKeyChecker.h"
#import "OGAAssetKeyManager.h"
#import "OGALog.h"

@interface OGAAssetKeyChecker ()

- (instancetype)initWithAssetKeyManager:(OGAAssetKeyManager *)assetKeyManager
                                 origin:(OguryInternalAdsErrorOrigin)origin
                                    log:(OGALog *)log;

@end

@interface OGAAssetKeyCheckerTests : XCTestCase

@property(nonatomic, retain) OGAAssetKeyManager *assetKeyManager;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, retain) OGAAssetKeyChecker *checker;

@end

@implementation OGAAssetKeyCheckerTests

- (void)setUp {
    self.log = OCMClassMock([OGALog class]);
    self.assetKeyManager = OCMClassMock([OGAAssetKeyManager class]);
    self.checker = [[OGAAssetKeyChecker alloc] initWithAssetKeyManager:self.assetKeyManager
                                                                origin:OguryInternalAdsErrorOriginLoad
                                                                   log:self.log];
}

#pragma mark - Methods

- (void)testCheckForSequence_validAssetKey {
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    OCMStub([self.assetKeyManager checkAssetKeyIsValid:[OCMArg anyObjectRef] origin:OguryInternalAdsErrorOriginLoad]).andReturn(YES);

    OguryError *error;
    XCTAssertTrue([self.checker checkForSequence:sequence error:&error]);

    XCTAssertNil(error);
}

- (void)testCheckForSequence_wrongAssetKey {
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    OguryError *assetKeyError = OCMClassMock([OguryAdsError class]);
    OCMStub([self.assetKeyManager checkAssetKeyIsValid:[OCMArg anyObjectRef] origin:OguryInternalAdsErrorOriginLoad]).andDo(^(NSInvocation *invocation) {
                                                                                                                         OguryError *__autoreleasing *errorPointer = nil;
                                                                                                                         [invocation getArgument:&errorPointer atIndex:2];
                                                                                                                         *errorPointer = assetKeyError;
                                                                                                                     })
        .andReturn(NO);

    OguryError *error;
    XCTAssertFalse([self.checker checkForSequence:sequence error:&error]);

    XCTAssertEqual(error, assetKeyError);
}

@end

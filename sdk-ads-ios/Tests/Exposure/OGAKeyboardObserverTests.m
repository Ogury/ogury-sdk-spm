//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAKeyboardObserver.h"
#import <OCMock/OCMock.h>

@interface OGAKeyboardObserver (Testing)

@property(nonatomic, strong) NSNotificationCenter *notificationCenter;

- (instancetype)initWithNotificationCenter:(NSNotificationCenter *)notificationCenter;

- (void)didReceiveKeyboardWillHideNotification:(NSNotification *)notification;

- (void)didReceiveKKeyboardDidShowNotification:(NSNotification *)notification;

- (void)dealloc;

@end

@interface OGAKeyboardObserverTests : XCTestCase

@property(nonatomic, strong) NSNotificationCenter *notificationCenter;
@property(nonatomic, strong) OGAKeyboardObserver *keyboardObserver;

@end

@implementation OGAKeyboardObserverTests

- (void)setUp {
    self.notificationCenter = OCMClassMock([NSNotificationCenter class]);
    self.keyboardObserver = [[OGAKeyboardObserver alloc] initWithNotificationCenter:self.notificationCenter];
}

- (void)testShared {
    OGAKeyboardObserver *keyboardObserver = [OGAKeyboardObserver shared];
    XCTAssertNotNil(keyboardObserver);
    XCTAssertEqual(keyboardObserver.notificationCenter, [NSNotificationCenter defaultCenter]);
}

- (void)testInitWithNotificationCenter {
    XCTAssertNotNil(self.keyboardObserver);
    XCTAssertEqual(self.notificationCenter, self.keyboardObserver.notificationCenter);
}

- (void)testKeyboardOffScreen {
    NSNotification *notification = OCMClassMock([NSNotification class]);
    [self.keyboardObserver didReceiveKeyboardWillHideNotification:notification];
    XCTAssertFalse(self.keyboardObserver.keyboardOnScreen);
    XCTAssertEqualObjects(self.keyboardObserver.keyboardRect, [NSValue valueWithCGRect:CGRectZero]);
}

- (void)testKeyboardOnScreen {
    NSNotification *notification = OCMClassMock([NSNotification class]);
    CGRect frame = CGRectMake(10, 20, 30, 40);
    OCMStub(notification.userInfo).andReturn(@{UIKeyboardFrameEndUserInfoKey : [NSValue valueWithCGRect:frame]});
    [self.keyboardObserver didReceiveKKeyboardDidShowNotification:notification];
    XCTAssertTrue(self.keyboardObserver.keyboardOnScreen);
    XCTAssertEqualObjects(self.keyboardObserver.keyboardRect, [NSValue valueWithCGRect:frame]);
}

@end

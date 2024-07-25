//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAApplicationViewControllersManager.h"
#import <OCMock/OCMock.h>
#import "OGAThumbnailAdConstants.h"

@interface OGAApplicationViewControllersManager ()

@property(nonatomic, strong) NSNotificationCenter *notificationCenter;
@property(nonatomic, strong) NSMutableDictionary *visibleViewControllers;

- (instancetype)initWithNotificationCenter:(NSNotificationCenter *)notificationCenter visibleViewControllers:(NSMutableDictionary *)visibleViewControllers;

@end

@interface OGAApplicationViewControllersManagerTests : XCTestCase

@property(nonatomic, strong) NSNotificationCenter *notificationCenter;
@property(nonatomic, strong) NSMutableDictionary *visibleViewControllers;
@property(nonatomic, strong) OGAApplicationViewControllersManager *applicationViewControllersManager;
@property(nonatomic, strong) NSDictionary *myControllers;

@end

@implementation OGAApplicationViewControllersManagerTests

- (void)setUp {
    self.myControllers = @{@"keyVC1" : @"VC1", @"keyVC2" : @"VC2"};
    self.notificationCenter = OCMClassMock([NSNotificationCenter class]);
    self.visibleViewControllers = OCMPartialMock([NSMutableDictionary dictionaryWithDictionary:self.myControllers]);
    self.applicationViewControllersManager = OCMPartialMock([[OGAApplicationViewControllersManager alloc] initWithNotificationCenter:self.notificationCenter visibleViewControllers:self.visibleViewControllers]);
}

- (void)tearDown {
    self.myControllers = nil;
    self.notificationCenter = nil;
    self.visibleViewControllers = nil;
    self.applicationViewControllersManager = nil;
}

- (void)testAddVisibleViewController {
    NSDictionary *myControllers = @{@"keyVC3" : @"VC3"};
    [self.applicationViewControllersManager addVisibleViewController:myControllers];
    OCMVerify([self.visibleViewControllers addEntriesFromDictionary:myControllers]);
    OCMVerify([self.notificationCenter postNotificationName:OGAViewControllersUpdated object:nil]);
}

- (void)testRemoveVisibleViewController {
    NSDictionary *myControllers = @{@"keyVC1" : @"VC2"};
    [self.applicationViewControllersManager removeVisibleViewController:myControllers];
    OCMVerify([self.visibleViewControllers removeObjectForKey:myControllers.allKeys.firstObject]);
    OCMVerify([self.notificationCenter postNotificationName:OGAViewControllersUpdated object:nil]);
}

- (void)testGetVisibleBundles {
    XCTAssertEqualObjects([self.applicationViewControllersManager getVisibleBundles], self.myControllers.allValues);
}

- (void)testGetVisibleViewControllers {
    XCTAssertEqualObjects([self.applicationViewControllersManager getVisibleViewControllers], self.myControllers.allKeys);
}

@end

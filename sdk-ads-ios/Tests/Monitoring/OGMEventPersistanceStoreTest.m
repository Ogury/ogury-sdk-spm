//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "OGAAdMonitorEvent.h"
#import "OGAUserDefaultsStore.h"
#import "OGMEventPersistanceStore.h"
#import "OGMMonitorManager.h"
#import "OGMOSLogMonitor.h"
#import "OGAAdMonitorEvent+Tests.h"

@interface OGAUserDefaultsStore ()

@property(nonatomic, strong) NSUserDefaults *userDefaults;

@end

@interface OGMEventPersistanceStore ()

@property(nonatomic, strong) OGAUserDefaultsStore *userDefaultsStore;

@end

@interface OGMEventPersistanceStoreTest : XCTestCase

@property(nonatomic, strong) OGMMonitorEvent *event;
@property(nonatomic, strong) OGAUserDefaultsStore *userDefaultStore;

@end

static NSInteger const TestTimestamp = 1000;
static NSString *const TestSessionId = @"1001";
static NSString *const TestEventCode = @"LT-100";
static NSString *const TestEventName = @"test";
static OGMDispatchType const TestDispatchType = OGMDispatchTypeImmediate;
static NSString *const TestAdUnitId = @"testAdunitId";
static NSString *const TestCampaignId = @"testCampaignId";
static NSString *const TestCreativeId = @"testCreativeId";
static NSString *const TestDetail = @"detailTest";
static NSString *const TestContent = @"detailContentTest";

static NSString *const TestUserDefaultSuiteName = @"TestDefaults";

@implementation OGMEventPersistanceStoreTest

- (void)setUp {
    NSDictionary *firstDictionnary = @{@"name" : @"dsp", @"value" : @"{\"creative_id\": \"123\", \"region\":\"east-us\"}", @"version" : @2};
    NSDictionary *secondDictionnary = @{@"name" : @"vast_version", @"value" : @"4.0", @"version" : @1};
    NSArray *extras = @[ firstDictionnary, secondDictionnary ];
    self.event = OCMPartialMock([[OGAAdMonitorEvent alloc] initWithTimestamp:[NSNumber numberWithInt:TestTimestamp]
                                                                   sessionId:TestSessionId
                                                                   eventCode:TestEventCode
                                                                   eventName:TestEventName
                                                                dispatchType:TestDispatchType
                                                                    adUnitId:TestAdUnitId
                                                                   mediation:nil
                                                                  campaignId:TestCampaignId
                                                                  creativeId:TestCreativeId
                                                                      extras:extras
                                                           detailsDictionary:@{TestDetail : TestContent}
                                                                   errorType:nil
                                                                errorContent:nil]);
    self.userDefaultStore = [[OGAUserDefaultsStore alloc] init];
    self.userDefaultStore.userDefaults = [[NSUserDefaults alloc] initWithSuiteName:TestUserDefaultSuiteName];
}

- (void)testUserdefault {
    OGMEventPersistanceStore *eventStore = [[OGMEventPersistanceStore alloc] init];
    eventStore.userDefaultsStore = self.userDefaultStore;

    [eventStore saveEvents:@[ self.event ]];

    NSArray *array = [eventStore getEvents];
    OGMMonitorEvent *event = array[0];

    XCTAssertEqual([array count], 1);
    XCTAssertNotNil(event);

    [eventStore cleanEvents];
    XCTAssertEqual([[eventStore getEvents] count], 0);
}

@end

//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "OGAAdMonitorEvent.h"
#import "OGMMonitorManager.h"
#import "OGMOSLogMonitor.h"

@interface OGMMonitorManager ()

@property(nonnull, retain) NSMutableArray<id<OGMMonitorable>> *monitors;

- (instancetype)init;

@end

@interface OGMMonitorManagerTest : XCTestCase

@property(nonatomic, strong) OGMMonitorEvent *event;

@end

@interface OGAAdMonitorEvent ()
- (instancetype)initWithTimestamp:(NSNumber *)timestamp
                        sessionId:(NSString *)sessionId
                        eventCode:(NSString *)eventCode
                        eventName:(NSString *)eventName
                     dispatchType:(OGMDispatchType)dispatchType
                         adUnitId:(NSString *)adUnitId
                        mediation:(OguryMediation *)mediation
                       campaignId:(NSString *_Nullable)campaignId
                       creativeId:(NSString *_Nullable)creativeId
                           extras:(NSArray *_Nullable)extras
                detailsDictionary:(NSDictionary *_Nullable)detailsDictionary
                        errorType:(NSString *_Nullable)errorType
                     errorContent:(NSDictionary *)errorContent;
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

@implementation OGMMonitorManagerTest

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
}
- (void)testMonitor {
    OGMMonitorManager *manager = [[OGMMonitorManager alloc] init];

    XCTAssertEqual([manager.monitors count], 0);

    OGMOSLogMonitor *monitorMock = [[OGMOSLogMonitor alloc] init];

    [manager addMonitor:monitorMock];
    [manager monitor:self.event];

    XCTAssertEqual([manager.monitors count], 1);
    OCMVerify([monitorMock monitor:self.event]);
}

@end

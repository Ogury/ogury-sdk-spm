//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "OGAMonitoringConstants.h"
#import "OGMMonitorEvent.h"
#import "OguryError+utility.h"

@interface OGMMonitorEventTests : XCTestCase

@property(nonatomic, strong) OGMMonitorEvent *event;

@end

static NSInteger const TestTimestamp = 1000;
static NSString *const TestSessionId = @"1001";
static NSString *const TestEventCode = @"LT-100";
static NSString *const TestEventName = @"test";
static OGMDispatchType const TestDispatchType = OGMDispatchTypeImmediate;
static NSString *const TestDetail = @"detailTest";
static NSString *const TestContent = @"detailContentTest";

@implementation OGMMonitorEventTests

- (void)setUp {
    self.event = OCMPartialMock([[OGMMonitorEvent alloc] initEventWithTimestamp:[NSNumber numberWithInt:TestTimestamp]
                                                                      sessionId:TestSessionId
                                                                      eventCode:TestEventCode
                                                                      eventName:TestEventName
                                                                   dispatchType:TestDispatchType
                                                              detailsDictionary:@{TestDetail : TestContent}
                                                                      errorType:nil
                                                                   errorContent:nil]);
}

- (void)testAsDictionary {
    NSDictionary *dict = [self.event asDisctionary];

    XCTAssertEqualObjects(dict[OGAMonitorEventBodyTimestamp], @(TestTimestamp));
    XCTAssertEqualObjects(dict[OGAMonitorEventBodySessionId], TestSessionId);
    XCTAssertEqualObjects(dict[OGAMonitorEventBodyEventCode], TestEventCode);
    XCTAssertEqualObjects(dict[OGAMonitorEventBodyEventName], TestEventName);

    XCTAssertEqualObjects(dict[OGAMonitorEventBodyDispatchMethod], OGAMonitorEventBodyDispatchMethodImmediate);

    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{TestDetail : TestContent} options:0 error:&err];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    XCTAssertTrue([dict[OGAMonitorEventBodyDetails] isEqual:jsonString]);
}

- (void)testNSCoding {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.event];
    OGMMonitorEvent *retrievedEvent = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSMutableDictionary *mutableEventDict = [self.event.asDisctionary mutableCopy];
    mutableEventDict[OGAMonitorEventBodyDispatchMethod] = OGAMonitorEventBodyDispatchMethodDeferred;
    // event are always deferred when retrieved from persistance, hence this value is not encoded, but directly assigned in decoding phase

    XCTAssertTrue([mutableEventDict isEqualToDictionary:retrievedEvent.asDisctionary]);
}

@end

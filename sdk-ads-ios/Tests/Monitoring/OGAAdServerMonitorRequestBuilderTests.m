//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "OGAAdMonitorEvent.h"
#import "OGAAdServerMonitorRequestBuilder.h"
#import "OGAAdMonitorEvent+Tests.h"

@interface OGAAdServerMonitorRequestBuilderTests : XCTestCase
@property(nonatomic, retain) OGAAdServerMonitorRequestBuilder *requestBuilder;
@end

@implementation OGAAdServerMonitorRequestBuilderTests

- (void)setUp {
    self.requestBuilder = OCMPartialMock([[OGAAdServerMonitorRequestBuilder alloc] initWithUrl:[NSURL URLWithString:@"http://www.dummy.fr"]]);
}

- (void)testWhenRequestIsBuilt_ThenDeviceNameIsNeverCalled {
    NSDictionary *firstDictionnary = @{@"name" : @"dsp", @"value" : @"{\"creative_id\": \"123\", \"region\":\"east-us\"}", @"version" : @2};
    NSDictionary *secondDictionnary = @{@"name" : @"vast_version", @"value" : @"4.0", @"version" : @1};
    NSArray *extras = @[ firstDictionnary, secondDictionnary ];
    id currentDevice = OCMPartialMock([UIDevice currentDevice]);

    OCMReject([currentDevice name]);
    OGAAdMonitorEvent *event = [[OGAAdMonitorEvent alloc] initWithTimestamp:@1000
                                                                  sessionId:@"session"
                                                                  eventCode:@"eventCode"
                                                                  eventName:@"event"
                                                               dispatchType:OGMDispatchTypeImmediate
                                                                   adUnitId:@"adUnit"
                                                                  mediation:nil
                                                                 campaignId:@"campaignId"
                                                                 creativeId:@"creativeId"
                                                                     extras:extras
                                                          detailsDictionary:@{@"Dictionary" : @YES}
                                                                  errorType:nil
                                                               errorContent:nil];
    [self.requestBuilder buildRequestWithEvents:@[ event ]];
    // stop mocking the singleton
    [currentDevice stopMocking];
}

@end

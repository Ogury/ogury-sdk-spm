//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAAdDisplayerCallEventListenersInformation.h"

@interface OGAAdDisplayerCallEventListenersInformationTests : XCTestCase

@property(nonatomic, copy) NSString *trigger;
@property(nonatomic, strong) NSDictionary *paramters;

@end

@interface OGAAdDisplayerCallEventListenersInformation ()

@property(nonatomic, copy) NSString *trigger;
@property(nonatomic, strong) NSDictionary *parameters;

- (instancetype)initWithEvent:(NSString *)trigger parameters:(NSDictionary *)paramters;

@end

@implementation OGAAdDisplayerCallEventListenersInformationTests

- (void)setUp {
    self.trigger = @"trigger";
    self.paramters = @{@"param1" : @"value"};
}

- (void)testShouldInstantiate {
    OGAAdDisplayerCallEventListenersInformation *information = [[OGAAdDisplayerCallEventListenersInformation alloc] initWithEvent:self.trigger parameters:self.paramters];
    XCTAssertNotNil(information);
    XCTAssertTrue([information.trigger isEqualToString:@"trigger"]);
    XCTAssertTrue([information.parameters isEqualToDictionary:@{@"param1" : @"value"}]);
}

- (void)testShouldReturnJavascriptCommand {
    OGAAdDisplayerCallEventListenersInformation *information = [[OGAAdDisplayerCallEventListenersInformation alloc] initWithEvent:self.trigger parameters:self.paramters];
    NSString *command = [information toJavascriptCommand];
    XCTAssertTrue([command isEqualToString:@"ogySdkMraidGateway.callEventListeners(\"trigger\", {\"param1\":\"value\"})"]);
}

@end

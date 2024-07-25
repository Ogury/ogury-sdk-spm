//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAProfigRequestBuilder.h"

@interface OGAProfigRequestBuilderTests : XCTestCase

@end

@implementation OGAProfigRequestBuilderTests

NSString *const OGAProfigRequestBuilderTestsAccept = @"Accept";
NSString *const OGAProfigRequestBuilderTestsAcceptEncoding = @"Accept-Encoding";
NSString *const OGAProfigRequestBuilderTestsContentType = @"Content-Type";
NSString *const OGAProfigRequestBuilderTestsContentEncoding = @"Content-Encoding";
NSString *const OGAProfigRequestBuilderTestsContentLength = @"Content-Length";

- (void)testBuild {
    NSURLRequest *request = [OGAProfigRequestBuilder build];
    XCTAssertNotNil(request);
    XCTAssertNotNil(request.HTTPBody);
    XCTAssertTrue([[request HTTPMethod] isEqualToString:@"POST"]);
    XCTAssertNotNil(request.URL);
    NSDictionary *header = [request allHTTPHeaderFields];
    XCTAssertEqual([header count], 5);
    XCTAssertNotNil([header valueForKey:OGAProfigRequestBuilderTestsAccept]);
    XCTAssertNotNil([header valueForKey:OGAProfigRequestBuilderTestsAcceptEncoding]);
    XCTAssertNotNil([header valueForKey:OGAProfigRequestBuilderTestsContentEncoding]);
    XCTAssertNotNil([header valueForKey:OGAProfigRequestBuilderTestsContentType]);
    XCTAssertNotNil([header valueForKey:OGAProfigRequestBuilderTestsContentLength]);
}

@end

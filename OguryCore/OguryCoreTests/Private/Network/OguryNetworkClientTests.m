//
//  Copyright © 12/11/2020-present Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OguryNetworkClient.h"
#import "OguryNetworkClientPrivateProperties.h"
#import "URLProtocolMock.h"
#import "OguryNetworkClientError.h"

@interface OguryNetworkClient ()

+ (void)handleHTTPURLResponse:(NSHTTPURLResponse *)httpURLResponse data:(NSData *)data completionHandler:(void(^)(NSData * _Nullable result, NSError * _Nullable error))completionHandler;

+ (void)handleHTTPURLResponse:(NSHTTPURLResponse *)httpURLResponse data:(NSData *)data completionHandlerWithUrlResponse:(void(^)(NSData * _Nullable result, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

@end

@interface OguryNetworkClientTests : XCTestCase

#pragma mark - Properties

@property (nonatomic, strong) OguryNetworkClient *networkClient;

@end

@implementation OguryNetworkClientTests

#pragma mark - Constants

static NSString * const DefaultRawURL = @"https://www.github.com";
static NSString * const DefaultRawData = @"Hello world!";

#pragma mark - Methods

- (void)setUp {
    // Remove all mock data
    URLProtocolMock.mockData = @{};

    // Network client retrieval
    self.networkClient = [OguryNetworkClient shared];

    // Mock network calls
    NSURLSessionConfiguration *mockConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    mockConfiguration.protocolClasses = @[[URLProtocolMock class]];

    self.networkClient.urlSession = [NSURLSession sessionWithConfiguration:mockConfiguration];
}

- (void)testShouldHandleSuccessfullResponse {
    NSHTTPURLResponse *httpURLResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:DefaultRawURL] statusCode:200 HTTPVersion:nil headerFields:nil];

    XCTestExpectation *testExpectation = [self expectationWithDescription:@"it should handle successful response"];

    [OguryNetworkClient handleHTTPURLResponse:httpURLResponse data:[DefaultRawData dataUsingEncoding:NSUTF8StringEncoding] completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        XCTAssertTrue([[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] isEqualToString:DefaultRawData]);
        XCTAssertNil(error);
        [testExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testShouldHandleSuccessfullResponseWithUrlResponse {
    NSHTTPURLResponse *httpURLResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:DefaultRawURL] statusCode:200 HTTPVersion:nil headerFields:nil];

    XCTestExpectation *testExpectation = [self expectationWithDescription:@"it should handle successful response"];

    [OguryNetworkClient handleHTTPURLResponse:httpURLResponse data:[DefaultRawData dataUsingEncoding:NSUTF8StringEncoding] completionHandlerWithUrlResponse:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertTrue([[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] isEqualToString:DefaultRawData]);
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        [testExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testShouldHandleClientErrorResponse {
    NSHTTPURLResponse *httpURLResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:DefaultRawURL] statusCode:400 HTTPVersion:nil headerFields:nil];

    XCTestExpectation *testExpectation = [self expectationWithDescription:@"it should handle successful response"];

    [OguryNetworkClient handleHTTPURLResponse:httpURLResponse data:[DefaultRawData dataUsingEncoding:NSUTF8StringEncoding] completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        XCTAssertNil(data);
        XCTAssertNotNil(error);
        XCTAssertEqual(error.code, OguryNetworkClientErrorTypeClientError);
        [testExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testShouldHandleClientErrorResponseWithUrlResponse400 {
    NSHTTPURLResponse *httpURLResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:DefaultRawURL] statusCode:400 HTTPVersion:nil headerFields:nil];

    XCTestExpectation *testExpectation = [self expectationWithDescription:@"it should handle successful response"];

    [OguryNetworkClient handleHTTPURLResponse:httpURLResponse data:[DefaultRawData dataUsingEncoding:NSUTF8StringEncoding] completionHandlerWithUrlResponse:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNotNil(data);
        XCTAssertNotNil(response);
        XCTAssertNotNil(error);
        XCTAssertEqual(error.code, OguryNetworkClientErrorTypeClientError);
        [testExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testShouldHandleServerErrorResponse {
    NSHTTPURLResponse *httpURLResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:DefaultRawURL] statusCode:500 HTTPVersion:nil headerFields:nil];

    XCTestExpectation *testExpectation = [self expectationWithDescription:@"it should handle successful response"];

    [OguryNetworkClient handleHTTPURLResponse:httpURLResponse data:[DefaultRawData dataUsingEncoding:NSUTF8StringEncoding] completionHandler:^(NSData * _Nullable result, NSError * _Nullable error) {
        XCTAssertNil(result);
        XCTAssertNotNil(error);
        XCTAssertEqual(error.code, OguryNetworkClientErrorTypeServerError);
        [testExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testShouldHandleServerErrorResponseWithUrlResponse {
    NSHTTPURLResponse *httpURLResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:DefaultRawURL] statusCode:500 HTTPVersion:nil headerFields:nil];

    XCTestExpectation *testExpectation = [self expectationWithDescription:@"it should handle successful response"];

    [OguryNetworkClient handleHTTPURLResponse:httpURLResponse data:[DefaultRawData dataUsingEncoding:NSUTF8StringEncoding] completionHandlerWithUrlResponse:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNil(data);
        XCTAssertNotNil(response);
        XCTAssertNotNil(error);
        XCTAssertEqual(error.code, OguryNetworkClientErrorTypeServerError);
        [testExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testShouldHandleUnknownResponse {
    NSHTTPURLResponse *httpURLResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:DefaultRawURL] statusCode:600 HTTPVersion:nil headerFields:nil];

    XCTestExpectation *testExpectation = [self expectationWithDescription:@"it should handle successful response"];

    [OguryNetworkClient handleHTTPURLResponse:httpURLResponse data:[DefaultRawData dataUsingEncoding:NSUTF8StringEncoding] completionHandler:^(NSData * _Nullable result, NSError * _Nullable error) {
        XCTAssertNil(result);
        XCTAssertNotNil(error);
        XCTAssertEqual(error.code, OguryNetworkClientErrorTypeUnknown);
        [testExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testShouldHandleUnknownResponseWithUrlResponse {
    NSHTTPURLResponse *httpURLResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:DefaultRawURL] statusCode:600 HTTPVersion:nil headerFields:nil];

    XCTestExpectation *testExpectation = [self expectationWithDescription:@"it should handle successful response"];

    [OguryNetworkClient handleHTTPURLResponse:httpURLResponse data:[DefaultRawData dataUsingEncoding:NSUTF8StringEncoding] completionHandlerWithUrlResponse:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNil(data);
        XCTAssertNotNil(response);
        XCTAssertNotNil(error);
        XCTAssertEqual(error.code, OguryNetworkClientErrorTypeUnknown);
        [testExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testShouldReturnErrorForNetworkError {
    NSURL *testURL = [NSURL URLWithString:DefaultRawURL];

    // Mock data
    URLProtocolMock.shouldReturnError = YES;

    XCTestExpectation *testExpectation = [self expectationWithDescription:@"it should return data"];

    [self.networkClient performRequest:[[NSURLRequest alloc] initWithURL:testURL] completionHandler:^(NSData * _Nullable result, NSError * _Nullable error) {
        XCTAssertNil(result);
        XCTAssertNotNil(error);

        [testExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testShouldReturnErrorForNetworkErrorWithUrlResponse {
    NSURL *testURL = [NSURL URLWithString:DefaultRawURL];

    // Mock data
    URLProtocolMock.shouldReturnError = YES;

    XCTestExpectation *testExpectation = [self expectationWithDescription:@"it should return data"];

    [self.networkClient performRequest:[[NSURLRequest alloc] initWithURL:testURL] completionHandlerWithUrlResponse:^(NSData * _Nullable result, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertNil(result);
        XCTAssertNotNil(error);
        XCTAssertNil(response);

        [testExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testShouldReturnData {
    NSURL *testURL = [NSURL URLWithString:DefaultRawURL];

    // Mock data
    URLProtocolMock.mockData = @{
        testURL: [DefaultRawData dataUsingEncoding:NSUTF8StringEncoding]
    };
    URLProtocolMock.mockStatusCodeForURL = @{
        testURL: @(200)
    };

    XCTestExpectation *testExpectation = [self expectationWithDescription:@"it should return data"];

    [self.networkClient performRequest:[[NSURLRequest alloc] initWithURL:testURL] completionHandler:^(NSData * _Nullable result, NSError * _Nullable error) {
        XCTAssertTrue([[[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding] isEqualToString:DefaultRawData]);
        XCTAssertNil(error);

        [testExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testShouldReturnErrorFromInvalidURL {
    NSURL *testURL = [NSURL URLWithString:@""];

    XCTestExpectation *testExpectation = [self expectationWithDescription:@"it should return an error from invalid URL"];

    [self.networkClient performRequest:[[NSURLRequest alloc] initWithURL:testURL] completionHandler:^(NSData * _Nullable result, NSError * _Nullable error) {
        XCTAssertNil(result);
        XCTAssertNotNil(error);
        XCTAssertEqual(error.code, OguryNetworkClientErrorTypeInvalidURL);

        [testExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testShouldReturnClientError {
    NSURL *testURL = [NSURL URLWithString:DefaultRawURL];

    // Mock data
    URLProtocolMock.mockStatusCodeForURL = @{
        testURL: @(400)
    };

    XCTestExpectation *testExpectation = [self expectationWithDescription:@"it should return client error"];

    [self.networkClient performRequest:[[NSURLRequest alloc] initWithURL:testURL] completionHandler:^(NSData * _Nullable result, NSError * _Nullable error) {
        XCTAssertNil(result);
        XCTAssertNotNil(error);
        XCTAssertEqual(error.code, OguryNetworkClientErrorTypeClientError);

        [testExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testShouldReturnServerError {
    NSURL *testURL = [NSURL URLWithString:DefaultRawURL];

    // Mock data
    URLProtocolMock.mockStatusCodeForURL = @{
        testURL: @(500)
    };

    XCTestExpectation *testExpectation = [self expectationWithDescription:@"it should return server error"];

    [self.networkClient performRequest:[[NSURLRequest alloc] initWithURL:testURL] completionHandler:^(NSData * _Nullable result, NSError * _Nullable error) {
        XCTAssertNil(result);
        XCTAssertNotNil(error);
        XCTAssertEqual(error.code, OguryNetworkClientErrorTypeServerError);

        [testExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end

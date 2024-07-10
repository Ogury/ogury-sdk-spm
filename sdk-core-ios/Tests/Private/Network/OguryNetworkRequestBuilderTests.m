//
//  Copyright © 10/11/2020-present Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OguryNetworkRequestBuilder.h"

@interface OguryNetworkRequestBuilder ()

+ (NSString * _Nullable)httpMethodFromMethod:(OguryNetworkRequestMethod)httpMethod;

@end

@interface OguryNetworkRequestBuilderTests : XCTestCase

@end

@implementation OguryNetworkRequestBuilderTests

#pragma mark - Constants

static NSString * const DefaultURL = @"https://www.google.com";

#pragma mark - Methods

- (void)testShouldInstantiateWithHTTPVerbAndURL {
    NSURL *url = [NSURL URLWithString:DefaultURL];

    OguryNetworkRequestBuilder *requestBuilder = [[OguryNetworkRequestBuilder alloc] initWithHTTPMethod:OguryNetworkRequestHTTPMethodGET andURL:url];

    XCTAssertNotNil(requestBuilder);
    XCTAssertEqual(requestBuilder.method, OguryNetworkRequestHTTPMethodGET);
    XCTAssertEqual(requestBuilder.url, url);
}

- (void)testShouldSetValueForHeader {
    NSURL *url = [NSURL URLWithString:DefaultURL];

    OguryNetworkRequestBuilder *requestBuilder = [[OguryNetworkRequestBuilder alloc] initWithHTTPMethod:OguryNetworkRequestHTTPMethodGET andURL:url];
    [requestBuilder setValue:OguryNetworkRequestBuilderHeaderApplicationJSON forHeader:OguryNetworkRequestBuilderHeaderAccept];

    XCTAssertNotNil(requestBuilder);
    XCTAssertEqual(requestBuilder.headers.count, 1);
    XCTAssertEqual(requestBuilder.headers[OguryNetworkRequestBuilderHeaderAccept], OguryNetworkRequestBuilderHeaderApplicationJSON);
}

- (void)testShouldAddAdditionalHeaders {
    NSURL *url = [NSURL URLWithString:DefaultURL];

    OguryNetworkRequestBuilder *requestBuilder = [[OguryNetworkRequestBuilder alloc] initWithHTTPMethod:OguryNetworkRequestHTTPMethodGET andURL:url];
    [requestBuilder addHeaders:@{
        OguryNetworkRequestBuilderHeaderContentType: OguryNetworkRequestBuilderHeaderApplicationJSON,
        OguryNetworkRequestBuilderHeaderContentEncoding: OguryNetworkRequestBuilderHeaderEncodingGZIP
    }];

    XCTAssertNotNil(requestBuilder);
    XCTAssertEqual(requestBuilder.headers.count, 2);
    XCTAssertEqual(requestBuilder.headers[OguryNetworkRequestBuilderHeaderContentType], OguryNetworkRequestBuilderHeaderApplicationJSON);
    XCTAssertEqual(requestBuilder.headers[OguryNetworkRequestBuilderHeaderContentEncoding], OguryNetworkRequestBuilderHeaderEncodingGZIP);
}

- (void)testShouldSetPayload {
    NSURL *url = [NSURL URLWithString:DefaultURL];

    OguryNetworkRequestBuilder *requestBuilder = [[OguryNetworkRequestBuilder alloc] initWithHTTPMethod:OguryNetworkRequestHTTPMethodGET andURL:url];
    requestBuilder.payload = [@"Data" dataUsingEncoding:NSUTF8StringEncoding];

    XCTAssertNotNil(requestBuilder);
    XCTAssertNotNil(requestBuilder.payload);
}

- (void)testShouldSetQueryItems {
    NSURL *url = [NSURL URLWithString:DefaultURL];

    OguryNetworkRequestBuilder *requestBuilder = [[OguryNetworkRequestBuilder alloc] initWithHTTPMethod:OguryNetworkRequestHTTPMethodGET andURL:url];
    [requestBuilder setQueryItems:@[
        [[NSURLQueryItem alloc] initWithName:@"type" value:@"json"]
    ]];

    XCTAssertNotNil(requestBuilder);
    XCTAssertEqual(requestBuilder.queryItems.count, 1);

    NSURLRequest *request = [requestBuilder build];

    XCTAssertTrue([request.URL.absoluteString containsString:@"?type=json"]);
}

- (void)testShouldAddQueryItem {
    NSURL *url = [NSURL URLWithString:DefaultURL];

    OguryNetworkRequestBuilder *requestBuilder = [[OguryNetworkRequestBuilder alloc] initWithHTTPMethod:OguryNetworkRequestHTTPMethodGET andURL:url];
    [requestBuilder addQueryItem:[[NSURLQueryItem alloc] initWithName:@"type" value:@"json"]];

    XCTAssertNotNil(requestBuilder);
    XCTAssertEqual(requestBuilder.queryItems.count, 1);

    NSURLRequest *request = [requestBuilder build];

    XCTAssertTrue([request.URL.absoluteString containsString:@"?type=json"]);
}

- (void)testShouldAddQueryItems {
    NSURL *url = [NSURL URLWithString:DefaultURL];

    OguryNetworkRequestBuilder *requestBuilder = [[OguryNetworkRequestBuilder alloc] initWithHTTPMethod:OguryNetworkRequestHTTPMethodGET andURL:url];
    [requestBuilder addQueryItems:@[
        [[NSURLQueryItem alloc] initWithName:@"type" value:@"json"],
        [[NSURLQueryItem alloc] initWithName:@"value" value:@"text"]
    ]];

    XCTAssertNotNil(requestBuilder);
    XCTAssertEqual(requestBuilder.queryItems.count, 2);
}

- (void)testShouldBuildWithValidURL {
    NSURL *url = [NSURL URLWithString:DefaultURL];

    OguryNetworkRequestBuilder *requestBuilder = [[OguryNetworkRequestBuilder alloc] initWithHTTPMethod:OguryNetworkRequestHTTPMethodGET andURL:url];

    NSURLRequest *request = [requestBuilder build];

    XCTAssertNotNil(request);
}

- (void)testShouldNotBuildWithInvalidURL {
    NSURL *url = [NSURL URLWithString:@""];

    OguryNetworkRequestBuilder *requestBuilder = [[OguryNetworkRequestBuilder alloc] initWithHTTPMethod:OguryNetworkRequestHTTPMethodGET andURL:url];

    NSURLRequest *request = [requestBuilder build];

    XCTAssertNil(request);
}

- (void)testShouldBuildWithValidURLAndAdditionalHeaders {
    NSURL *url = [NSURL URLWithString:DefaultURL];
    NSError *error;

    OguryNetworkRequestBuilder *requestBuilder = [[OguryNetworkRequestBuilder alloc] initWithHTTPMethod:OguryNetworkRequestHTTPMethodGET andURL:url];
    [requestBuilder addHeaders:@{
        OguryNetworkRequestBuilderHeaderContentType: OguryNetworkRequestBuilderHeaderApplicationJSON,
        OguryNetworkRequestBuilderHeaderContentEncoding: OguryNetworkRequestBuilderHeaderEncodingGZIP
    }];

    NSURLRequest *request = [requestBuilder build];

    XCTAssertNotNil(request);
    XCTAssertNil(error);
    XCTAssertEqual(request.allHTTPHeaderFields.count, 4);
}

- (void)testShouldBuildWithValidURLAndQueryItems {
    NSURL *url = [NSURL URLWithString:DefaultURL];

    OguryNetworkRequestBuilder *requestBuilder = [[OguryNetworkRequestBuilder alloc] initWithHTTPMethod:OguryNetworkRequestHTTPMethodGET andURL:url];
    [requestBuilder setQueryItems:@[
        [[NSURLQueryItem alloc] initWithName:@"type" value:@"json"],
        [[NSURLQueryItem alloc] initWithName:@"value" value:@"text"]
    ]];

    NSURLRequest *request = [requestBuilder build];

    XCTAssertNotNil(request);
    XCTAssertTrue([request.URL.absoluteString containsString:@"?type=json&value=text"]);
}

- (void)testShouldBuildWithValidURLAndPayload {
    NSURL *url = [NSURL URLWithString:DefaultURL];

    OguryNetworkRequestBuilder *requestBuilder = [[OguryNetworkRequestBuilder alloc] initWithHTTPMethod:OguryNetworkRequestHTTPMethodGET andURL:url];
    requestBuilder.payload = [@"Data" dataUsingEncoding:NSUTF8StringEncoding];

    NSURLRequest *request = [requestBuilder build];

    XCTAssertNotNil(request.HTTPBody);
    XCTAssertEqual(request.allHTTPHeaderFields.count, 5);
    XCTAssertEqual(request.allHTTPHeaderFields[OguryNetworkRequestBuilderHeaderContentType], OguryNetworkRequestBuilderHeaderApplicationJSON);
    XCTAssertEqual(request.allHTTPHeaderFields[OguryNetworkRequestBuilderHeaderAcceptEncoding], OguryNetworkRequestBuilderHeaderEncodingGZIP);
    XCTAssertEqual(request.allHTTPHeaderFields[OguryNetworkRequestBuilderHeaderContentType], OguryNetworkRequestBuilderHeaderApplicationJSON);
    XCTAssertEqual(request.allHTTPHeaderFields[OguryNetworkRequestBuilderHeaderContentEncoding], OguryNetworkRequestBuilderHeaderEncodingGZIP);
    XCTAssertEqual(request.allHTTPHeaderFields[OguryNetworkRequestBuilderHeaderContentLength], @(24).stringValue);
    XCTAssertEqual(request.HTTPBody.length, 24);
}

- (void)testShouldReturnHTTPMethodForGET {
    NSString *httpMethod = [OguryNetworkRequestBuilder httpMethodFromMethod:OguryNetworkRequestHTTPMethodGET];

    XCTAssertTrue([httpMethod isEqualToString:@"GET"]);
}

- (void)testShouldReturnHTTPMethodForPOST {
    NSString *httpMethod = [OguryNetworkRequestBuilder httpMethodFromMethod:OguryNetworkRequestHTTPMethodPOST];

    XCTAssertTrue([httpMethod isEqualToString:@"POST"]);
}

- (void)testShouldReturnHTTPMethodForPUT {
    NSString *httpMethod = [OguryNetworkRequestBuilder httpMethodFromMethod:OguryNetworkRequestHTTPMethodPUT];

    XCTAssertTrue([httpMethod isEqualToString:@"PUT"]);
}

- (void)testShouldReturnHTTPMethodForDELETE {
    NSString *httpMethod = [OguryNetworkRequestBuilder httpMethodFromMethod:OguryNetworkRequestHTTPMethodDELETE];

    XCTAssertTrue([httpMethod isEqualToString:@"DELETE"]);
}

@end

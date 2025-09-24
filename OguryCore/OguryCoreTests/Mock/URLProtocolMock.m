//
//  Copyright © 12/11/2020-present Ogury. All rights reserved.
//

#import "URLProtocolMock.h"

@implementation URLProtocolMock

#pragma mark - Constants

static NSDictionary<NSURL *, NSData *> *_mockDataForURL;
static NSDictionary<NSURL *, NSNumber *> *_mockStatusCodeForURL;
static BOOL _shouldReturnError;

@dynamic mockData;

#pragma mark - Methods

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    return true;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    NSNumber *statusCode = @(200);

    if (self.request && self.request.URL) {
        // Mock data
        [self.client URLProtocol:self didLoadData: _mockDataForURL[self.request.URL]];

        // Mock status code
        NSNumber *mockStatusCode = _mockStatusCodeForURL[self.request.URL];
        if (mockStatusCode) {
            statusCode = mockStatusCode;
        }
    }

    NSHTTPURLResponse *httpURLResponse = [[NSHTTPURLResponse alloc]  initWithURL:self.request.URL statusCode:statusCode.integerValue HTTPVersion:@"" headerFields:nil];

    if (_shouldReturnError) {
        [self.client URLProtocol:self didFailWithError:[[NSError alloc] initWithDomain:@"" code:-1 userInfo:nil]];
        _shouldReturnError = NO;
    } else {
        [self.client URLProtocol:self didReceiveResponse:httpURLResponse cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    }

    [self.client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading {
    // Not implemented
}

+ (NSDictionary<NSURL *,NSData *> *)mockData {
    if (!_mockDataForURL) {
        _mockDataForURL = [NSDictionary dictionary];
    }

    return _mockDataForURL;
}

+ (void)setMockData:(NSDictionary<NSURL *, NSData *> *)mockData {
    _mockDataForURL = mockData;
}

+ (NSDictionary<NSURL *,NSNumber *> *)mockStatusCodeForURL {
    if (!_mockStatusCodeForURL) {
        _mockStatusCodeForURL = [NSDictionary dictionary];
    }

    return _mockStatusCodeForURL;
}

+ (void)setMockStatusCodeForURL:(NSDictionary<NSURL *, NSNumber *> *)mockData {
    _mockStatusCodeForURL = mockData;
}

+ (BOOL)shouldReturnError {
    return _shouldReturnError;
}

+ (void)setShouldReturnError:(BOOL)shouldReturnError {
    _shouldReturnError = shouldReturnError;
}

+ (void)clearMockData {
    self.mockData = [NSDictionary dictionary];
    self.mockStatusCodeForURL = [NSDictionary dictionary];
    self.shouldReturnError = NO;
}

@end

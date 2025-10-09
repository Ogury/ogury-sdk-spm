//
//  Copyright © 10/11/2020-present Ogury. All rights reserved.
//

#import "OguryNetworkRequestBuilder.h"
#import "OguryNetworkClientError.h"
#import <zlib.h>

@interface OguryNetworkRequestBuilder ()

@property (nonatomic, strong, readwrite) NSDictionary<NSString *, NSString *> *headers;
@property (nonatomic, strong, readwrite) NSArray<NSURLQueryItem *> *queryItems;
@property (nonatomic, strong, readwrite) NSData *payload;

@end

@implementation OguryNetworkRequestBuilder

#pragma mark - Constants

NSString * const OguryNetworkRequestBuilderHeaderAccept = @"Accept";
NSString * const OguryNetworkRequestBuilderHeaderAcceptEncoding = @"Accept-Encoding";
NSString * const OguryNetworkRequestBuilderHeaderContentType = @"Content-Type";
NSString * const OguryNetworkRequestBuilderHeaderContentEncoding = @"Content-Encoding";
NSString * const OguryNetworkRequestBuilderHeaderContentLength = @"Content-Length";
NSString * const OguryNetworkRequestBuilderHeaderUserAgent = @"User-Agent";

NSString * const OguryNetworkRequestBuilderHeaderApplicationJSON = @"application/json";
NSString * const OguryNetworkRequestBuilderHeaderEncodingGZIP = @"gzip";

#pragma mark - Initialization

- (instancetype)initWithHTTPMethod:(OguryNetworkRequestMethod)method andURL:(NSURL *)url {
    if (self = [super init]) {
        _method = method;
        _url = url;
    }

    return self;
}

#pragma mark - Methods

- (void)setValue:(NSString *)value forHeader:(NSString *)header {
    if (!self.headers) {
        self.headers = [[NSMutableDictionary alloc] init];
    }

    [self.headers setValue:value forKey:header];
}

- (void)addHeaders:(NSDictionary<NSString *, NSString *> *)headers {
    if (!self.headers) {
        self.headers = [[NSMutableDictionary alloc] init];
    }

    NSMutableDictionary<NSString *, NSString *> *dictionary = [self.headers mutableCopy];
    [dictionary addEntriesFromDictionary:headers];

    self.headers = dictionary;
}

- (void)setHeaders:(NSDictionary<NSString *, NSString *> *)headers {
    _headers = headers;
}

- (void)addQueryItem:(NSURLQueryItem *)queryItem {
    if (!self.queryItems) {
        self.queryItems = [NSMutableArray array];
    }

    NSMutableArray<NSURLQueryItem *> *queryItems = [self.queryItems mutableCopy];
    [queryItems addObject:queryItem];

    self.queryItems = queryItems;
}


- (void)addQueryItems:(NSArray<NSURLQueryItem *> *)queryItems {
    if (!self.queryItems) {
        self.queryItems = [NSMutableArray array];
    }

    NSMutableArray<NSURLQueryItem *> *newQueryItems = [self.queryItems mutableCopy];
    [newQueryItems addObjectsFromArray:queryItems];

    self.queryItems = newQueryItems;
}

- (void)setQueryItems:(NSArray<NSURLQueryItem *> *)queryItems {
    _queryItems = queryItems;
}

- (void)setPayload:(NSData *)payload {
    _payload = payload;
}

+ (NSString * _Nullable)httpMethodFromMethod:(OguryNetworkRequestMethod)httpMethod {
    NSString *returnValue;

    switch (httpMethod) {
        case OguryNetworkRequestHTTPMethodGET:
            returnValue = @"GET";
            break;
        case OguryNetworkRequestHTTPMethodPOST:
            returnValue = @"POST";
            break;
        case OguryNetworkRequestHTTPMethodPUT:
            returnValue = @"PUT";
            break;
        case OguryNetworkRequestHTTPMethodDELETE:
            returnValue = @"DELETE";
            break;
    }

    return returnValue;
}

- (NSURL * _Nullable)buildURL {
    if (!self.url || [self.url.absoluteString isEqualToString:@""]) {
        return nil;
    }

    // Computed URL
    NSURL *computedUrl = [self.url copy];

    // Query items
    if (self.queryItems) {
        NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:computedUrl.absoluteString];
        urlComponents.queryItems = self.queryItems;
        computedUrl = urlComponents.URL;
    }

    return computedUrl;
}

- (NSURLRequest * _Nullable)buildRequestWith:(NSURL *)url {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];

    // HTTP method
    request.HTTPMethod = [OguryNetworkRequestBuilder httpMethodFromMethod:self.method];

    // Base headers
    [request setValue:OguryNetworkRequestBuilderHeaderApplicationJSON forHTTPHeaderField:OguryNetworkRequestBuilderHeaderAccept];
    [request setValue:OguryNetworkRequestBuilderHeaderEncodingGZIP forHTTPHeaderField:OguryNetworkRequestBuilderHeaderAcceptEncoding];

    // Additional headers
    for (NSString *additionalHeaderKey in self.headers.allKeys) {
        [request setValue:self.headers[additionalHeaderKey] forHTTPHeaderField:additionalHeaderKey];
    }

    // Payload
    if (self.payload && self.payload.length > 0) {
        NSData *compressedData = [OguryNetworkRequestBuilder gzippedData:self.payload];

        // Add content headers
        [request setValue:OguryNetworkRequestBuilderHeaderApplicationJSON forHTTPHeaderField:OguryNetworkRequestBuilderHeaderContentType];
        [request setValue:OguryNetworkRequestBuilderHeaderEncodingGZIP forHTTPHeaderField:OguryNetworkRequestBuilderHeaderContentEncoding];
        [request setValue:@(compressedData.length).stringValue forHTTPHeaderField:OguryNetworkRequestBuilderHeaderContentLength];

        request.HTTPBody = compressedData;
    }

    return request;
}

- (NSURLRequest * _Nullable)build {
    NSURL *url = [self buildURL];

    if (!url) {
        return nil;
    }

    return [self buildRequestWith:url];
}

+ (NSData *)gzippedData:(NSData *)data withCompressionLevel:(float)level {
    if (data.length == 0) {
        return data;
    }

    z_stream stream;
    stream.zalloc = Z_NULL;
    stream.zfree = Z_NULL;
    stream.opaque = Z_NULL;
    stream.avail_in = (uint)data.length;
    stream.next_in = (Bytef *)(void *)data.bytes;
    stream.total_out = 0;
    stream.avail_out = 0;

    static const NSUInteger ChunkSize = 16384;

    NSMutableData *output = nil;
    int compression = (level < 0.0f)? Z_DEFAULT_COMPRESSION: (int)(roundf(level * 9));
    if (deflateInit2(&stream, compression, Z_DEFLATED, 31, 8, Z_DEFAULT_STRATEGY) == Z_OK) {
        output = [NSMutableData dataWithLength:ChunkSize];
        while (stream.avail_out == 0) {
            if (stream.total_out >= output.length) {
                output.length += ChunkSize;
            }
            stream.next_out = (uint8_t *)output.mutableBytes + stream.total_out;
            stream.avail_out = (uInt)(output.length - stream.total_out);
            deflate(&stream, Z_FINISH);
        }

        deflateEnd(&stream);
        output.length = stream.total_out;
    }

    return output;
}

+ (NSData *)gzippedData:(NSData *)data {
    return [self gzippedData:data withCompressionLevel:-1.0f];
}

@end

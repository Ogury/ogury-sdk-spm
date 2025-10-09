//
//  Copyright © 10/11/2020-present Ogury. All rights reserved.
//

#import "OguryNetworkClient.h"
#import "OguryNetworkClientPrivateProperties.h"
#import "OguryNetworkClientError.h"
#import "OGCLog.h"
#import "OguryLogLevel.h"
#import "OGCConstants.h"

@interface OguryNetworkClient ()

#pragma mark - Properties

@property (nonatomic, strong) OGCLog *log;

@end

@implementation OguryNetworkClient

#pragma mark - Initialization

- (instancetype)init {
    if (self = [super init]) {
        NSURLSessionConfiguration *urlSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        urlSessionConfiguration.requestCachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        urlSessionConfiguration.timeoutIntervalForRequest = OGCNetworkClientTimeoutIntervalForRequest;

        _urlSession = [NSURLSession sessionWithConfiguration:urlSessionConfiguration];
        _log = [OGCLog shared];
    }

    return self;
}

#pragma mark - Methods

+ (instancetype)shared {
    static OguryNetworkClient *instance = nil;
    static dispatch_once_t token;

    dispatch_once(&token, ^{
        instance = [[self alloc] init];
    });

    return instance;
}

- (void)performRequest:(NSURLRequest *)request completionHandler:(void(^)(NSData * _Nullable result, NSError * _Nullable error))completionHandler {
    if (!request.URL || [request.URL.absoluteString isEqualToString:@""]) {
        completionHandler(nil, [OguryNetworkClientError errorWithType:OguryNetworkClientErrorTypeInvalidURL]);
        return;
    }
    
    [self.log logRequestMessage:OguryLogLevelDebug message:@"Performing request" request:request];
    [[self.urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            completionHandler(nil, error);
            return;
        }

        if (!response) {
            completionHandler(nil, [OguryNetworkClientError errorWithType:OguryNetworkClientErrorTypeEmptyResponse]);
            return;
        }

        [self.log logRequestMessageFormat:OguryLogLevelDebug request:request format:@"Received request response: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
        if (httpURLResponse) {
            [OguryNetworkClient handleHTTPURLResponse:httpURLResponse data:data completionHandler:completionHandler];
        }
    }] resume];
}

- (void)performRequest:(NSURLRequest *)request completionHandlerWithUrlResponse:(void(^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
    if (!request.URL || [request.URL.absoluteString isEqualToString:@""]) {
        completionHandler(nil, nil, [OguryNetworkClientError errorWithType:OguryNetworkClientErrorTypeInvalidURL]);
        return;
    }

    [[self.urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            completionHandler(nil, nil, error);
            return;
        }

        if (!response) {
            completionHandler(nil, response, [OguryNetworkClientError errorWithType:OguryNetworkClientErrorTypeEmptyResponse]);
            return;
        }

        NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
        if (httpURLResponse) {
            [OguryNetworkClient handleHTTPURLResponse:httpURLResponse data:data completionHandlerWithUrlResponse:completionHandler];
        }
    }] resume];
}

+ (void)handleHTTPURLResponse:(NSHTTPURLResponse *)httpURLResponse data:(NSData *)data completionHandler:(void(^)(NSData * _Nullable result, NSError * _Nullable error))completionHandler {
    switch (httpURLResponse.statusCode) {
        case 200 ... 299:
            completionHandler(data, nil);
            break;

        case 400 ... 499:
            completionHandler(nil, [OguryNetworkClientError errorWithType:OguryNetworkClientErrorTypeClientError]);
            break;

        case 500 ... 599:
            completionHandler(nil, [OguryNetworkClientError errorWithType:OguryNetworkClientErrorTypeServerError]);
            break;

        default:
            completionHandler(nil, [OguryNetworkClientError errorWithType:OguryNetworkClientErrorTypeUnknown]);
            break;
    }
}

+ (void)handleHTTPURLResponse:(NSHTTPURLResponse *)httpURLResponse data:(NSData *)data completionHandlerWithUrlResponse:(void(^)(NSData * _Nullable result, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
    switch (httpURLResponse.statusCode) {
        case 200 ... 299:
            completionHandler(data, httpURLResponse, nil);
            break;

        case 400 ... 499:
            completionHandler(data, httpURLResponse, [OguryNetworkClientError errorWithType:OguryNetworkClientErrorTypeClientError]);
            break;

        case 500 ... 599:
            completionHandler(nil, httpURLResponse, [OguryNetworkClientError errorWithType:OguryNetworkClientErrorTypeServerError]);
            break;

        default:
            completionHandler(nil, httpURLResponse, [OguryNetworkClientError errorWithType:OguryNetworkClientErrorTypeUnknown]);
            break;
    }
}

@end

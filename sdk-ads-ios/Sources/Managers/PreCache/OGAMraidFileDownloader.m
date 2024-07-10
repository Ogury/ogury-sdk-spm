//
//  Copyright © 2018 Ogury. All rights reserved.
//

#import "OGAMraidFileDownloader.h"
#import <OguryCore/OguryNetworkRequestBuilder.h>
#import <OguryCore/OguryNetworkClient.h>
#import "OguryError+Ads.h"
#import "OGAMraidDownloadHeaderBuilder.h"
#import "OGAMonitoringDispatcher.h"
#import "OGALog.h"
#import "OGAAd.h"

@interface OGAMraidFileDownloader ()

@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) OGALog *log;

@end

@implementation OGAMraidFileDownloader

static NSString *const OGAMonitoringEventMraidURL = @"url";

#pragma mark - init

- (instancetype)init {
    return [self initWith:[OGAMonitoringDispatcher shared]
                      log:[OGALog shared]];
}

- (instancetype)initWith:(OGAMonitoringDispatcher *)monitoringDispatcher
                     log:(OGALog *)log {
    if (self = [super init]) {
        _monitoringDispatcher = monitoringDispatcher;
        _log = log;
    }
    return self;
}

#pragma mark - Methods

- (void)downloadMraidJSFromURL:(OGAAd *)ad completion:(MraidFileCompletion)completion {
    NSURL *url = [NSURL URLWithString:ad.mraidDownloadUrl];

    if (url == nil) {
        completion(@"", [OguryError createNotLoadedError]);
        return;
    }
    [self.monitoringDispatcher sendLoadEvent:OGALoadEventMraidRequest adConfiguration:ad.adConfiguration details:@{OGAMonitoringEventMraidURL : ad.mraidDownloadUrl}];
    [self.log logAd:OguryLogLevelDebug forAdConfiguration:ad.adConfiguration message:[NSString stringWithFormat:@"Mraid file request url : %@", ad.mraidDownloadUrl]];

    // Request
    OguryNetworkRequestBuilder *requestBuilder = [[OguryNetworkRequestBuilder alloc] initWithHTTPMethod:OguryNetworkRequestHTTPMethodGET
                                                                                                 andURL:url];

    // Headers
    [requestBuilder addHeaders:[OGAMraidDownloadHeaderBuilder build]];

    // check request build
    NSURLRequest *request = [requestBuilder build];
    if (request == nil) {
        completion(@"", [OguryError createNotLoadedError]);
        return;
    }

    [[OguryNetworkClient shared] performRequest:request
                              completionHandler:^(NSData *_Nullable result, NSError *_Nullable error) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      completion([[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding], error);
                                  });
                              }];
}

@end

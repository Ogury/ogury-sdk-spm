//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGAMetricsServiceSendCustomEventOperation.h"
#import <OguryCore/OguryNetworkClient.h>
#import <OguryCore/OguryNetworkRequestBuilder.h>
#import "OGALog.h"

@interface OGAMetricsServiceSendCustomEventOperation ()

#pragma mark - Properties

@property(nonatomic, strong) NSString *eventURL;
@property(nonatomic, strong) OguryNetworkClient *networkClient;
@property(nonatomic, strong) OGALog *log;

@end

@implementation OGAMetricsServiceSendCustomEventOperation

#pragma mark - Initialization

- (instancetype)initWithEventURL:(NSString *)eventURL {
    return [self initWithEventURL:eventURL networkClient:OguryNetworkClient.shared log:[OGALog shared]];
}

- (instancetype)initWithEventURL:(NSString *)eventURL networkClient:(OguryNetworkClient *)networkClient log:(OGALog *)log {
    if (self = [super init]) {
        _eventURL = eventURL;
        _networkClient = networkClient;
        _log = log;
    }

    return self;
}

#pragma mark - Methods

- (void)main {
    [super main];

    NSURL *url = [NSURL URLWithString:self.eventURL];

    if (!url) {
        [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelError
                                             adConfiguration:nil
                                                     logType:OguryLogTypePublisher
                                                     message:[NSString stringWithFormat:@"Failed to parse custom track event URL [eventURL: %@]", self.eventURL]
                                                        tags:nil]];
        return;
    }

    OguryNetworkRequestBuilder *builder = [[OguryNetworkRequestBuilder alloc] initWithHTTPMethod:OguryNetworkRequestHTTPMethodGET andURL:url];
    NSURLRequest *eventRequest = [builder build];

    if (!eventRequest) {
        [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelError
                                             adConfiguration:nil
                                                     logType:OguryLogTypePublisher
                                                     message:[NSString stringWithFormat:@"Failed to create request for custom track event [eventURL: %@]", self.eventURL]
                                                        tags:nil]];
        return;
    }

    [self.networkClient performRequest:eventRequest
                     completionHandler:^(NSData *_Nullable result, NSError *_Nullable error) {
                         if (error) {
                             [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelError
                                                                  adConfiguration:nil
                                                                          logType:OguryLogTypePublisher
                                                                          message:[NSString stringWithFormat:@"An error occurred while sending custom track event [eventURL: %@]", self.eventURL]
                                                                             tags:nil]];
                         }
                     }];
}

@end

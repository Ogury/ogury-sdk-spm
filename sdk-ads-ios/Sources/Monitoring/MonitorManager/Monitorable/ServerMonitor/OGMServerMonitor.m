//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import "OGMServerMonitor.h"
#import "OGALog.h"
#import "OGMServerMonitorRequestBuildable.h"
#import "OGAConfigurationUtils.h"
#import <OguryCore/OguryNetworkClient.h>
#import "OGMEventServerMonitorable.h"
#import "OGAMonitoringLogMessage.h"
#import "OGAAdMonitorEvent.h"

@interface OGMServerMonitor ()

@property(nonatomic, retain) NSURL *url;

@property(nonatomic, strong) OguryNetworkClient *networkClient;
@property(nonatomic, strong) id<OGMServerMonitorRequestBuildable> requestBuilder;
@property(nonatomic, strong) id<OGMPersistanceStore> persistanceStore;

@property(nonatomic, strong) NSMutableArray<id<OGMEventMonitorable>> *pendingEvents;

@property(nonatomic, strong) OGALog *log;

@end

@implementation OGMServerMonitor

#pragma mark - Property

@synthesize url;

#pragma mark - Methods

- (instancetype)initWithRequestBuilder:(id<OGMServerMonitorRequestBuildable>)requestBuilder
                      persistanceStore:(id<OGMPersistanceStore>)persistanceStore {
    return [self initWithRequestBuilder:requestBuilder
                          networkClient:[OguryNetworkClient shared]
                       persistanceStore:persistanceStore
                                    log:[OGALog shared]];
}

- (instancetype)initWithRequestBuilder:(id<OGMServerMonitorRequestBuildable>)requestBuilder
                         networkClient:(OguryNetworkClient *)networkClient
                      persistanceStore:(id<OGMPersistanceStore>)persistanceStore
                                   log:(OGALog *)log {
    if (self = [super init]) {
        self.networkClient = networkClient;
        self.requestBuilder = requestBuilder;
        self.log = log;
        self.persistanceStore = persistanceStore;
        self.pendingEvents = [self.persistanceStore getEvents] ?: [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)monitor:(id<OGMEventMonitorable>)event {
    [self monitorEvents:@[ event ]];
}

- (void)monitorEvents:(NSArray<id<OGMEventMonitorable>> *)events {
    @synchronized(self) {
        NSArray<id<OGMEventMonitorable>> *localArray = [self.pendingEvents arrayByAddingObjectsFromArray:events];

        NSURLRequest *request = [self.requestBuilder buildRequestWithEvents:localArray];

        if (!request) {
            // we will lose this track if a request cannot be instantiated because of this event, which should normally never arrived (previous event are saved only when initialisation of a request is properly done)
            return;
        }

        if (![OGAConfigurationUtils isConnectedToInternet]) {
            [self updateSavedEventsWith:localArray];
            return;
        }

        [self cleanEvents];
        [self.log log:[[OGAMonitoringLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                                     adConfiguration:((OGAAdMonitorEvent *)events.firstObject).adConfiguration
                                                             message:@"Send event to server"
                                                               event:events.firstObject]];

        [self.networkClient performRequest:request
                         completionHandler:^(NSData *_Nullable result, NSError *_Nullable error) {
                             @synchronized(self) {
                                 if (error != nil) {
                                     NSArray *errorCodes = @[ @(NSURLErrorUnknown),
                                                              @(NSURLErrorCancelled),
                                                              @(NSURLErrorTimedOut),
                                                              @(NSURLErrorCannotFindHost),
                                                              @(NSURLErrorCannotConnectToHost),
                                                              @(NSURLErrorNetworkConnectionLost),
                                                              @(NSURLErrorNotConnectedToInternet),
                                                              @(NSURLErrorZeroByteResource),
                                                              @(NSURLErrorDNSLookupFailed),
                                                              @(NSURLErrorHTTPTooManyRedirects),
                                                              @(NSURLErrorResourceUnavailable),
                                                              @(NSURLErrorBadServerResponse) ];

                                     if ([errorCodes containsObject:@(error.code)]) {
                                         [self updateSavedEventsWith:localArray];
                                     } else {
                                         [self.log log:[[OGAMonitoringLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                                                                      adConfiguration:((OGAAdMonitorEvent *)events.firstObject).adConfiguration
                                                                                                error:error
                                                                                              message:@"Send event failed"
                                                                                                event:events.firstObject]];
                                     }
                                 }
                             }
                         }];
    }
}

- (void)updateSavedEventsWith:(NSArray<id<OGMEventMonitorable>> *)events {
    @synchronized(self) {
        [self.pendingEvents removeAllObjects];
        // update all events as deferred
        for (int index = 0; index < events.count; index++) {
            ((id<OGMEventServerMonitorable>)events[index]).dispatchType = OGMDispatchTypeDeferred;
        }
        [self.pendingEvents addObjectsFromArray:events];
        [self.persistanceStore saveEvents:self.pendingEvents];
    };
}

- (void)cleanEvents {
    [self.pendingEvents removeAllObjects];
    [self.persistanceStore cleanEvents];
}

@end

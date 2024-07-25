//
// Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGWMonitoringInfoSender.h"

#import <OguryCore/OguryNetworkClient.h>
#import <OguryCore/OguryNetworkRequestBuilder.h>

#import "OGWLog.h"
#import "OGWMonitoringInfoHeadersBuilder.h"
#import "OGWMonitoringInfoSerializer.h"

NSString *const OGWMonitoringInfoSenderProductionURL = @"https://sdk-monitoring.ogury.co/sdk-versions";
NSString *const OGWMonitoringInfoSenderStagingURL = @"https://ms-ads-monitoring-events.staging.cloud.ogury.io/sdk-versions";
NSString *const OGWMonitoringInfoSenderDevcURL = @"https://ms-ads-monitoring-events.devc.cloud.ogury.io/sdk-versions";

NSString *const OGWMonitoringInfoSenderReleaseEnvironment = @"release";
NSString *const OGWMonitoringInfoSenderBetaEnvironment = @"beta";
NSString *const OGWMonitoringInfoSenderProdEnvironment = @"prod";
NSString *const OGWMonitoringInfoSenderStagingEnvironment = @"staging";
NSString *const OGWMonitoringInfoSenderDevcEnvironment = @"devc";

NSString *const OGWMonitoringInfoSenderErrorDomain = @"OGWMonitoringInfoSender";
NSInteger const OGWMonitoringInfoSenderErrorNoUrl = 0;
NSInteger const OGWMonitoringInfoSenderErrorFailedToBuildRequest = 1;

@interface OGWMonitoringInfoSender ()

@property(nonatomic, strong) NSURL *url;
@property(nonatomic, strong) OGWMonitoringInfoHeadersBuilder *headersBuilder;
@property(nonatomic, strong) OGWMonitoringInfoSerializer *serializer;
@property(nonatomic, strong) OguryNetworkClient *networkClient;

@end

@implementation OGWMonitoringInfoSender

#pragma mark - Initialization

- (instancetype)init {
   return [self initWithURL:[OGWMonitoringInfoSender urlForEnvironment:OGURY_ENVIRONMENT]
             headersBuilder:[[OGWMonitoringInfoHeadersBuilder alloc] init]
                 serializer:[[OGWMonitoringInfoSerializer alloc] init]
              networkClient:[OguryNetworkClient shared]];
}

- (instancetype)initWithURL:(NSURL *)url
             headersBuilder:(OGWMonitoringInfoHeadersBuilder *)headersBuilder
                 serializer:(OGWMonitoringInfoSerializer *)serializer
              networkClient:(OguryNetworkClient *)networkClient {
   if (self = [super init]) {
      _url = url;
      _headersBuilder = headersBuilder;
      _serializer = serializer;
      _networkClient = networkClient;
   }
   return self;
}

#pragma mark - Methods

- (void)send:(OGWMonitoringInfo *)monitoringInfo completionHandler:(void (^_Nullable)(NSError *))completionHandler {
   if (!self.url) {
      if (completionHandler) {
         completionHandler([NSError errorWithDomain:OGWMonitoringInfoSenderErrorDomain
                                               code:OGWMonitoringInfoSenderErrorNoUrl
                                           userInfo:nil]);
      }
      return;
   }

   NSError *error;
   NSData *monitoringInfoJson = [self.serializer serialize:monitoringInfo error:&error];
   if (!monitoringInfoJson) {
      if (completionHandler) {
         completionHandler(error);
      }
      return;
   }

   OguryNetworkRequestBuilder *builder = [[OguryNetworkRequestBuilder alloc] initWithHTTPMethod:OguryNetworkRequestHTTPMethodPOST andURL:self.url];
   [builder addHeaders:[self.headersBuilder build:monitoringInfo]];
   builder.payload = monitoringInfoJson;

   NSURLRequest *request = [builder build];
   if (!request) {
      if (completionHandler) {
         completionHandler([NSError errorWithDomain:OGWMonitoringInfoSenderErrorDomain
                                               code:OGWMonitoringInfoSenderErrorFailedToBuildRequest
                                           userInfo:nil]);
      }
      return;
   }

   [self.networkClient performRequest:request
                    completionHandler:^(NSData *result, NSError *requestError) {
                      if (completionHandler) {
                         completionHandler(requestError);
                      }
                    }];
}

+ (NSURL *)urlForEnvironment:(NSString *)env {
   NSString *rawUrl;
   if ([OGWMonitoringInfoSenderProdEnvironment isEqualToString:env] || [OGWMonitoringInfoSenderBetaEnvironment isEqualToString:env] || [OGWMonitoringInfoSenderReleaseEnvironment isEqualToString:env]) {
      rawUrl = OGWMonitoringInfoSenderProductionURL;
   } else if ([OGWMonitoringInfoSenderStagingEnvironment isEqualToString:env]) {
      rawUrl = OGWMonitoringInfoSenderStagingURL;
   } else if ([OGWMonitoringInfoSenderDevcEnvironment isEqualToString:env]) {
      rawUrl = OGWMonitoringInfoSenderDevcURL;
   } else {
      [[OGWLog shared] logFormat:OguryLogLevelError format:@"Failed to determine the url for environment '%@'.", env];
      return nil;
   }
   return [[NSURL alloc] initWithString:rawUrl];
}

@end

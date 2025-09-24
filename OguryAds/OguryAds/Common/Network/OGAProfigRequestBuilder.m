//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAProfigRequestBuilder.h"
#import "OGAEnvironmentManager.h"
#import "OGAConfigurationUtils+Profig.h"
#import <OguryCore/OguryNetworkRequestBuilder.h>
#import <OguryCore/OGCURLRequestLogMessage.h>
#import "OGALog.h"

@implementation OGAProfigRequestBuilder

+ (NSURLRequest *)build {
    OguryNetworkRequestBuilder *profigRequestBuilder = [[OguryNetworkRequestBuilder alloc] initWithHTTPMethod:OguryNetworkRequestHTTPMethodPOST
                                                                                                       andURL:[OGAEnvironmentManager shared].profigURL];

    [profigRequestBuilder setPayload:[NSJSONSerialization dataWithJSONObject:[OGAConfigurationUtils profigParams] options:0 error:nil]];
    NSURLRequest *request = [profigRequestBuilder build];

    [[OGALog shared] log:[[OGCURLRequestLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                                                    sdk:OguryLogSDKAds
                                                                message:@"[Setup] profig request building body"
                                                                request:request]];
    return request;
}

@end

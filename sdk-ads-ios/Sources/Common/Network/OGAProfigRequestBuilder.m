//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAProfigRequestBuilder.h"
#import "OGAEnvironmentManager.h"
#import "OGAConfigurationUtils+Profig.h"
#import <OguryCore/OguryNetworkRequestBuilder.h>
#import "OGALog.h"

@implementation OGAProfigRequestBuilder

+ (NSURLRequest *)build {
    OguryNetworkRequestBuilder *profigRequestBuilder = [[OguryNetworkRequestBuilder alloc] initWithHTTPMethod:OguryNetworkRequestHTTPMethodPOST
                                                                                                       andURL:[OGAEnvironmentManager shared].profigURL];

    [profigRequestBuilder setPayload:[NSJSONSerialization dataWithJSONObject:[OGAConfigurationUtils profigParams] options:0 error:nil]];

    [[OGALog shared] logFormat:OguryLogLevelDebug format:@"[Setup] profig request building body: %@", [OGAConfigurationUtils profigParams]];

    return [profigRequestBuilder build];
}

@end

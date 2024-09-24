//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGAAdLogMessage.h"
#import "OGALog.h"

OguryLogSDK const OguryLogSDKAds = @"Ads";
OguryLogType const OguryLogTypeMraid = @"Mraid";
OguryLogType const OguryLogTypeMonitoring = @"Monitoring";
OguryLogType const OguryLogTypeDelegate = @"Callbacks";

@implementation OGAAdLogMessage

#pragma mark - Initialization

- (instancetype)initWithLevel:(OguryLogLevel)level
              adConfiguration:(OGAAdConfiguration *_Nullable)adConfiguration
                      logType:(OguryLogType)logType
                      message:(NSString *)message
                         tags:(NSArray<OguryLogTag *> *_Nullable)tags {
    if (self = [super initWithLevel:level
                            logType:logType
                                sdk:OguryLogSDKAds
                            message:message]) {
        _adConfiguration = adConfiguration;
        NSMutableArray *computeTags = [@[] mutableCopy];
        if (adConfiguration != nil) {
            [computeTags addObjectsFromArray:@[
                [OguryLogTag tagWithKey:@"AdType" value:[adConfiguration getAdTypeString] ?: @""],
                [OguryLogTag tagWithKey:@"AdUnitId" value:adConfiguration.adUnitId ?: @""],
                [OguryLogTag tagWithKey:@"CampaignId" value:adConfiguration.campaignId ?: @""]
            ]];
        }
        if (tags != nil) {
            [computeTags addObjectsFromArray:tags];
        }
        self.tags = computeTags;
    }
    return self;
}

- (instancetype)initWithLevel:(OguryLogLevel)level
              adConfiguration:(OGAAdConfiguration *_Nullable)adConfiguration
                      logType:(OguryLogType)logType
                        error:(NSError *)error
                      message:(NSString *_Nullable)message
                         tags:(NSArray<OguryLogTag *> *_Nullable)tags {
    return [self initWithLevel:level
               adConfiguration:adConfiguration
                       logType:logType
                       message:message == nil ? logErrorMessage(error) : [logErrorMessage(error) stringByAppendingFormat:@" - %@", message]
                          tags:tags];
}

- (BOOL)isEqual:(id)object {
    // clang-format off
    OGAAdLogMessage *rhsMessage = (OGAAdLogMessage *)object;
    if (rhsMessage == nil) {
        return NO;
    }
    return [super isEqual:rhsMessage] && self.adConfiguration == rhsMessage.adConfiguration;
    // clang-format on
}

@end

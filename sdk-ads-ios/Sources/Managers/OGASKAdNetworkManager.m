//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGASKAdNetworkManager.h"
#import "OGASKAdNetworkService.h"
#import "OGALog.h"
#import "OGAMonitoringDispatcher+SKNetwork.h"
#import "OGAAd.h"

@interface OGASKAdNetworkManager ()

@property(nonatomic, strong) SKAdImpression *impression API_AVAILABLE(ios(14.5));
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;

@end

@implementation OGASKAdNetworkManager

#pragma mark - Initialization

+ (instancetype)shared {
    static OGASKAdNetworkManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    return [self initWithLog:[OGALog shared] monitoringDispatcher:[OGAMonitoringDispatcher shared]];
}

- (instancetype)initWithLog:(OGALog *)log
       monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher {
    if (self = [super init]) {
        _log = log;
        _monitoringDispatcher = monitoringDispatcher;
    }
    return self;
}

#pragma mark - Methods

- (void)startImpressionWithAd:(OGAAd *)ad {
    if (ad.skAdNetworkResponse == NULL) {
        return;
    }
    [self.log logAd:OguryLogLevelInfo
        forAdConfiguration:ad.adConfiguration
                   message:@"[SKAdNetwork] SKAdNetwork configuration found"];
    if (ad.skAdNetworkResponse.isStoreKitDisplay) {
        [self.log logAd:OguryLogLevelInfo
            forAdConfiguration:ad.adConfiguration
                       message:@"[SKAdNetwork] SKimpression display by Store Kit"];
        return;
    }
    [self.monitoringDispatcher sendSKNetworkImpressionEvent:OGASKNetworkShowEventStartingImpression
                           advertisedAppStoreItemIdentifier:ad.skAdNetworkResponse.itunesItemId
                                            adConfiguration:ad.adConfiguration];

    if (@available(iOS 14.5, *)) {
        [self.log logAd:OguryLogLevelInfo
            forAdConfiguration:ad.adConfiguration
                       message:@"[SKAdNetwork] Impression SKAdNetwork created"];
        self.impression = [OGASKAdNetworkService createImpression:ad.skAdNetworkResponse.signature
                                     sourceAppStoreItemIdentifier:ad.skAdNetworkResponse.sourceAppId
                                 advertisedAppStoreItemIdentifier:ad.skAdNetworkResponse.itunesItemId
                                             adCampaignIdentifier:ad.skAdNetworkResponse.campaignId
                                                 sourceIdentifier:ad.skAdNetworkResponse.sourceIdentifier
                                              adNetworkIdentifier:ad.skAdNetworkResponse.networkIdentifier
                                                          version:ad.skAdNetworkResponse.version
                                           adImpressionIdentifier:ad.skAdNetworkResponse.nonce
                                                        timestamp:ad.skAdNetworkResponse.timestamp];
        [OGASKAdNetworkService startImpression:self.impression
                          monitoringDispatcher:self.monitoringDispatcher
                               adConfiguration:ad.adConfiguration];
        [self.log logAd:OguryLogLevelInfo
            forAdConfiguration:ad.adConfiguration
                       message:@"[SKAdNetwork] Impression SKAdNetwork started"];
    } else {
        [self.monitoringDispatcher sendSKNetworkImpressionEvent:OGASKNetworkShowEventIncompatibleIOSVersionToStartImpression
                               advertisedAppStoreItemIdentifier:ad.skAdNetworkResponse.itunesItemId
                                                adConfiguration:ad.adConfiguration];
    }
}

- (void)stopImpressionWithAd:(OGAAd *)ad {
    if (ad.skAdNetworkResponse == NULL) {
        return;
    }
    if (ad.skAdNetworkResponse.isStoreKitDisplay) {
        return;
    }
    [self.monitoringDispatcher sendSKNetworkImpressionEvent:OGASKNetworkShowEventStoppingImpression
                           advertisedAppStoreItemIdentifier:ad.skAdNetworkResponse.itunesItemId
                                            adConfiguration:ad.adConfiguration];
    if (@available(iOS 14.5, *)) {
        if (self.impression == NULL) {
            return;
        }
        [self.log log:OguryLogLevelInfo
              message:@"[SKAdNetwork] Impression SKAdNetwork end"];
        [OGASKAdNetworkService endImpression:self.impression
                        monitoringDispatcher:self.monitoringDispatcher
                             adConfiguration:ad.adConfiguration];
    } else {
        [self.monitoringDispatcher sendSKNetworkImpressionEvent:OGASKNetworkShowEventIncompatibleIOSVersionToStopImpression
                               advertisedAppStoreItemIdentifier:ad.skAdNetworkResponse.itunesItemId
                                                adConfiguration:ad.adConfiguration];
    }
}

@end

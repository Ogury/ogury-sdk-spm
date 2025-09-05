//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAProfigFullResponse+Parser.h"
#import "OGALog.h"
#import "OGAMonitoringDispatcher.h"
#import "OGAProfigConstants.h"

@implementation OGAProfigFullResponse (Parser)

+ (OGAProfigFullResponse *)parseProfigResponseWithData:(NSData *)response urlResponse:(NSURLResponse *)urlResponse {
    NSError *error;
    if (response == nil) {
        return nil;
    }

    NSDictionary *json;
    @try {
        json = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:&error];
    }
    @catch (NSException *exception) {
        [[OGALog shared] log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelError
                                                    adConfiguration:nil
                                                            logType:OguryLogTypePublisher
                                                            message:[NSString stringWithFormat:@"[Setup] profig response parsing exception: %@", exception.reason]
                                                               tags:nil]];
    }
    if (error) {
        return nil;
    }

    [[OGALog shared] log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                                adConfiguration:nil
                                                        logType:OguryLogTypeInternal
                                                        message:[NSString stringWithFormat:@"[Setup] profig response parsed: %@", json]
                                                           tags:nil]];

    if (json.allKeys.count == 0) {
        return nil;
    }

    OGAProfigFullResponse *profig;
    if ([json objectForKey:OGAErrorKey]) {
        NSError *error;
        profig = [[OGAProfigFullResponse alloc] initWithDictionary:json error:&error];
    } else {
        profig = [self parserFullResponseWithDictionary:json];
    }
    NSDictionary *responseHeader = [OGAProfigFullResponse retreiveHttpResponseHeader:urlResponse];
    NSString *cacheControl = responseHeader[OGACacheControlKey];
    NSRange ccLocation = [cacheControl rangeOfString:[NSString stringWithFormat:@"%@=", OGAMaxAgeKey]];
    if (ccLocation.location != NSNotFound) {
        NSString *maxAge = [cacheControl substringFromIndex:ccLocation.location + ccLocation.length];
        if (maxAge.intValue > 0) {
            profig.retryInterval = @(maxAge.intValue);
        }
    }
    // moved this test here to always perform a max-age even on Bad Request 400 responses
    if (!profig.retryInterval) {
        profig.retryInterval = @(OGAMaxAgeDefault);
    }
    return profig;
}

+ (NSDictionary *)retreiveHttpResponseHeader:(NSURLResponse *)urlResponse {
    if ([urlResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)urlResponse;
        return [httpResponse allHeaderFields];
    } else {
        return [NSDictionary dictionary];
    }
}

+ (OGAProfigFullResponse *)parserFullResponseWithDictionary:(NSDictionary *)profigJSON {
    NSError *error;
    OGAProfigFullResponse *profig = [[OGAProfigFullResponse alloc] initWithDictionary:profigJSON error:&error];

    if (error) {
        [[OGALog shared] log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                                    adConfiguration:nil
                                                            logType:OguryLogTypeInternal
                                                            message:[NSString stringWithFormat:@"[Setup] profig error parsing: json %@", profigJSON]
                                                               tags:nil]];
        return nil;
    }

    if (!profig.requestTimeout) {
        profig.requestTimeout = @(OGARequestTimeOutDefault);
    }

    if (!profig.childrenRequestPermissionsFilter) {
        profig.childrenRequestPermissionsFilter = @(OGAChildrenRequestPermissionsFilterDefault);
    }

    if (profig.retryInterval) {
        profig.maxProfigApiCallsPerDay = nil;
    } else if (!profig.maxProfigApiCallsPerDay) {
        profig.maxProfigApiCallsPerDay = @(OGAProfigCallsPerDayDefault);
    }

    if (!profig.adsyncPermissions) {
        profig.adsyncPermissions = @(OGAAdSyncPermissionsDefault);
    }

    if (!profig.adExpirationTime) {
        profig.adExpirationTime = @(OGAADExpirationTimeDefault);
    }

    if (!profig.webviewLoadTimeout) {
        profig.webviewLoadTimeout = @(OGAWebviewLoadTimeoutDefault);
    }

    if (!profig.showCloseButtonDelay) {
        profig.showCloseButtonDelay = @(OGAShowCloseButtonDelayDefault);
    }

    if (!profig.thumbnailDefaultXMargin) {
        profig.thumbnailDefaultXMargin = @(OGAXMarginDefault);
    }

    if (!profig.thumbnailDefaultYMargin) {
        profig.thumbnailDefaultYMargin = @(OGAYMarginDefault);
    }

    if (!profig.thumbnailDefaultMaxWidth) {
        profig.thumbnailDefaultMaxWidth = @(OGAMaxWidthDefault);
    }

    if (!profig.thumbnailDefaultMaxHeight) {
        profig.thumbnailDefaultMaxHeight = @(OGAMaxHeightDefault);
    }

    if (!profig.monitoringPermissions) {
        profig.monitoringPermissions = @(OGAMonitoringPermissions);
    }
    
    if (!profig.adQualityConfiguration) {
        profig.adQualityConfiguration = [OGAAdQualityConfiguration new];
    }

    [self handleBooleansDefaultValuesFrom:profigJSON for:profig];
    return profig;
}

+ (void)handleBooleansDefaultValuesFrom:(NSDictionary *)json for:(OGAProfigFullResponse *)profig {
    if (json[@"response"][@"ad_serving"][@"enabled"] == nil) {
        profig.adsEnabled = OGAAdEnabledDefault;
    }
    if (json[@"response"][@"ad_serving"][@"webview"][@"back_button_enabled"] == nil) {
        profig.backButtonEnabled = OGABackButtonEnabledDefault;
    }
    if (json[@"response"][@"ad_serving"][@"webview"][@"close_ad_when_leaving_app"] == nil) {
        profig.closeAdWhenLeavingApp = OGACloseADWhenLeavingApplicationDefault;
    }
    if (json[@"response"][@"monitoring"][@"tracks"][@"enabled"] == nil) {
        profig.cacheLogsEnabled = OGACacheLogsEnabledDefault;
    }
    if (json[@"response"][@"monitoring"][@"precaching_logs"][@"enabled"] == nil) {
        profig.precachingLogsEnabled = OGAPrecachingLogsEnabledDefault;
    }
    if (json[@"response"][@"monitoring"][@"ad_life_cycle"][@"enabled"] == nil) {
        profig.adLifeCycleLogsEnabled = OGAAdLifeCycleLogsEnabledDefault;
    }
    if (json[@"response"][@"monitoring"][@"ad_life_cycle"][@"blacklist"] == nil) {
        profig.blacklistedTracks = [OGAProfigFullResponse defaultBlackList];
    }
    if (json[@"response"][@"omid"][@"enabled"] == nil) {
        profig.omidEnabled = OGAAdOmidEnabledDefault;
    }
}

@end

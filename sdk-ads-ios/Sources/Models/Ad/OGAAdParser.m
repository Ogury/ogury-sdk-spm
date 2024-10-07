//
//  Copyright © 2018 Ogury. All rights reserved.
//

#import "OGAAdParser.h"
#import "NSString+OGAUtility.h"
#import "OGAAdConfiguration.h"
#import "OGALog.h"
#import "OguryAdError+Internal.h"

@implementation OGAAdParser

+ (NSArray *)parseJSONResponse:(NSDictionary *)json
               adConfiguration:(OGAAdConfiguration *)adConfig
          privacyConfiguration:(OGAAdPrivacyConfiguration *)privacyConfiguration
                         error:(NSError *_Nonnull *_Nonnull)error
          monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher {
    NSMutableArray<OGAAd *> *parsedAds = [NSMutableArray new];
    NSArray<NSDictionary *> *adsJSON = json[@"ad"];

    if ([adsJSON count] == 0) {
        *error = [OguryAdError adParsingFailedWithStackTrace:@"No ad received"];
        return adsJSON;
    }

    if (adsJSON) {
        for (NSDictionary *adJSON in adsJSON) {
            OGAAd *ad = [OGAAdParser parseAdJSON:adJSON
                                 adConfiguration:adConfig
                            privacyConfiguration:privacyConfiguration
                                           error:error
                            monitoringDispatcher:monitoringDispatcher];
            if (ad != nil) {
                [parsedAds addObject:ad];
            }
        }
    }

    return parsedAds;
}

+ (OGAAd *)parseAdJSON:(NSDictionary *)adJSON
         adConfiguration:(OGAAdConfiguration *)adConfig
    privacyConfiguration:(OGAAdPrivacyConfiguration *)privacyConfiguration
                   error:(NSError *_Nonnull *_Nonnull)error
    monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher {
    @try {
        NSError *parseError;
        OGAAd *ad = [[OGAAd alloc] initWithDictionary:adJSON error:&parseError];
        if (parseError) {
            [[OGALog shared] logAdError:parseError forAdConfiguration:adConfig message:@"Failed to parse ad content."];
            return nil;
        }
        if ([self shouldParseAd:ad withConfiguration:adConfig error:error]) {
            ad.orientation = [OGAAdParser parseParam:adJSON param:@"orientation"];
            ad.adWebViewId = [OGAAdParser parseFormatParams:adJSON];
            ad.privacyConfiguration = privacyConfiguration;
            ad.adConfiguration = [adConfig copy];
            ad.adConfiguration.monitoringDetails.loadedSource = [ad getRawLoadedSource];
            ad.adConfiguration.campaignId = ad.campaignId;
            ad.adConfiguration.creativeId = ad.creativeId;
            ad.adConfiguration.extras = ad.extras;
            [monitoringDispatcher sendLoadEvent:OGALoadEventAdParseEnded adConfiguration:adConfig];
            return ad;
        } else {
            return nil;
        }
    } @catch (NSException *exception) {
        [[OGALog shared] logAdFormat:OguryLogLevelError forAdConfiguration:adConfig format:@"Failed to parse ad content. Caused by %@.", exception.reason];
    }
}

+ (BOOL)shouldParseAd:(OGAAd *)ad withConfiguration:(OGAAdConfiguration *)adConfig error:(NSError *_Nonnull *_Nonnull)error {
    if ([NSString ogaIsNilOrEmpty:ad.adUnit.identifier] || [NSString ogaIsNilOrEmpty:ad.adUnit.type]) {
        [[OGALog shared] logAdFormat:OguryLogLevelInfo forAdConfiguration:adConfig format:@"adUnit on ad object is empty"];
        *error = [OguryAdError adParsingFailedWithStackTrace:@"No adUnit on Ad object"];
        return NO;
    }

    if (![[adConfig getAdTypeString] isEqualToString:ad.adUnit.type]) {
        [[OGALog shared] logAdFormat:OguryLogLevelError
                  forAdConfiguration:adConfig
                              format:@"ad.adUnit type [%@] not equalt to expected adConfiguration with type [%@]", ad.adUnit.type, [adConfig getAdTypeString]];
        *error = [OguryAdError adParsingFailedWithStackTrace:[NSString stringWithFormat:@"Type mismatch. Awaited (%@) - received (%@)",
                                                                                        [adConfig getAdTypeString],
                                                                                        ad.adUnit.type]];
        return NO;
    }

    return YES;
}

#pragma mark - Private Methods

+ (NSString *)parseParam:(NSDictionary *)json param:(NSString *)param {
    NSDictionary *paramsDict = json[@"params"];
    for (NSDictionary *jsonItem in paramsDict) {
        NSString *paramName = jsonItem[@"name"];
        if ([paramName isEqualToString:param]) {
            return jsonItem[@"value"];
        }
    }
    return nil;
}

+ (NSString *)parseFormatParams:(NSDictionary *)json {
    NSArray *formatParams = json[@"format"][@"params"];
    for (NSDictionary *formatJSONItem in formatParams) {
        NSString *paramName = formatJSONItem[@"name"];
        if ([paramName isEqualToString:@"zones"]) {
            NSArray *zoneArray = formatJSONItem[@"value"];
            NSDictionary *zoneJSON = [zoneArray firstObject];
            if (zoneJSON) {
                return zoneJSON[@"name"];
            }
        }
    }
    return nil;
}

@end

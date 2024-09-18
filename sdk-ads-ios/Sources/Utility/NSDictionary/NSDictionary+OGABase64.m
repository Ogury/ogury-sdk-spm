//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "NSDictionary+OGABase64.h"
#import "NSString+OGABase64.h"
#import "OGALog.h"
#import "OguryAdsError+Internal.h"

@implementation NSDictionary (OGABase64)

- (NSString *)ogaEncodeToBase64 {
    NSError *error;
    NSData *jsonConverted = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingFragmentsAllowed error:&error];
    if (error) {
        [[OGALog shared] log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelError
                                                    adConfiguration:nil
                                                            logType:OguryLogTypePublisher
                                                              error:error
                                                               tags:nil]];
        return @"";
    } else if (jsonConverted == nil) {
        [[OGALog shared] log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelError
                                                    adConfiguration:nil
                                                            logType:OguryLogTypePublisher
                                                            message:@"An error occurred while encoding NSObject to Base64"
                                                               tags:nil]];
        return @"";
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonConverted encoding:NSUTF8StringEncoding];
        return [jsonString ogaEncodeStringTo64];
    }
}

+ (NSDictionary *)ogaDecodeFromBase64:(NSString *)jsonString error:(NSError **)error {
    if (!jsonString) {
        *error = [OguryAdsError adParsingFailedWithStackTrace:[NSString stringWithFormat:@"Base64 string is empty"]];
        return nil;
    }
    NSError *parseError;
    NSData *data = [[NSData alloc] initWithBase64EncodedString:jsonString options:NSDataBase64DecodingIgnoreUnknownCharacters];
    if (!data) {
        *error = [OguryAdsError adParsingFailedWithStackTrace:@"Could not decode Base64"];
        return nil;
    }
    id jsonConverted = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
    if (parseError || jsonConverted == nil) {
        *error = [OguryAdsError adParsingFailedWithStackTrace:[NSString stringWithFormat:@"Base64 contained invalid JSON (%@)", parseError.localizedDescription]];
        [[OGALog shared] log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelError
                                                    adConfiguration:nil
                                                            logType:OguryLogTypePublisher
                                                              error:parseError
                                                               tags:nil]];
        return nil;
    } else {
        return jsonConverted;
    }
}

@end

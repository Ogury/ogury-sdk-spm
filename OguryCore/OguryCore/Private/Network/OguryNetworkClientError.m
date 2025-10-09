//
//  Copyright © 10/11/2020-present Ogury. All rights reserved.
//

#import "OguryNetworkClientError.h"
#import "OGCConstants.h"

@implementation OguryNetworkClientError

#pragma mark - Methods

+ (NSError *)errorWithType:(OguryNetworkClientErrorType)errorType {
    return [[NSError alloc] initWithDomain:OguryNetworkClientErrorDomain code:errorType userInfo:[OguryNetworkClientError userInfoForErrorType:errorType]];
}

+ (NSString *)localizedDescriptionForErrorType:(OguryNetworkClientErrorType)errorType {
    NSString *localizedDescription;

    switch (errorType) {
        case OguryNetworkClientErrorTypeInvalidURL:
            localizedDescription = OguryNetworkClientErrorTypeInvalidURLLocalizedDescription;
            break;
        case OguryNetworkClientErrorTypeUnknown:
            localizedDescription = OguryNetworkClientErrorTypeUnknownLocalizedDescription;
            break;
        case OguryNetworkClientErrorTypeEmptyResponse:
            localizedDescription = OguryNetworkClientErrorTypeEmptyResponseLocalizedDescription;
            break;
        case OguryNetworkClientErrorTypeClientError:
            localizedDescription = OguryNetworkClientErrorTypeClientErrorLocalizedDescription;
            break;
        case OguryNetworkClientErrorTypeServerError:
            localizedDescription = OguryNetworkClientErrorTypeServerErrorLocalizedDescription;
            break;
        case OguryNetworkClientErrorTypeNotYetImplemented:
            localizedDescription = OguryNetworkClientErrorTypeNotYetImplementedLocalizedDescription;
            break;
    }

    return [OguryNetworkClientErrorLocalizedDescription stringByAppendingString:localizedDescription];
}

+ (NSString *)localizedRecoverySuggestionForErrorType:(OguryNetworkClientErrorType)errorType {
    NSString *localizedRecoverySuggestion = @"";

    switch (errorType) {
        case OguryNetworkClientErrorTypeInvalidURL:
            localizedRecoverySuggestion = OguryNetworkClientErrorTypeInvalidURLLocaliedRecoverySuggestion;
            break;
        case OguryNetworkClientErrorTypeUnknown:
            localizedRecoverySuggestion = OguryNetworkClientErrorTypeUnknowLocalizedRecoverySuggestion;
            break;
        case OguryNetworkClientErrorTypeEmptyResponse:
            localizedRecoverySuggestion = OguryNetworkClientErrorTypeEmptyResponseLocalizedRecoverySuggestion;
            break;
        case OguryNetworkClientErrorTypeClientError:
            localizedRecoverySuggestion = OguryNetworkClientErrorTypeClientErrorLocalizedRecoverySuggestion;
            break;
        case OguryNetworkClientErrorTypeServerError:
            localizedRecoverySuggestion = OguryNetworkClientErrorTypeServerErrorLocalizedRecoverySuggestion;
            break;
        case OguryNetworkClientErrorTypeNotYetImplemented:
            localizedRecoverySuggestion = OguryNetworkClientErrorTypeNotYetImplementedLocalizedRecoverySuggestion;
            break;
    }

    return localizedRecoverySuggestion;
}

+ (NSDictionary<NSString *, NSString *> *)userInfoForErrorType:(OguryNetworkClientErrorType)errorType {
    return @{
        NSLocalizedDescriptionKey: [self localizedDescriptionForErrorType:errorType],
        NSLocalizedRecoverySuggestionErrorKey: [self localizedRecoverySuggestionForErrorType:errorType],
    };
}

@end

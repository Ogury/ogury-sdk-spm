//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import "OguryError.h"
#import "OGCConstants.h"

@implementation OguryError

#pragma mark - Methods

+ (instancetype)createOguryErrorWithCode:(NSInteger)code {
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey: @""
    };

    return [OguryError errorWithDomain:[self getOguryErrorDomain] code:code userInfo:userInfo];
}

+ (instancetype)createOguryErrorWithCode:(NSInteger)code localizedDescription:(NSString *)localizedDescription {
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey: localizedDescription ?: @""
    };

    return [OguryError errorWithDomain:[self getOguryErrorDomain] code:code userInfo:userInfo];
}

+ (instancetype)createOguryErrorWithCode:(NSInteger)code localizedDescription:(NSString *)localizedDescription localizedRecoverySuggestion:(NSString *)localizedRecoverySuggestion {
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey: localizedDescription ?: @"",
        NSLocalizedRecoverySuggestionErrorKey: localizedRecoverySuggestion ?: @""
    };

    return [OguryError errorWithDomain:[self getOguryErrorDomain] code:code userInfo:userInfo];
}

+ (NSString *)getOguryErrorDomain {
    return OguryErrorCoreDomain;
}

+ (instancetype)noInternetConnectionError {
    return [OguryError createOguryErrorWithCode:OguryCoreErrorTypeNoInternetConnection
                           localizedDescription:OguryCoreErrorTypeNoInternetConnectionDesc
                    localizedRecoverySuggestion:OguryCoreErrorTypeNoInternetConnectionRecoverySugg];
}

@end

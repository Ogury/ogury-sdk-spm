//
//  Copyright © 2024 Ogury. All rights reserved.
//

#import <OguryCore/OguryError.h>

typedef NS_ENUM(NSInteger, OguryCoreErrorType) {
    OguryCoreErrorTypeNoInternetConnection = 0
};

@interface OguryError (Internal)

+ (instancetype)createOguryErrorWithCode:(NSInteger)code;

+ (instancetype)createOguryErrorWithCode:(NSInteger)code localizedDescription:(NSString *)localizedDescription;

+ (instancetype)createOguryErrorWithCode:(NSInteger)code localizedDescription:(NSString *)localizedDescription localizedRecoverySuggestion:(NSString *)localizedRecoverySuggestion;

+ (NSString *)getOguryErrorDomain;

+ (instancetype)noInternetConnectionError;
@end

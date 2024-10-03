//
//  Copyright © 2024 Ogury. All rights reserved.
//

#import <OguryCore/OguryError.h>

@interface OguryError (Internal)

+ (instancetype)createOguryErrorWithCode:(NSInteger)code;

+ (instancetype)createOguryErrorWithCode:(NSInteger)code localizedDescription:(NSString *)localizedDescription;

+ (instancetype)createOguryErrorWithCode:(NSInteger)code localizedDescription:(NSString *)localizedDescription localizedRecoverySuggestion:(NSString *)localizedRecoverySuggestion;

+ (NSString *)getOguryErrorDomain;

+ (instancetype)noInternetConnectionError;
@end

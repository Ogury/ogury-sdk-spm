//
//  JSONModelError.m
//  JSONModel
//

#import "OGAJSONModelError.h"

NSString *const OGAJSONModelErrorDomain = @"JSONModelErrorDomain";
NSString *const kOGAJSONModelMissingKeys = @"kJSONModelMissingKeys";
NSString *const kOGAJSONModelTypeMismatch = @"kJSONModelTypeMismatch";
NSString *const kOGAJSONModelKeyPath = @"kJSONModelKeyPath";

@implementation OGAJSONModelError

+ (id)errorInvalidDataWithMessage:(NSString *)message {
    message = [NSString stringWithFormat:@"Invalid JSON data: %@", message];
    return [OGAJSONModelError errorWithDomain:OGAJSONModelErrorDomain
                                         code:kOGAJSONModelErrorInvalidData
                                     userInfo:@{NSLocalizedDescriptionKey : message}];
}

+ (id)errorInvalidDataWithMissingKeys:(NSSet *)keys {
    return [OGAJSONModelError errorWithDomain:OGAJSONModelErrorDomain
                                         code:kOGAJSONModelErrorInvalidData
                                     userInfo:@{NSLocalizedDescriptionKey : @"Invalid JSON data. Required JSON keys are missing from the input. Check the error user information.", kOGAJSONModelMissingKeys : [keys allObjects]}];
}

+ (id)errorInvalidDataWithTypeMismatch:(NSString *)mismatchDescription {
    return [OGAJSONModelError errorWithDomain:OGAJSONModelErrorDomain
                                         code:kOGAJSONModelErrorInvalidData
                                     userInfo:@{NSLocalizedDescriptionKey : @"Invalid JSON data. The JSON type mismatches the expected type. Check the error user information.", kOGAJSONModelTypeMismatch : mismatchDescription}];
}

+ (id)errorBadResponse {
    return [OGAJSONModelError errorWithDomain:OGAJSONModelErrorDomain
                                         code:kOGAJSONModelErrorBadResponse
                                     userInfo:@{NSLocalizedDescriptionKey : @"Bad network response. Probably the JSON URL is unreachable."}];
}

+ (id)errorBadJSON {
    return [OGAJSONModelError errorWithDomain:OGAJSONModelErrorDomain
                                         code:kOGAJSONModelErrorBadJSON
                                     userInfo:@{NSLocalizedDescriptionKey : @"Malformed JSON. Check the JSONModel data input."}];
}

+ (id)errorModelIsInvalid {
    return [OGAJSONModelError errorWithDomain:OGAJSONModelErrorDomain
                                         code:kOGAJSONModelErrorModelIsInvalid
                                     userInfo:@{NSLocalizedDescriptionKey : @"Model does not validate. The custom validation for the input data failed."}];
}

+ (id)errorInputIsNil {
    return [OGAJSONModelError errorWithDomain:OGAJSONModelErrorDomain
                                         code:kOGAJSONModelErrorNilInput
                                     userInfo:@{NSLocalizedDescriptionKey : @"Initializing model with nil input object."}];
}

- (instancetype)errorByPrependingKeyPathComponent:(NSString *)component {
    // Create a mutable  copy of the user info so that we can add to it and update it
    NSMutableDictionary *userInfo = [self.userInfo mutableCopy];

    // Create or update the key-path
    NSString *existingPath = userInfo[kOGAJSONModelKeyPath];
    NSString *separator = [existingPath hasPrefix:@"["] ? @"" : @".";
    NSString *updatedPath = (existingPath == nil) ? component : [component stringByAppendingFormat:@"%@%@", separator, existingPath];
    userInfo[kOGAJSONModelKeyPath] = updatedPath;

    // Create the new error
    return [OGAJSONModelError errorWithDomain:self.domain
                                         code:self.code
                                     userInfo:[NSDictionary dictionaryWithDictionary:userInfo]];
}

@end

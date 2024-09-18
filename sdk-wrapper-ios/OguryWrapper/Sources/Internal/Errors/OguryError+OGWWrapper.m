//
//  OguryError+OGWWrapper.m
//

#import "OguryError+OGWWrapper.h"
#import "OGWErrorMessage.h"

@implementation OguryError (OGWErrorCode)

+ (instancetype)createFailedStartingOguryModuleError:(NSString *)errorMessage {
    return [OguryError createOguryErrorWithCode:OGWErrorFailedStartingOguryModule
                           localizedDescription:errorMessage];
}

+ (instancetype)createNoSDKModuleFoundError {
    return [OguryError createOguryErrorWithCode:OGWErrorNoSdkModuleFound
                           localizedDescription:OGWErrorNoSdkModuleFoundMessage];
}

@end

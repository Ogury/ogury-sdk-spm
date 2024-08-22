//
//  OguryError+OGWWrapper.m
//

#import "OguryError+OGWWrapper.h"
#import "OGWErrorMessage.h"

@implementation OguryError (OGWErrorCode)

+ (instancetype)createFailedStartingOguryModuleError {
    return [OguryError createOguryErrorWithCode:OGWErrorFailedStartingOguryModule
                           localizedDescription:OGWErrorFailedStartingOguryModuleMessage];
}

+ (instancetype)createNoSDKModuleFoundError {
    return [OguryError createOguryErrorWithCode:OGWErrorNoSdkModuleFound
                           localizedDescription:OGWErrorNoSdkModuleFoundMessage];
}

@end

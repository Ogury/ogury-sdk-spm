//
//  OguryError+OGWWrapper.m
//

#import "OguryError+OGWWrapper.h"
#import "OGWErrorMessage.h"
#import "OguryStartErrorCode.h"

@implementation OguryError (OGWErrorCode)

+ (instancetype)createFailedStartingOguryModuleError:(NSString *)errorMessage {
    return [OguryError createOguryErrorWithCode:OguryStartErrorCodeFailedStartingModule
                           localizedDescription:errorMessage];
}

+ (instancetype)createNoSDKModuleFoundError {
    return [OguryError createOguryErrorWithCode:OguryStartErrorCodeNoModuleFound
                           localizedDescription:OGWErrorNoSdkModuleFoundMessage];
}

@end

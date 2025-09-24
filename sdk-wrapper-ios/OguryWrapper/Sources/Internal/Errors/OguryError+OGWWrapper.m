//
//  OguryError+OGWWrapper.m
//

#import "OguryError+OGWWrapper.h"
#import "OGWErrorMessage.h"
#import "OguryStartErrorCode.h"
#import <OguryCore/OguryError+internal.h>

@implementation OguryError (OGWErrorCode)

+ (instancetype)createModuleMissingError {
    return [OguryError createOguryErrorWithCode:OguryStartErrorCodeModuleMissing
                           localizedDescription:OguryStartErrorCodeModuleMissingDescription];
}

+ (instancetype)createModuleFailedToStartError:(NSString *)errorMessage {
    return [OguryError createOguryErrorWithCode:OguryStartErrorCodeModuleFailedToStart
                           localizedDescription:errorMessage];
}

@end

//
//  OguryError+OGWWrapper.h
//  OguryWrapper
//

#import <Foundation/Foundation.h>
#import "OGWWrapper.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, OGWErrorCode) {
    OGWErrorFailedStartingOguryModule = 1000,
    OGWErrorNoSdkModuleFound = 1001
};

@interface OguryError(OGWWrapper)

@end

NS_ASSUME_NONNULL_END

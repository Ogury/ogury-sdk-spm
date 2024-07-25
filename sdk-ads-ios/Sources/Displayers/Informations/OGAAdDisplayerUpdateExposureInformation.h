//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdDisplayerInformation.h"

@class OGAAdExposure;

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdDisplayerUpdateExposureInformation : NSObject <OGAAdDisplayerInformation>

#pragma mark - Properties

@property(nonatomic, strong, readonly) OGAAdExposure *adExposure;

#pragma mark - Initialization

- (instancetype)initWithExposure:(OGAAdExposure *)adExposure;

@end

NS_ASSUME_NONNULL_END

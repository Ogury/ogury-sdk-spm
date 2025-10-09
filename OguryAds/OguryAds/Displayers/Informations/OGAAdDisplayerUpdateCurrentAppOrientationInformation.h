//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdDisplayerInformation.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdDisplayerUpdateCurrentAppOrientationInformation : NSObject <OGAAdDisplayerInformation>

#pragma mark - Properties

@property(nonatomic, copy, readonly) NSString *orientation;
@property(nonatomic, readonly) BOOL locked;

#pragma mark - Initialization

- (instancetype)initWithOrientation:(NSString *)orientation locked:(BOOL)locked;

@end

NS_ASSUME_NONNULL_END

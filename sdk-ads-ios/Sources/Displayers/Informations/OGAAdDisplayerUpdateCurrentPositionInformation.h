//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import "OGAAdDisplayerInformation.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdDisplayerUpdateCurrentPositionInformation : NSObject <OGAAdDisplayerInformation>

#pragma mark - Initialization

- (instancetype)initWithPosition:(CGPoint)position size:(CGSize)size;

@end

NS_ASSUME_NONNULL_END

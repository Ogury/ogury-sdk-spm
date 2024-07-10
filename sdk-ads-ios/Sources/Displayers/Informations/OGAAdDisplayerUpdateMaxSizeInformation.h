//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OGAAdDisplayerInformation.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdDisplayerUpdateMaxSizeInformation : NSObject <OGAAdDisplayerInformation>

#pragma mark - Properties

@property(nonatomic, readonly) CGSize size;

#pragma mark - Initialization

- (instancetype)initWithSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END

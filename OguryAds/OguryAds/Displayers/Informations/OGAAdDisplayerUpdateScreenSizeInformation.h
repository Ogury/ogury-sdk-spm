//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OGAAdDisplayerInformation.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdDisplayerUpdateScreenSizeInformation : NSObject <OGAAdDisplayerInformation>

#pragma mark - Properties

@property(nonatomic, assign) CGSize size;

#pragma mark - Initialization

- (instancetype)initWithSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END

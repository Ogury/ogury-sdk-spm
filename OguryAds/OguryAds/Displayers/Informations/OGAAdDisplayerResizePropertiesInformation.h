//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdDisplayerInformation.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdDisplayerResizePropertiesInformation : NSObject <OGAAdDisplayerInformation>

#pragma mark - Properties

@property(nonatomic, assign) int width;
@property(nonatomic, assign) int height;
@property(nonatomic, assign) int xOffset;
@property(nonatomic, assign) int yOffset;

#pragma mark - Initialization

- (instancetype)initWithWidth:(int)width height:(int)height xOffset:(int)xOffset yOffset:(int)yOffset;

@end

NS_ASSUME_NONNULL_END

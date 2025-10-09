//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdDisplayerInformation.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdDisplayerUpdateViewabilityInformation : NSObject <OGAAdDisplayerInformation>

#pragma mark - Properties

@property(nonatomic, assign) BOOL isViewable;

#pragma mark - Initialization

- (instancetype)initWithViewability:(BOOL)isViewable;

@end

NS_ASSUME_NONNULL_END

//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdDisplayerInformation.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdDisplayerUpdatePlacementInformation : NSObject <OGAAdDisplayerInformation>

#pragma mark - Constants

typedef NS_ENUM(NSInteger, OGAAdDisplayerPlacement) {
    OGAAdDisplayerPlacementInline,
    OGAAdDisplayerPlacementInterstitial
};

#pragma mark - Properties

@property(nonatomic, assign) OGAAdDisplayerPlacement placement;

#pragma mark - Initialization

- (instancetype)initWithPlacement:(OGAAdDisplayerPlacement)placement;

@end

NS_ASSUME_NONNULL_END

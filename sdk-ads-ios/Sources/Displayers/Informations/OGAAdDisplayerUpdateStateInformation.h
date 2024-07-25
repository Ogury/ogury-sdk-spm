//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdDisplayerInformation.h"
#import "OGAMRAIDState.h"

@class OGAAdExposure;

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdDisplayerUpdateStateInformation : NSObject <OGAAdDisplayerInformation>

#pragma mark - Properties

@property(nonatomic, copy, readonly) NSString *mraidState;
@property(nonatomic) OGAMRAIDState rawMraidState;

#pragma mark - Initialization

- (instancetype)initWithMraidState:(OGAMRAIDState)mraidState;

@end

NS_ASSUME_NONNULL_END

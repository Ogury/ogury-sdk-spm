//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAJSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAMraidSetOrientationPropertiesCommand : OGAJSONModel
@property(nonatomic, assign) NSNumber *allowOrientationChange;
@property(nonatomic, copy) NSString *forceOrientation;
@end

NS_ASSUME_NONNULL_END

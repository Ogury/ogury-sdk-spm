//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdDisplayerInformation.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdDisplayerUserCloseSKOverlayInformation : NSObject <OGAAdDisplayerInformation>

#pragma mark - Properties

@property(nonatomic, strong, readonly) NSNumber *errorCode;

#pragma mark - Initialization

- (instancetype)initWithErrorCode:(NSNumber *_Nullable)errorCode;

@end

NS_ASSUME_NONNULL_END

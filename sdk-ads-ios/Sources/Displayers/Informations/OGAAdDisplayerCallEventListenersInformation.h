//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdDisplayerInformation.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdDisplayerCallEventListenersInformation : NSObject <OGAAdDisplayerInformation>

#pragma mark - Properties

@property(nonatomic, copy, readonly) NSString *trigger;
@property(nonatomic, strong, readonly) NSDictionary *parameters;

#pragma mark - Initialization

- (instancetype)initWithEvent:(NSString *)trigger parameters:(NSDictionary *)parameters;

@end

NS_ASSUME_NONNULL_END

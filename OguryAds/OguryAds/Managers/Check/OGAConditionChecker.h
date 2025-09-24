//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryError.h>

#import "OGAAdSequence.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Protocol describing a condition before loading or displaying a sequence.
 */
@protocol OGAConditionChecker <NSObject>

- (BOOL)checkForSequence:(OGAAdSequence *)sequence error:(OguryError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END

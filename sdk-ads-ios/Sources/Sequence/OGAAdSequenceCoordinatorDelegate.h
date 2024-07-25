//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OGAAdSequence;

NS_ASSUME_NONNULL_BEGIN

@protocol OGAAdSequenceCoordinatorDelegate <NSObject>

- (void)didCloseSequence:(OGAAdSequence *)sequence;

@end

NS_ASSUME_NONNULL_END

//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdAction.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Constants

extern NSString *const OGAShowAdActionName;

@interface OGAShowAdAction : NSObject <OGAAdAction>

#pragma mark - Properties

@property(nonatomic, strong) NSString *name;

#pragma mark - Methods

- (BOOL)performAction:(nonnull OGAAdContainer *)adContainer error:(OguryAdError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END

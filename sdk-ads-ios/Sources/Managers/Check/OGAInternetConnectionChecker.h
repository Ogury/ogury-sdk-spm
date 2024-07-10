//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import "OGAConditionChecker.h"

@interface OGAInternetConnectionChecker : NSObject <OGAConditionChecker>

#pragma mark - Initialization

+ (instancetype _Nonnull)shared;

- (BOOL)checkForSequence:(OGAAdSequence *_Nullable)sequence error:(OguryError *_Nullable *_Nullable)error;

@end

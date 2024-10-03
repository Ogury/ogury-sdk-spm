//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdAction.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAForceCloseAdAction : NSObject <OGAAdAction>

#pragma mark - Constants

extern NSString *const OGAForceCloseAdActionName;

#pragma mark - Properties

@property(nonatomic, strong) NSString *name;

#pragma mark - Methods

- (BOOL)performAction:(OGAAdContainer *)adContainer error:(OguryAdError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END

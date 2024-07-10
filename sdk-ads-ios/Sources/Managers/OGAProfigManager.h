//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAProfigService.h"

@class OGABroadcastEventBus;
@class OGAAdPrivacyConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface OGAProfigManager : NSObject

#pragma mark - properties

@property(nonatomic, copy) NSString *currentUserAgent;
@property(nonatomic, strong) OGABroadcastEventBus *broadcastEventBus;

#pragma mark - Class methods

+ (instancetype)shared;

#pragma mark - @methods

- (void)resetProfig;
- (void)syncProfigWithCompletion:(ProfigCompletionBlock)completion;
- (BOOL)profigParametersWereUpdated;
- (BOOL)shouldSync;
- (void)registerToBroadcastEventBus;
- (OGAAdPrivacyConfiguration *_Nonnull)currentPrivacyConfiguration;

@end

NS_ASSUME_NONNULL_END

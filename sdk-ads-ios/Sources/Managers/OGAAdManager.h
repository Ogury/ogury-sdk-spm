//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGADelegateDispatcher.h"
#import "OGAConfigurationUtils.h"
#import "OGAConditionChecker.h"

@class OGAAdSequence;
@class OGAAdConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdManager : NSObject

#pragma mark - @properties

@property(nonatomic, assign, setter=defineSDKType:) OGASDKType sdkType;
@property(nonatomic, copy, setter=defineMediationName:) NSString *mediation;

#pragma mark - Class Methods

+ (instancetype)sharedManager;

#pragma mark - Methods

- (OGAAdSequence *)loadAdConfiguration:(OGAAdConfiguration *)configuration
                      previousSequence:(OGAAdSequence *_Nullable)previousSequence;

- (void)show:(OGAAdSequence *)sequence additionalConditions:(NSArray<id<OGAConditionChecker>> *_Nullable)additionalConditions;

- (void)defineSDKType:(OGASDKType)sdkType;
- (void)defineMediationName:(NSString *)mediationName;
- (BOOL)isLoaded:(OGAAdSequence *_Nullable)sequence;
- (BOOL)isExpired:(OGAAdSequence *)sequence;
- (BOOL)isExpanded:(OGAAdSequence *_Nullable)sequence;
- (void)close:(OGAAdSequence *)sequence;

- (BOOL)isKilled:(OGAAdSequence *)sequence;

@end

NS_ASSUME_NONNULL_END

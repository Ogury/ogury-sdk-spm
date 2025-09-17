//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAProfigService.h"

@class OGAAdPrivacyConfiguration;
@class OGAAdQualityConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface OGAProfigManager : NSObject

#pragma mark - properties

@property(nonatomic, copy) NSString *currentUserAgent;

#pragma mark - Class methods

+ (instancetype)shared;

#pragma mark - @methods

- (void)resetProfig;
- (void)syncProfigWithCompletion:(ProfigCompletionBlock)completion;
- (BOOL)profigParametersWereUpdated;
- (BOOL)shouldSync;
- (OGAAdPrivacyConfiguration *_Nonnull)currentPrivacyConfiguration;
- (OGAAdQualityConfiguration *_Nonnull)currentAdQualityConfiguration;

@end

NS_ASSUME_NONNULL_END

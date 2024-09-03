//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGADelegateDispatcher.h"
#import "OguryMediation.h"

@class OGAAdManager;

NS_ASSUME_NONNULL_BEGIN

@protocol OGAAdInternalAPI <NSObject>

#pragma mark - Properties

@property(nonatomic, copy, readonly) NSString *adUnitId;
@property(nonatomic, copy, readonly, nullable) OguryMediation *mediation;

#pragma mark - Initialization

- (instancetype)initWithAdUnitId:(NSString *)adUnitId
              delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher
                       mediation:(OguryMediation *_Nullable)mediation;

#pragma mark - Methods

- (void)load;

- (BOOL)isLoaded;

@end

NS_ASSUME_NONNULL_END

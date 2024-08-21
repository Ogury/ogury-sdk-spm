//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OguryConfiguration.h"
#import <OguryCore/OguryLogLevel.h>
#import "Ogury.h"


NS_ASSUME_NONNULL_BEGIN

@interface OGWWrapper : NSObject

#pragma mark - Methods

+ (instancetype)shared;

- (void)startWithConfiguration:(OguryConfiguration *)configuration completionHandler:(SetupCompletionBlock _Nullable)completionHandler;

- (void)setLogLevel:(OguryLogLevel)logLevel;

- (void)registerAttributionForSKAdNetwork;

@end

NS_ASSUME_NONNULL_END

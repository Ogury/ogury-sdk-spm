//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OGAAdSequence;
@class OGAAd;
@class OGAAdConfiguration;
@class OGAAdController;

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdControllerFactory : NSObject

#pragma mark - Methods

- (void)createControllersForSequence:(OGAAdSequence *)sequence ads:(NSArray<OGAAd *> *)ads configuration:(OGAAdConfiguration *)configuration;

- (OGAAdController *)createControllerForAd:(OGAAd *)ad sequence:(OGAAdSequence *)sequence configuration:(OGAAdConfiguration *)configuration;

@end

NS_ASSUME_NONNULL_END

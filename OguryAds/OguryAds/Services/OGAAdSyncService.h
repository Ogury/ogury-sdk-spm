//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdPrivacyConfiguration.h"

@class OGAAdConfiguration;
@class OGAAd;

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdSyncService : NSObject

#pragma mark - Methods

- (void)postAdSyncForAdConfiguration:(OGAAdConfiguration *)configuration
                privacyConfiguration:(OGAAdPrivacyConfiguration *)privacyConfiguration
                   completionHandler:(void (^)(NSArray<OGAAd *> *ads, NSError *_Nullable error))completionHandler;

- (void)fetchCustomCloseWithURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END

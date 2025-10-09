//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OGAAdConfiguration;
@class OGAAdPrivacyConfiguration;
@class OGAAd;

NS_ASSUME_NONNULL_BEGIN

typedef void (^OGAAdSyncCompletionHandler)(NSArray<OGAAd *> *_Nullable ads, NSError *_Nullable error);

@interface OGAAdSyncManager : NSObject

#pragma mark - Class Methods

+ (instancetype)shared;

#pragma mark - Methods

- (void)postAdSyncForAdConfiguration:(OGAAdConfiguration *)adConfiguration
                privacyConfiguration:(OGAAdPrivacyConfiguration *)privacyConfiguration
                   completionHandler:(OGAAdSyncCompletionHandler)completionHandler;

- (void)fetchCustomCloseWithURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END

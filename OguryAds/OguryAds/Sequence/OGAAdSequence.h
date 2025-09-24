//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGAAdConfiguration.h"
#import "OGAAdPrivacyConfiguration.h"

@class OGAAdSequenceCoordinator;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, OGAAdSequenceStatus) {
    OGAAdSequenceStatusLoading,
    OGAAdSequenceStatusLoaded,
    OGAAdSequenceStatusShown,
    OGAAdSequenceStatusClosed,
    OGAAdSequenceStatusInitError,
    OGAAdSequenceStatusError
};

@interface OGAAdSequence : NSObject

#pragma mark - Properties

@property(nonatomic, assign) OGAAdSequenceStatus status;
@property(nonatomic, strong, nullable) OGAAdSequenceCoordinator *coordinator;
@property(nonatomic, strong, readonly) OGAAdConfiguration *configuration;
@property(nonatomic, strong, nullable) OGAAdPrivacyConfiguration *privacyConfiguration;

#pragma mark - Initialization

- (instancetype)initWithAdConfiguration:(OGAAdConfiguration *)configuration;
- (void)updateReloadStateWithSessionId:(NSString *)sessionId;
- (OGAAdConfiguration *)monitoringAdConfiguration;

@end

NS_ASSUME_NONNULL_END

//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGAAdDisplayer.h"
#import "OGAProfigDao.h"
#import "OGAAdExposureController.h"
#import "OGAAdExposureDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol OGAAdContainerState <NSObject>

typedef NS_ENUM(NSInteger, OGAAdContainerStateType) {
    OGAAdContainerStateTypeInitial,
    OGAAdContainerStateTypeInline,
    OGAAdContainerStateTypeOverlay,
    OGAAdContainerStateTypeFullScreenOverlay,
    OGAAdContainerStateTypeClosed,
    OGAAdContainerStateTypeUnknown
};

#pragma mark - Properties

@property(nonatomic, strong, readonly) NSString *name;
@property(nonatomic, assign, readonly) OGAAdContainerStateType type;
@property(nonatomic, strong, readonly) id<OGAAdDisplayer> displayer;
@property(nonatomic, strong, readonly) OGAAdExposureController *exposureController;
@property(nonatomic, assign, readonly) BOOL isExpanded;

#pragma mark - Initialization

- (instancetype)init;

#pragma mark - Methods

- (BOOL)display:(id<OGAAdDisplayer>)displayer error:(OguryAdError *_Nullable *_Nullable)error;

- (void)cleanUp;

- (void)forceClose;

- (void)registerForApplicationLifecycleNotifications;

- (void)unregisterForApplicationLifecycleNotifications;

- (void)updateViewablityIfNecessary:(OGAAdExposure *)exposure;

@end

NS_ASSUME_NONNULL_END

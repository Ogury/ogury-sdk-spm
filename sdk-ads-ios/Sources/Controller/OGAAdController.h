//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryCore.h>
#import "OGAAdControllerDelegate.h"
#import "OGAAdDisplayer.h"
#import "OGAExpirationContext.h"

@class OGAAd;
@class OGAAdConfiguration;
@class OGAAdContainer;

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdController : NSObject

#pragma mark - Properties

@property(nonatomic, strong) OGAAd *ad;
@property(nonatomic, weak) id<OGAAdControllerDelegate> delegate;

@property(nonatomic, assign, readonly) BOOL isLoaded;
@property(nonatomic, assign, readonly) BOOL isKilled;
@property(nonatomic, strong) OGAExpirationContext *expirationContext;
@property(nonatomic, assign, readonly) BOOL isExpired;
@property(nonatomic, assign, readonly) BOOL isDisplayed;
@property(nonatomic, assign, readonly) BOOL isExpanded;
@property(nonatomic, assign, readonly) BOOL isOverlay;
@property(nonatomic, assign, readonly) BOOL isFullScreenOverlay;
@property(nonatomic, assign, readonly) BOOL isClosed;
@property(nonatomic, strong, readonly) NSDate *createdAt;

#pragma mark - Initialization

- (instancetype)initWithAd:(OGAAd *)ad
             configuration:(OGAAdConfiguration *)configuration
                 displayer:(id<OGAAdDisplayer>)displayer
                 container:(OGAAdContainer *)container;

#pragma mark - Methods

- (BOOL)show:(OguryAdError *_Nullable *_Nullable)error;

- (BOOL)hasNextAd;

- (void)forceClose;

@end

NS_ASSUME_NONNULL_END

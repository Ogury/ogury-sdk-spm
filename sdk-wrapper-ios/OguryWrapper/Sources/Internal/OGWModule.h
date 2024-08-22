//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryLogLevel.h>
#import "Ogury.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGWModule : NSObject

#pragma mark - Properties

@property(nonatomic, copy, readonly) NSString *className;

@property(nonatomic, assign, readonly) BOOL isPresent;

#pragma mark - Initialization

- (instancetype)initWithClassName:(NSString *)className;

#pragma mark - Methods

- (void)startWithAssetKey:(NSString *)assetKey completionHandler:(SetupCompletionBlock _Nullable)completionHandler;
- (void)setLogLevel:(OguryLogLevel)logLevel;

- (NSString *_Nullable)getVersion;

@end

NS_ASSUME_NONNULL_END

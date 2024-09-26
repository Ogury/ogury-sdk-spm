//
//  Copyright © 2022-present Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryLogLevel.h>
#import "Ogury.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGWModuleClassMock : NSObject

@property(class, nonatomic) OGWModuleClassMock *storedShared;
@property(nonatomic) OguryLogLevel storedLogLevel;
@property(nonatomic, nullable) NSString *storedAssetKey;

+ (instancetype)shared;

- (void)startWithAssetKey:(NSString *)assetKey completionHandler:(StartCompletionBlock _Nullable)completionHandler;

- (void)setLogLevel:(OguryLogLevel)logLevel;

@end

NS_ASSUME_NONNULL_END

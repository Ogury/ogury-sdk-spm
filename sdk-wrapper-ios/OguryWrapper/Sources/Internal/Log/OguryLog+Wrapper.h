//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryLog.h>

NS_ASSUME_NONNULL_BEGIN

@interface OguryLog (Wrapper)

- (void)ogwlogAssetKeyMessage:(OguryLogLevel)level assetKey:(NSString *)assetKey message:(NSString *)message;

@end

NS_ASSUME_NONNULL_END

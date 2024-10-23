//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryAbstractLogMessage.h>
#import <OguryCore/OguryStringFormattable.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGWAssetKeyLogMessage : OguryAbstractLogMessage <OguryStringFormattable>

#pragma mark - Properties

@property (nonatomic, copy) NSString *assetKey;

#pragma mark - Initialization

- (instancetype)initWithLevel:(OguryLogLevel)level assetKey:(NSString *)assetKey message:(NSString *)message;

@end

NS_ASSUME_NONNULL_END

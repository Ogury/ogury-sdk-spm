//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdDsp : NSObject

@property(nonatomic, copy) NSString *creativeId;
@property(nonatomic, copy) NSString *region;

- (instancetype)initWithCreativeId:(NSString *)creativeId region:(NSString *)region;

@end

NS_ASSUME_NONNULL_END

//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryError.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^HeaderBiddingCompletionBlock)(NSString *_Nullable token, OguryError *_Nullable error);

@interface OguryTokenService : NSObject

+ (void)bidderToken:(HeaderBiddingCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END

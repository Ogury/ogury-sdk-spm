//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryError.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^BidTokenCompletionBlock)(NSString *_Nullable bidToken, OguryError *_Nullable error);

@interface OguryBidTokenService : NSObject

+ (void)bidToken:(BidTokenCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END

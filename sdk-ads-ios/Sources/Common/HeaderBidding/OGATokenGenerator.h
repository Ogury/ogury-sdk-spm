//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGATokenGenerator : NSObject

- (NSString *_Nullable)generateBidderToken;
- (NSString *_Nullable)generateBidderToken:(NSString *)campaignId;
- (NSString *_Nullable)generateBidderToken:(NSString *)campaignId creativeId:(NSString *_Nullable)creativeId;
- (NSString *_Nullable)generateBidderToken:(NSString *)campaignId creativeId:(NSString *_Nullable)creativeId dspCreativeId:(NSString *_Nullable)dspCreativeId dspRegion:(NSString *_Nullable)dspRegion;

@end

NS_ASSUME_NONNULL_END

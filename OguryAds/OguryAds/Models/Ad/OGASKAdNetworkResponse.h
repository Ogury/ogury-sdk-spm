//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAJSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGASKAdNetworkResponse : OGAJSONModel

@property(nonatomic, strong) NSNumber *campaignId;
@property(nonatomic, strong) NSNumber *sourceIdentifier;
@property(nonatomic, strong) NSNumber *itunesItemId;
@property(nonatomic, strong) NSString *nonce;
@property(nonatomic, strong) NSString *networkIdentifier;
@property(nonatomic, strong) NSNumber *sourceAppId;
@property(nonatomic, strong) NSString *signature;
@property(nonatomic, strong) NSString *version;
@property(nonatomic, strong) NSNumber *timestamp;
@property(nonatomic, strong) NSNumber *fidelity;
@property(nonatomic, assign) BOOL isStoreKitDisplay;

@end

NS_ASSUME_NONNULL_END

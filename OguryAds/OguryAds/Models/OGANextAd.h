//
//  Copyright © 2019 Ogury. All rights reserved.
//

#import "OGAJSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGANextAd : OGAJSONModel

@property(nonatomic, strong, nullable) NSNumber *showNextAd;
@property(nonatomic, strong, nullable) NSString *nextAdId;

+ (BOOL)shouldShowNextAd:(OGANextAd *_Nullable)nextAd;

+ (NSString *_Nullable)nextAdId:(OGANextAd *_Nullable)nextAd;

+ (OGANextAd *)nextAdTrue;

+ (OGANextAd *)nextAdFalse;

@end

NS_ASSUME_NONNULL_END

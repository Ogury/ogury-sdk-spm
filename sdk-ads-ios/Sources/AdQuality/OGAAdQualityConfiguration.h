//
//  OGAAdQualityConfiguration.h
//  OguryAds
//
//  Created by Jerome TONNELIER on 28/08/2025.
//  Copyright © 2025 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdQualityUniformColorRectAlgorithm.h"
#import "OGAJSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdQualityBlankAdConfiguration<NSCoding> : OGAJSONModel
@property(nonatomic) BOOL isEnabled;
@property(nonatomic, retain) NSArray<OGAAdQualityUniformColorRectAlgorithm *> *_Nullable algos;
@end

@interface OGAAdQualityConfiguration<NSCoding> : OGAJSONModel
@property(nonatomic, retain) OGAAdQualityBlankAdConfiguration *_Nullable blankAdConfiguration;
@end

NS_ASSUME_NONNULL_END

//
//  OGAAdQualityController.m
//  OguryAds
//
//  Created by Jerome TONNELIER on 25/08/2025.
//  Copyright © 2025 Ogury Ltd. All rights reserved.
//

#import "OGAAdQualityController.h"
#import "OGAAdQualityAlgorithm.h"
#import "OGAAdQualityUniformColorRectAlgorithm.h"

@interface OGAAdQualityController ()

@end

@implementation OGAAdQualityController
@synthesize activeAlgorithms, isEnabled;

+ (instancetype)shared {
    static OGAAdQualityController *instance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[OGAAdQualityController alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
//        activeAlgorithms = @[
//            [[OGAAdQualityUniformColorRectAlgorithm alloc] initWithSize:CGSizeMake(50, 50)
//                                                              threshold:@(6)
//                                                             startDelay:@(1000)
//                                                         allowedFormats:@[ OGAAdConfigurationAdTypeInterstitial,
//                                                                           OGAAdConfigurationAdTypeRewarded,
//                                                                           OGAAdConfigurationAdTypeThumbnailAd,
//                                                                           OGAAdConfigurationAdTypeStandardBanners ]]
//        ];
        activeAlgorithms = @[];
        self.isEnabled = YES;
    }
    return self;
}

- (void)setUpFrom:(OGAAdQualityConfiguration *)configuration {
    NSMutableArray<id<OGAAdQualityAlgorithm>> *configAlgos = [@[] mutableCopy];
    [configuration.blankAdConfiguration.algos enumerateObjectsUsingBlock:^(OGAAdQualityUniformColorRectAlgorithm * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [configAlgos addObject:obj];
    }];
    self.activeAlgorithms = configAlgos;
    self.isEnabled = YES;
}

- (void)safeResultCompletionWithData:(NSArray<OGAAdQualityResult *> *)results completion:(AdQualityCompletionBlock _Nullable)completion {
    if (completion) {
        completion(results);
    }
}

- (void)performAdQualityChecksOn:(UIView *)view adConfiguration:(OGAAdConfiguration *)adConfiguration completion:(AdQualityCompletionBlock _Nullable)completion {
    if (!self.isEnabled) {
        [self safeResultCompletionWithData:@[] completion:completion];
        return;
    }
    dispatch_group_t group = dispatch_group_create();
    NSMutableArray<OGAAdQualityResult *> *results = [@[] mutableCopy];

    [self.activeAlgorithms enumerateObjectsUsingBlock:^(id<OGAAdQualityAlgorithm> _Nonnull algo, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([algo.allowedFormats containsObject:[adConfiguration getAdTypeString]]) {
            dispatch_group_enter(group);
            [algo performAdQualityCheckOn:view
                          adConfiguration:adConfiguration
                               completion:^(OGAAdQualityResult *_Nonnull result) {
                                   [results addObject:result];
                                   dispatch_group_leave(group);
                               }];
        }
    }];

    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self safeResultCompletionWithData:results completion:completion];
    });
}

- (void)performAdQualityChecksOn:(UIView *)view adConfiguration:(OGAAdConfiguration *)adConfiguration {
    [self performAdQualityChecksOn:view adConfiguration:adConfiguration completion:nil];
}
@end

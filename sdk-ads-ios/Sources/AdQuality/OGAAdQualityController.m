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
@property(nonatomic, retain) NSArray<id<OGAAdQualityAlgorithm>> *activeAlgorithms;
@end

@implementation OGAAdQualityController
@synthesize activeAlgorithms;

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
        activeAlgorithms = @[];
    }
    return self;
}

- (void)reset {
    self.activeAlgorithms = @[];
}

- (void)setUpFrom:(OGAAdQualityConfiguration *)configuration {
    NSMutableArray<id<OGAAdQualityAlgorithm>> *configAlgos = [@[] mutableCopy];
    if (configuration.blankAdConfiguration.isEnabled) {
        [configuration.blankAdConfiguration.algos enumerateObjectsUsingBlock:^(OGAAdQualityUniformColorRectAlgorithm * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [configAlgos addObject:obj];
        }];
    }
    self.activeAlgorithms = configAlgos;
}

- (void)safeResultCompletionWithData:(NSArray<OGAAdQualityResult *> *)results completion:(AdQualityCompletionBlock _Nullable)completion {
    if (completion) {
        completion(results);
    }
}

- (void)performAdQualityChecksOn:(UIView *)view adConfiguration:(OGAAdConfiguration *)adConfiguration completion:(AdQualityCompletionBlock _Nullable)completion {
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

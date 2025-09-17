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
- (instancetype)initFrom:(OGAAdQualityConfiguration *)configuration {
    if (self = [super init]) {
        NSMutableArray<id<OGAAdQualityAlgorithm>> *configAlgos = [@[] mutableCopy];
        if (configuration.blankAdConfiguration.isEnabled) {
            [configuration.blankAdConfiguration.algos enumerateObjectsUsingBlock:^(OGAAdQualityUniformColorRectAlgorithm * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [configAlgos addObject:(id<OGAAdQualityAlgorithm>)obj];
            }];
        }
        self.activeAlgorithms = configAlgos;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"🐳 OGAAdQualityController dealloc");
}

-(void)cleanUp {
    [self.activeAlgorithms enumerateObjectsUsingBlock:^(id<OGAAdQualityAlgorithm>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.isCancelled = YES;
    }];;
}

- (void)safeResultCompletionWithData:(NSArray<OGAAdQualityResult *> *)results completion:(AdQualityCompletionBlock _Nullable)completion {
    if (completion) {
        completion(results);
    }
}

- (void)performAdQualityChecksOn:(UIView *)view adConfiguration:(OGAAdConfiguration *)adConfiguration completion:(AdQualityCompletionBlock _Nullable)completion {NSMutableArray<OGAAdQualityResult *> *results = [@[] mutableCopy];
    if (self.activeAlgorithms.count == 0) {
        [self safeResultCompletionWithData:results completion:completion];
        return;
    }
    
    dispatch_group_t group = dispatch_group_create();
    
    [self.activeAlgorithms enumerateObjectsUsingBlock:^(id<OGAAdQualityAlgorithm> _Nonnull algo, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([algo computationEnabledFor:adConfiguration]) {
            dispatch_group_enter(group);
            [algo performAdQualityCheckOn:view
                          adConfiguration:adConfiguration
                               completion:^(OGAAdQualityResult *_Nullable result) {
                if (result) {
                    [results addObject:result];
                }
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

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[OGAAdQualityController class]] == NO) {
        return NO;
    }
    OGAAdQualityController *qualityController = (OGAAdQualityController *)object;
    return [qualityController.activeAlgorithms isEqualToArray:self.activeAlgorithms];
}

@end

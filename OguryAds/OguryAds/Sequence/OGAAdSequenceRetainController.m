//.
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import "OGAAdSequenceRetainController.h"

@interface OGAAdSequenceRetainController ()

@property(nonatomic, strong) NSMapTable<OGAAdSequence *, NSHashTable *> *controllersRetainingSequenceMap;

@end

@implementation OGAAdSequenceRetainController

#pragma mark - Initialization

- (instancetype)init {
    if (self = [super init]) {
        _controllersRetainingSequenceMap = [NSMapTable strongToStrongObjectsMapTable];
    }
    return self;
}

+ (instancetype)shared {
    static OGAAdSequenceRetainController *instance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });

    return instance;
}

#pragma mark - Methods

- (void)retainSequence:(OGAAdSequence *)sequence fromController:(OGAAdController *)controller {
    NSHashTable *controllers = [self.controllersRetainingSequenceMap objectForKey:sequence];
    if (!controllers) {
        controllers = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory capacity:1];
        [controllers addObject:controller];
        [self.controllersRetainingSequenceMap setObject:controllers forKey:sequence];
    } else if (![controllers containsObject:controller]) {
        [controllers addObject:controller];
    }
}

- (void)releaseSequence:(OGAAdSequence *)sequence fromController:(OGAAdController *)controller {
    NSHashTable *controllers = [self.controllersRetainingSequenceMap objectForKey:sequence];
    if (controllers) {
        [controllers removeObject:controller];
        if (controllers.count == 0) {
            [self.controllersRetainingSequenceMap removeObjectForKey:sequence];
        }
    }
}

@end

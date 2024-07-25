//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAInitialAdContainerState.h"

NSString *const OGAInitialAdContainerStateState = @"initial";

@interface OGAInitialAdContainerState ()

@property(nonatomic, strong, readwrite) id<OGAAdDisplayer> displayer;

@end

@implementation OGAInitialAdContainerState

@synthesize displayer = _displayer;

#pragma mark - Initialization

- (instancetype)initWithDisplayer:(id<OGAAdDisplayer>)displayer {
    if (self = [super init]) {
        _displayer = displayer;
    }
    return self;
}

#pragma mark - Properties

- (NSString *)name {
    return @"initial";
}

- (OGAAdContainerStateType)type {
    return OGAAdContainerStateTypeInitial;
}

@end

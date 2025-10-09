//
// Copyright (c) 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGAAdContainer.h"

@interface OGAAdContainer (Testing)

- (_Nullable id<OGAAdContainerTransition>)findTransitionForAction:(NSString *)action initialState:(id<OGAAdContainerState>)initialState;

@end

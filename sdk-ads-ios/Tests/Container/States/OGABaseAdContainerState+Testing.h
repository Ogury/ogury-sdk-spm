//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGABaseAdContainerState.h"
#import "OGAAdDisplayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGABaseAdContainerState (Testing)

@property(nonatomic, strong) id<OGAAdDisplayer> displayer;

@property(nonatomic, assign) BOOL currentViewabilityStatus;

- (void)overrideDisplayer:(id<OGAAdDisplayer>)displayer;

@end

NS_ASSUME_NONNULL_END

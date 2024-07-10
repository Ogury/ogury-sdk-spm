//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAClosedAdContainerState.h"
#import "OGAAdDisplayer.h"
#import "OGAMraidAdWebView.h"

@implementation OGAClosedAdContainerState

#pragma mark - Properties

- (NSString *)name {
    return @"closed";
}

- (OGAAdContainerStateType)type {
    return OGAAdContainerStateTypeClosed;
}

#pragma mark - Methods

- (BOOL)display:(id<OGAAdDisplayer>)displayer error:(OguryError *_Nullable *_Nullable)error {
    // Allow for displayer to perform some cleanup before closing
    [displayer cleanUp];

    return YES;
}

@end

//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdAction.h"

NS_ASSUME_NONNULL_BEGIN

@protocol OGAAdDisplayerDelegate <NSObject>

#pragma mark - Methods

typedef NS_ENUM(NSUInteger, UnloadOrigin) {
    UnloadOriginFormat,
    UnloadOriginTimeout
};

- (void)didLoad;
- (void)didUnLoadFrom:(UnloadOrigin)unloadOrigin;
- (BOOL)performAction:(id<OGAAdAction>)action error:(OguryAdError *_Nullable *_Nullable)error;
- (BOOL)adIsDisplayed;
- (void)webkitProcessDidTerminate;

@end

NS_ASSUME_NONNULL_END

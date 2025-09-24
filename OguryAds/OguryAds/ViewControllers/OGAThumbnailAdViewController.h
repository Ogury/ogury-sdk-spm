//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OGAAdDisplayer.h"
#import "OGAAdExposureController.h"
#import "OGAAdDisplayerOrientationDelegate.h"

@class OGAThumbnailAdWindow;

NS_ASSUME_NONNULL_BEGIN

@interface OGAThumbnailAdViewController : UIViewController <OGAAdExposureDelegate, OGAAdDisplayerOrientationDelegate>

#pragma mark - Properties

@property(nonatomic, weak, readonly, nullable) id<OGAAdDisplayer> displayer;

@property(nonatomic, strong, readonly, nullable) OGAAdExposureController *exposureController;

#pragma mark - Initialization

- (instancetype)initWithWindow:(OGAThumbnailAdWindow *)window;

#pragma mark - Methods

- (BOOL)display:(id<OGAAdDisplayer>)displayer error:(OguryError *_Nullable *_Nullable)error;

- (void)cleanUp;

- (void)updateThumbnailAdWithAnimation:(BOOL)animation;

- (void)updateThumbnailToExpandedFormatWithDisplayer:(id<OGAAdDisplayer>)displayer;

- (void)updateThumbnailWithDisplayer:(id<OGAAdDisplayer>)displayer;

@end

NS_ASSUME_NONNULL_END

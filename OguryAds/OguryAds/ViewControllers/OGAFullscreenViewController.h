//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OguryCore/OguryError.h>
#import "OGAAdDisplayer.h"
#import "OGAAdExposureController.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAFullscreenViewController : UIViewController

@property(nonatomic, strong, readonly) OGAAdExposureController *exposureController;

- (instancetype)initWithExposureController:(OGAAdExposureController *)exposureController;

- (BOOL)display:(id<OGAAdDisplayer>)displayer error:(OguryError *_Nullable *_Nullable)error;

- (void)cleanUp;

@end

NS_ASSUME_NONNULL_END

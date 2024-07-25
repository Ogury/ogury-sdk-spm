//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OGAAdDisplayer.h"
#import "OGAThumbnailAdViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAThumbnailAdWindow : UIWindow

#pragma mark - Properties

@property(nonatomic, assign) BOOL isDraggable;

@property(nonatomic, assign) BOOL isExpanded;

@property(nonatomic, strong, readonly) OGAThumbnailAdViewController *thumbnailAdViewController;

#pragma mark - Initialization

- (instancetype)initWithDisplayer:(id<OGAAdDisplayer>)displayer;

#pragma mark - Methods

- (BOOL)display:(id<OGAAdDisplayer>)displayer error:(OguryError *_Nullable *_Nullable)error;

- (void)cleanUp;

@end

NS_ASSUME_NONNULL_END

//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGAFullscreenAdContainerState.h"
#import "OGAFullscreenViewController.h"

@interface OGAFullscreenAdContainerState (Testing)

@property(nonatomic, strong) OGAFullscreenViewController *fullscreenViewController;

- (OGAFullscreenViewController *)createFullscreenViewController;

- (void)cleanUp;

@end

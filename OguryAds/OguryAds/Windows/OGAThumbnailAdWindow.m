//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAThumbnailAdWindow.h"
#import "OGAMraidUtils.h"
#import "OGAAdConfiguration.h"
#import "OGAAd.h"
#import "OGAThumbnailAdResponse.h"
#import "OGAThumbnailAdViewController.h"
#import "UIWindowScene+OGAActiveScene.h"
#import "OGAThumbnailAdConstants.h"
#import "OGAThumbnailAdViewController+Exposure.h"
#import "UIColor+OGAString.h"

@interface OGAThumbnailAdWindow ()

@property(strong, nonatomic, readwrite) OGAThumbnailAdViewController *thumbnailAdViewController;

@end

@implementation OGAThumbnailAdWindow

- (instancetype)initWithDisplayer:(id<OGAAdDisplayer>)displayer {
    return [self initWithDisplayer:displayer thumbnailViewController:[self createThumbnailAdViewControllerWithDisplayer:displayer]];
}

- (instancetype)initWithDisplayer:(id<OGAAdDisplayer>)displayer thumbnailViewController:(OGAThumbnailAdViewController *)thumbnailViewController {
    if (self = [super init]) {
        [self setupThumbnailAdWindowWithDisplayer:displayer];
        _thumbnailAdViewController = thumbnailViewController;
        self.rootViewController = self.thumbnailAdViewController;
        _isDraggable = YES;
        _isExpanded = NO;
    }
    return self;
}

- (void)setupThumbnailAdWindowWithDisplayer:(nonnull id<OGAAdDisplayer>)displayer {
    self.frame = CGRectMake(0, 0, [displayer.ad.thumbnailAdResponse.width floatValue], [displayer.ad.thumbnailAdResponse.height floatValue]);
    self.tag = OGAThumbnailAdWindowTag;
    self.clipsToBounds = YES;
    self.windowLevel = UIWindowLevelStatusBar;
    if (@available(iOS 13.0, *)) {
        if (displayer.configuration.scene != nil) {
            self.windowScene = displayer.configuration.scene;
        } else {
            self.windowScene = [UIWindowScene getOGAActiveScene];
        }
    }
}

- (BOOL)display:(id<OGAAdDisplayer>)displayer error:(OguryError *_Nullable *_Nullable)error {
    // No need to display again the displayer if it is already displayed by the view controller.
    if (self.thumbnailAdViewController.displayer == displayer) {
        [self.thumbnailAdViewController updateThumbnailAdWithAnimation:NO];
        [self.thumbnailAdViewController sendAdExposure];
        if (self.isExpanded) {
            [self.thumbnailAdViewController updateThumbnailToExpandedFormatWithDisplayer:displayer];
        } else {
            [self.thumbnailAdViewController updateThumbnailWithDisplayer:displayer];
        }
        return YES;
    }

    if (![self.thumbnailAdViewController display:displayer error:error]) {
        return NO;
    }

    if (@available(iOS 12, *)) {
        [self makeKeyAndVisible];
        [displayer startOMIDSessionOnShow];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self makeKeyAndVisible];
            [displayer startOMIDSessionOnShow];
        });
    }

    return YES;
}

- (OGAThumbnailAdViewController *)createThumbnailAdViewControllerWithDisplayer:(id<OGAAdDisplayer>)displayer {
    return [[OGAThumbnailAdViewController alloc] initWithWindow:self];
}

- (void)cleanUp {
    if (@available(iOS 13.0, *)) {
        self.windowScene = nil;
    }
    [self.thumbnailAdViewController cleanUp];
    self.thumbnailAdViewController = nil;
    self.rootViewController = nil;
}

@end

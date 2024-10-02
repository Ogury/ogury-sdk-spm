//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import "OGAThumbnailAdViewController+Position.h"
#import "OGAAd.h"
#import "OGAAdConfiguration.h"
#import "OGAThumbnailAdWindow.h"
#import "OGAThumbnailAdConstants.h"
#import "OGAInvalidThumbnailAdPositions.h"
#import "OGAAdDisplayerUpdateCurrentPositionInformation.h"
#import "OGAAdDisplayerUpdateCurrentAppOrientationInformation.h"
#import "OGAAdDisplayerUpdateScreenSizeInformation.h"
#import "UIApplication+Orientation.h"
#import "UIDevice+Orientation.h"
#import "OGADeviceOrientationConstants.h"
#import "OGASizeSafeAreaController.h"
#import "OGADeviceService.h"

@interface OGAThumbnailAdViewController ()

@property(nonatomic, weak, nullable) id<OGAAdDisplayer> displayer;
@property(nonatomic, weak, nullable) OGAThumbnailAdWindow *window;
@property(nonatomic, strong) NSNotificationCenter *notificationCenter;
@property(nonatomic, strong) UIPanGestureRecognizer *moveThumbnailAdPanGesture;
@property(nonatomic, assign) CGSize thumbnailSize;
@property(nonatomic, assign) CGPoint thumbnailPosition;
@property(nonatomic, assign) BOOL keyboardOnScreen;
@property(nonatomic, assign) CGRect keyboardRect;
@property(nonatomic, assign) OguryOffset offsetRatio;
@property(nonatomic, assign) OguryRectCorner rectCorner;
@property(strong, nonatomic, nullable) OGASizeSafeAreaController *safeAreaController;
@property(nonatomic, strong) OGADeviceService *deviceService;

@end

@implementation OGAThumbnailAdViewController (Position)

- (void)setupThumbnailPosition {
    [self initThumbnailPosition];
    [self applyOffsetToPosition];
    [self checkThumbnailCorrectPosition];
    [self updateOffsetRatio];
}

- (void)initThumbnailPosition {
    if ([self getDeviceWidth] != 0 && [self getVisibleHeight] != 0) {
        self.offsetRatio = OguryOffsetMake(self.displayer.ad.adConfiguration.offset.x / [self getDeviceWidth], self.displayer.ad.adConfiguration.offset.y / [self getVisibleHeight]);
    } else {
        self.offsetRatio = OguryOffsetMake(0, 0);
    }
    self.rectCorner = self.displayer.ad.adConfiguration.corner;
}

- (void)initThumbnailSize {
    CGFloat initialWidth = [self.displayer.ad.thumbnailAdResponse.width floatValue];
    CGFloat initialHeight = [self.displayer.ad.thumbnailAdResponse.height floatValue];
    self.thumbnailSize = CGSizeMake(initialWidth, initialHeight);
}

- (void)applyOffsetToPosition {
    float leftOffset = self.offsetRatio.x * [self getDeviceWidth];
    float topOffset = self.offsetRatio.y * [self getVisibleHeight];
    float rightOffset = [self getDeviceWidth] - self.thumbnailSize.width - leftOffset;
    float bottomOffset = [self getVisibleHeight] - self.thumbnailSize.height - topOffset;

    switch (self.rectCorner) {
        case OguryRectCornerTopLeft:
            self.thumbnailPosition = CGPointMake(leftOffset, topOffset);
            break;
        case OguryRectCornerTopRight:
            self.thumbnailPosition = CGPointMake(rightOffset, topOffset);
            break;
        case OguryRectCornerBottomLeft:
            self.thumbnailPosition = CGPointMake(leftOffset, bottomOffset);
            break;
        case OguryRectCornerBottomRight:
            self.thumbnailPosition = CGPointMake(rightOffset, bottomOffset);
            break;
    }
}

- (void)updateOffsetRatio {
    if ([self getDeviceWidth] == 0 || [self getVisibleHeight] == 0) {
        self.offsetRatio = OguryOffsetMake(0, 0);
        return;
    }

    if (self.thumbnailPosition.x + self.thumbnailSize.width / 2 < [self getDeviceWidth] / 2) {
        if (self.thumbnailPosition.y + self.thumbnailSize.height / 2 < [self getVisibleHeight] / 2) {
            self.offsetRatio = OguryOffsetMake(self.thumbnailPosition.x / [self getDeviceWidth], self.thumbnailPosition.y / [self getVisibleHeight]);
            self.rectCorner = OguryRectCornerTopLeft;
        } else {
            CGFloat convertedYOffsetRatio = ([self getVisibleHeight] - self.thumbnailPosition.y - self.thumbnailSize.height) / [self getVisibleHeight];
            self.offsetRatio = OguryOffsetMake(self.thumbnailPosition.x / [self getDeviceWidth], convertedYOffsetRatio);
            self.rectCorner = OguryRectCornerBottomLeft;
        }
    } else {
        if (self.thumbnailPosition.y + self.thumbnailSize.height / 2 < [self getVisibleHeight] / 2) {
            CGFloat convertedXOffsetRatio = ([self getDeviceWidth] - self.thumbnailPosition.x - self.thumbnailSize.width) / [self getDeviceWidth];
            self.offsetRatio = OguryOffsetMake(convertedXOffsetRatio, self.thumbnailPosition.y / [self getVisibleHeight]);
            self.rectCorner = OguryRectCornerTopRight;
        } else {
            CGFloat convertedXOffsetRatio = ([self getDeviceWidth] - self.thumbnailPosition.x - self.thumbnailSize.width) / [self getDeviceWidth];
            CGFloat convertedYOffsetRatio = ([self getVisibleHeight] - self.thumbnailPosition.y - self.thumbnailSize.height) / [self getVisibleHeight];
            self.offsetRatio = OguryOffsetMake(convertedXOffsetRatio, convertedYOffsetRatio);
            self.rectCorner = OguryRectCornerBottomRight;
        }
    }
}

- (void)checkThumbnailPartialOutofBounds {
    if (self.thumbnailPosition.x < 0) {
        self.thumbnailPosition = CGPointMake(0, self.thumbnailPosition.y);
    } else if (self.thumbnailPosition.x + self.thumbnailSize.width > [self getDeviceWidth]) {
        self.thumbnailPosition = CGPointMake([self getDeviceWidth] - self.thumbnailSize.width, self.thumbnailPosition.y);
    }

    if (self.thumbnailPosition.y < 0) {
        self.thumbnailPosition = CGPointMake(self.thumbnailPosition.x, 0);
    } else if (self.thumbnailPosition.y + self.thumbnailSize.height > [self getVisibleHeight]) {
        self.thumbnailPosition = CGPointMake(self.thumbnailPosition.x, [self getVisibleHeight] - self.thumbnailSize.height);
    }
}

- (CGFloat)getDeviceWidth {
    return [self.safeAreaController getUsableFullscreenFrameWithWindow:self.window].size.width;
}

- (CGFloat)getDeviceHeight {
    return [self.safeAreaController getUsableFullscreenFrameWithWindow:self.window].size.height;
}

- (CGSize)getScreenSize {
    return UIScreen.mainScreen.bounds.size;
}

- (CGFloat)getVisibleHeight {
    if (self.keyboardOnScreen) {
        return [self getScreenSize].height - self.keyboardRect.size.height;
    }
    return [self getScreenSize].height;
}

- (void)checkThumbnailCorrectPosition {
    [self checkThumbnailOutOfBounds];
    [self checkThumbnailPartialOutofBounds];
}

- (void)checkThumbnailOutOfBounds {
    OGAInvalidThumbnailAdPositions thumbnailPosition = [self canMoveToPoint:self.thumbnailPosition];

    while (thumbnailPosition != OGAInvalidPositionNone) {
        switch (thumbnailPosition) {
            case OGAInvalidPositionTop:
                self.thumbnailPosition = CGPointMake(self.thumbnailPosition.x, 0);
                break;
            case OGAInvalidPositionBottom:
                self.thumbnailPosition = CGPointMake(self.thumbnailPosition.x, [self getVisibleHeight] - self.thumbnailSize.height);
                break;
            case OGAInvalidPositionLeft:
                self.thumbnailPosition = CGPointMake(0, self.thumbnailPosition.y);
                break;
            case OGAInvalidPositionRight:
                self.thumbnailPosition = CGPointMake([self getDeviceWidth] - self.thumbnailSize.width, self.thumbnailPosition.y);
                break;
            case OGAInvalidPositionNone:
                return;
        }
        thumbnailPosition = [self canMoveToPoint:self.thumbnailPosition];
    }
}

- (OGAInvalidThumbnailAdPositions)canMoveToPoint:(CGPoint)point {
    if (point.x < 0 && fabs(point.x) > self.thumbnailSize.width * OGATwentyFivePercent) {
        return OGAInvalidPositionLeft;
    }

    if ((point.x + self.thumbnailSize.width * OGASeventyFivePercent) > [self getDeviceWidth]) {
        return OGAInvalidPositionRight;
    }

    if (point.y < 0 && fabs(point.y) > self.thumbnailSize.height * OGATwentyFivePercent) {
        return OGAInvalidPositionTop;
    }

    if ((point.y + self.thumbnailSize.height * OGASeventyFivePercent) > [self getVisibleHeight]) {
        return OGAInvalidPositionBottom;
    }

    return OGAInvalidPositionNone;
}

- (BOOL)isMinimumVisibleScreen {
    if ([self getDeviceHeight] * OGAMinimumVisibleArea <= [self getVisibleHeight]) {
        return YES;
    }
    return NO;
}

- (void)sendScreenOrientationChange:(CGSize)size {
    if (self.window.isExpanded) {
        [self.displayer dispatchInformation:[[OGAAdDisplayerUpdateScreenSizeInformation alloc]
                                                initWithSize:size]];
    }

    [self.displayer dispatchInformation:[[OGAAdDisplayerUpdateCurrentAppOrientationInformation alloc]
                                            initWithOrientation:[self.deviceService interfaceOrientation]
                                                         locked:false]];

    [self.displayer dispatchInformation:[[OGAAdDisplayerUpdateCurrentPositionInformation alloc]
                                            initWithPosition:self.thumbnailPosition
                                                        size:size]];
    [self sendCurrentOrientation];
}

- (void)sendCurrentOrientation {
    [self.displayer dispatchInformation:[[OGAAdDisplayerUpdateCurrentAppOrientationInformation alloc] initWithOrientation:[self.deviceService interfaceOrientation] locked:false]];
}

@end

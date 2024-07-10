//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import "OGAThumbnailAdWindowFactory.h"

@interface OGAThumbnailAdWindowFactory ()

@property(strong, nonatomic, nullable) OGAThumbnailAdWindow *thumbnailAdWindow;

@end

@implementation OGAThumbnailAdWindowFactory

- (OGAThumbnailAdWindow *)createThumbnailAdWindowWithDisplayer:(nonnull id<OGAAdDisplayer>)displayer {
    if (self.thumbnailAdWindow) {
        return self.thumbnailAdWindow;
    }
    self.thumbnailAdWindow = [[OGAThumbnailAdWindow alloc] initWithDisplayer:displayer];
    return self.thumbnailAdWindow;
}

- (OGAThumbnailAdWindow *)getThumbnailAdWindowIfExist {
    return self.thumbnailAdWindow;
}

- (void)cleanUp {
    self.thumbnailAdWindow = nil;
}

@end

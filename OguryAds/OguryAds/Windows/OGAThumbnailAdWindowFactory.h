//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAThumbnailAdWindow.h"
#import "OGAAdDisplayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAThumbnailAdWindowFactory : NSObject

- (OGAThumbnailAdWindow *)createThumbnailAdWindowWithDisplayer:(id<OGAAdDisplayer>)displayer;

- (OGAThumbnailAdWindow *_Nullable)getThumbnailAdWindowIfExist;

- (void)cleanUp;

@end

NS_ASSUME_NONNULL_END

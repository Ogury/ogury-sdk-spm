//
//  Copyright © 2018 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OGAAd;

typedef void (^MraidFileCompletion)(NSString *response, NSError *error);

@interface OGAMraidFileDownloader : NSObject

#pragma mark - Methods

- (void)downloadMraidJSFromURL:(OGAAd *)ad completion:(MraidFileCompletion)completion;

@end

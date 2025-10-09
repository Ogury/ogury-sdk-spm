//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGAThumbnailAdRestrictionsManager : NSObject

- (BOOL)shouldRestrict:(NSArray<NSString *> *_Nullable)viewControllers whiteListBundles:(NSArray<NSString *> *_Nullable)whiteListBundles;

@end

NS_ASSUME_NONNULL_END

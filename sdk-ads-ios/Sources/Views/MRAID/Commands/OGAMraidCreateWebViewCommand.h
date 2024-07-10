//
//  Copyright © 2018 Ogury. All rights reserved.
//

#import "OGAJSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAMraidCreateWebViewCommand : OGAJSONModel

#pragma mark - Properties

@property(nonatomic, copy) NSString *content;
@property(nonatomic, copy) NSString *webViewId;
@property(nonatomic, strong) NSDictionary *size;
@property(nonatomic, strong) NSDictionary *position;
@property(nonatomic, assign) BOOL isLandingPage;
@property(nonatomic, copy) NSString *url;
@property(nonatomic, assign) BOOL enableTracking;
@property(nonatomic, assign) BOOL keepAlive;
@property(nonatomic, assign) BOOL isUrlLoaded;
@property(nonatomic, assign) BOOL isTrackerIntercepted;

@end

NS_ASSUME_NONNULL_END

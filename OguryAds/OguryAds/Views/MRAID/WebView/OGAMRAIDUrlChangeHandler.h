//
//  Copyright © 2019 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OGAMraidCommand;

NS_ASSUME_NONNULL_BEGIN

@protocol OGAMRAIDWebViewUrlChangeHandlerDelegate <NSObject>

#pragma mark - Methods

- (void)mraidBlocked;

- (void)mraidAction:(OGAMraidCommand *)action;

- (void)mraidUnknownCommand:(NSString *)url;

@end

@interface OGAMRAIDUrlChangeHandler : NSObject

#pragma mark - Properties

@property(nonatomic, weak) id<OGAMRAIDWebViewUrlChangeHandlerDelegate> urlChangeHandlerDelegate;

#pragma mark - Methods

- (BOOL)shouldLoadUrl:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END

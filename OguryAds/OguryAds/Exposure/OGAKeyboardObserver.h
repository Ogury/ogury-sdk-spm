//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const OGAKeyboardVisibilityDidChangeNotification;

@interface OGAKeyboardObserver : NSObject

#pragma mark - Properties

@property(nonatomic, assign, readonly) BOOL keyboardOnScreen;
@property(nonatomic, strong, readonly) NSValue *keyboardRect;

#pragma mark - Methods

+ (instancetype)shared;

@end

NS_ASSUME_NONNULL_END

//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OGAKeyboardObserver.h"

NSString *const OGAKeyboardVisibilityDidChangeNotification = @"OGAKeyboardVisibilityDidChangeNotification";

@interface OGAKeyboardObserver ()

@property(nonatomic, strong) NSNotificationCenter *notificationCenter;
@property(nonatomic, assign, readwrite) BOOL keyboardOnScreen;
@property(nonatomic, strong, readwrite) NSValue *keyboardRect;

@end

@implementation OGAKeyboardObserver

+ (instancetype)shared {
    static OGAKeyboardObserver *instance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[OGAKeyboardObserver alloc] initWithNotificationCenter:NSNotificationCenter.defaultCenter];
    });
    return instance;
}

- (instancetype)initWithNotificationCenter:(NSNotificationCenter *)notificationCenter {
    if (self = [super init]) {
        _notificationCenter = notificationCenter;
        [_notificationCenter addObserver:self selector:@selector(didReceiveKKeyboardDidShowNotification:) name:UIKeyboardDidShowNotification object:nil];
        [_notificationCenter addObserver:self selector:@selector(didReceiveKeyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    }

    return self;
}

- (void)didReceiveKeyboardWillHideNotification:(NSNotification *)notification {
    self.keyboardOnScreen = NO;
    self.keyboardRect = [NSValue valueWithCGRect:CGRectZero];
    [self.notificationCenter postNotificationName:OGAKeyboardVisibilityDidChangeNotification object:nil userInfo:nil];
}

- (void)didReceiveKKeyboardDidShowNotification:(NSNotification *)notification {
    self.keyboardOnScreen = YES;
    NSValue *value = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    self.keyboardRect = value;
    [self.notificationCenter postNotificationName:OGAKeyboardVisibilityDidChangeNotification object:nil userInfo:nil];
}

- (void)dealloc {
    [self.notificationCenter removeObserver:self];
}

@end

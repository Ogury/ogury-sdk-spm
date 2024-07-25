//
//  Copyright © 2019 Ogury. All rights reserved.
//

#import "OGAMRAIDUrlChangeHandler.h"
#import "OGAMraidCommand.h"

@implementation OGAMRAIDUrlChangeHandler

#pragma mark - Methods

- (BOOL)shouldLoadUrl:(NSURL *)url {
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];

    if ([components.host isEqualToString:@"ogymraid"]) {
        [self handleMRAIDCommandsOfURL:url];
        return NO;
    } else {
        return YES;
    }
}

- (void)handleMRAIDCommandsOfURL:(NSURL *)url {
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSString *parameter = components.queryItems.firstObject.name;
    NSString *value = components.queryItems.firstObject.value;

    if ([parameter isEqualToString:@"q"]) {
        [self.urlChangeHandlerDelegate mraidAction:[[OGAMraidCommand alloc] initWithString:value error:nil]];
        return;
    }

    if ([url.absoluteString containsString:@"mraid.js"]) {
        [self.urlChangeHandlerDelegate mraidBlocked];
        return;
    }

    [self.urlChangeHandlerDelegate mraidUnknownCommand:url.absoluteString];
}

@end

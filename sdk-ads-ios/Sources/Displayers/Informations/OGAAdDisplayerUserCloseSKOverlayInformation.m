//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdDisplayerUserCloseSKOverlayInformation.h"
#import "OGALog.h"

@interface OGAAdDisplayerUserCloseSKOverlayInformation ()

@property(nonatomic, strong) OGALog *log;

@end

@implementation OGAAdDisplayerUserCloseSKOverlayInformation

#pragma mark - Initialization

- (instancetype)initWithErrorCode:(NSNumber *)errorCode log:(OGALog *)log {
    if (self = [super init]) {
        _errorCode = errorCode;
        _log = log;
    }
    return self;
}

- (instancetype)initWithErrorCode:(NSNumber *)errorCode {
    return [self initWithErrorCode:errorCode log:[OGALog shared]];
}

#pragma mark - Methods

- (NSString *)toJavascriptCommand {
    if (!self.errorCode) {
        return [NSString stringWithFormat:@"ogySdkMraidGateway.ogyUserCloseSKOverlay()"];
    } else {
        return [NSString stringWithFormat:@"ogySdkMraidGateway.ogyUserCloseSKOverlay({error_code:%@})", self.errorCode];
    }
}

@end
